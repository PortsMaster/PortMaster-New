import base64, json, os, shutil, subprocess, sys, time, urllib.parse, urllib.request, zipfile

APP_DIR = os.path.dirname(os.path.abspath(__file__))
YTDLP_DIR = os.path.join(APP_DIR, "ytdlp_src")
DENO = os.path.join(APP_DIR, "bin", "deno")


def _js(quality):
    if quality == "720p" and os.access(DENO, os.X_OK):
        return {"js_runtimes": {"deno": {"path": DENO}}}
    return {}
sys.path.insert(0, YTDLP_DIR)
import yt_dlp

import i18n
from i18n import T, decimal

VERSION = yt_dlp.version.__version__

QUALITY = {
    "240p": "133+ba[ext=m4a]/160+ba[ext=m4a]/best[height<=240]",
    "360p": "134+ba[ext=m4a]/133+ba[ext=m4a]/160+ba[ext=m4a]/best[height<=360]",
    "480p": "135+ba[ext=m4a]/134+ba[ext=m4a]/133+ba[ext=m4a]/best[height<=480]",
    "720p": ("136+ba[ext=m4a]/bestvideo[height<=720][fps<=30][vcodec^=avc1]+ba[ext=m4a]"
             "/bestvideo[height<=720][vcodec^=avc1]+ba[ext=m4a]/135+ba[ext=m4a]/134+ba[ext=m4a]/best[height<=720]"),
    "audio": "140/bestaudio[ext=m4a]/bestaudio",
}
from store import MUSIC_DIR  # noqa: E402
THUMBS = {}

def _live_fmt(h):
    v = f"bestvideo[height<={h}][vcodec^=avc1][protocol^=m3u8]"
    a = "bestaudio[protocol^=m3u8]"
    return f"{v}+{a}/best[height<={h}][protocol^=m3u8]/bestvideo[protocol^=m3u8]+{a}/best"


LIVE_QUALITY = {q: _live_fmt(int(q[:-1])) for q in ("240p", "360p", "480p", "720p")}

_BASE = {"quiet": True, "no_warnings": True, "noplaylist": True}
_search_dl = yt_dlp.YoutubeDL({**_BASE, "extract_flat": "in_playlist"})
_list_dl = yt_dlp.YoutubeDL({"quiet": True, "no_warnings": True, "extract_flat": "in_playlist", "playlistend": 50})
_stream_dls = {}
_live_dls = {}


def _stream_dl(quality, js=False):
    key = (quality, js)
    if key not in _stream_dls:
        _stream_dls[key] = yt_dlp.YoutubeDL({
            **_BASE, **(_js(quality) if js else {}), "format": QUALITY.get(quality, QUALITY["360p"]),
            "extractor_args": {"youtube": {"skip": ["hls"]}},
        })
    return _stream_dls[key]


def _live_dl(quality):
    if quality not in _live_dls:
        _live_dls[quality] = yt_dlp.YoutubeDL({
            **_BASE, **_js(quality), "format": LIVE_QUALITY.get(quality, LIVE_QUALITY["360p"]),
        })
    return _live_dls[quality]


def thumb_url(video_id):
    if video_id in THUMBS:
        return THUMBS[video_id]
    return f"https://i.ytimg.com/vi/{video_id}/mqdefault.jpg"


FILTERS = {
    "sort": [("relevance", 0), ("date", 2), ("views", 3)],
    "date": [("any", 0), ("hour", 1), ("today", 2), ("week", 3), ("month", 4), ("year", 5)],
    "duration": [("any", 0), ("short", 1), ("medium", 3), ("long", 2)],
    "type": [("any", 0), ("video", 1), ("live", "live"), ("playlist", 3)],
}


def filter_code(filters):
    vals = {k: dict(FILTERS[k]).get(filters.get(k, FILTERS[k][0][0]), 0) for k in FILTERS}
    inner = b""
    if vals["date"]:
        inner += bytes([0x08, vals["date"]])
    if vals["type"] == "live":
        live = True
    else:
        live = False
        if vals["type"]:
            inner += bytes([0x10, vals["type"]])
    if vals["duration"]:
        inner += bytes([0x18, vals["duration"]])
    if live:
        inner += bytes([0x40, 0x01])
    out = bytes([0x08, vals["sort"]]) if vals["sort"] else b""
    if inner:
        out += bytes([0x12, len(inner)]) + inner
    return base64.b64encode(out).decode() if out else ""


def _thumb(e):
    for t in reversed(e.get("thumbnails") or []):
        if t.get("url"):
            return t["url"]
    return None


def _entry(e):
    if e.get("ie_key") == "YoutubeTab" or "list=" in (e.get("url") or "") and not e.get("duration"):
        thumb = _thumb(e)
        if thumb:
            THUMBS[e["id"]] = thumb
        return {"id": e["id"], "kind": "playlist", "title": e.get("title") or "",
                "channel": e.get("channel") or e.get("uploader") or "", "duration": 0, "live": False,
                "count": e.get("playlist_count") or e.get("video_count") or 0}
    duration = e.get("duration") or 0
    return {
        "id": e["id"],
        "title": e.get("title") or "",
        "channel": e.get("channel") or e.get("uploader") or "",
        "duration": duration,
        "live": e.get("live_status") == "is_live" or not duration,
    }


def search(query, count=15, filters=None):
    code = filter_code(filters or {})
    if code:
        url = ("https://www.youtube.com/results?search_query=" + urllib.parse.quote(query)
               + "&sp=" + urllib.parse.quote(code))
        dl = yt_dlp.YoutubeDL({"quiet": True, "no_warnings": True, "extract_flat": "in_playlist", "playlistend": count})
        info = dl.extract_info(url, download=False)
    else:
        info = _search_dl.extract_info(f"ytsearch{count}:{query}", download=False)
    return [_entry(e) for e in info.get("entries") or [] if e and e.get("id")]


def playlist_items(playlist_id):
    info = _list_dl.extract_info("https://www.youtube.com/playlist?list=" + playlist_id, download=False)
    return {"title": info.get("title") or "",
            "items": [_entry(e) for e in info.get("entries") or [] if e and e.get("id") and len(e["id"]) == 11]}


_NEXT_URL = "https://www.youtube.com/youtubei/v1/next?prettyPrint=false"
_NEXT_CLIENT = {"clientName": "WEB", "clientVersion": "2.20251101.00.00", "hl": "en"}


def _seconds(text):
    try:
        sec = 0
        for part in (text or "").strip().split(":"):
            sec = sec * 60 + int(part)
        return sec
    except ValueError:
        return 0


def _runs(t):
    return (t or {}).get("simpleText") or "".join(r.get("text", "") for r in (t or {}).get("runs") or [])


def _from_lockup(lv):
    """Related item in YouTube's newer lockupViewModel shape (2025+)."""
    if lv.get("contentType") != "LOCKUP_CONTENT_TYPE_VIDEO" or len(lv.get("contentId") or "") != 11:
        return None
    md = lv.get("metadata", {}).get("lockupMetadataViewModel", {})
    rows = md.get("metadata", {}).get("contentMetadataViewModel", {}).get("metadataRows") or []
    parts = (rows[0].get("metadataParts") or []) if rows else []
    channel = parts[0].get("text", {}).get("content", "") if parts else ""
    overlays = lv.get("contentImage", {}).get("thumbnailViewModel", {}).get("overlays") or []
    badges = [b.get("thumbnailBadgeViewModel", {}).get("text", "") for o in overlays
              for b in o.get("thumbnailBottomOverlayViewModel", {}).get("badges") or []]
    duration = next((_seconds(b) for b in badges if _seconds(b)), 0)
    return {"id": lv["contentId"], "title": md.get("title", {}).get("content", ""),
            "channel": channel, "duration": duration, "live": not duration}


def _from_compact(r):
    """Related item in the older compactVideoRenderer shape."""
    if len(r.get("videoId") or "") != 11:
        return None
    duration = _seconds(_runs(r.get("lengthText")))
    return {"id": r["videoId"], "title": _runs(r.get("title")), "channel": _runs(r.get("shortBylineText")),
            "duration": duration, "live": not duration}


def _related_next(video_id):
    body = json.dumps({"context": {"client": _NEXT_CLIENT}, "videoId": video_id}).encode()
    req = urllib.request.Request(_NEXT_URL, data=body, headers={"Content-Type": "application/json",
                                                                "User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req, timeout=10) as r:
        data = json.loads(r.read().decode("utf-8", "replace"))
    results = (data.get("contents", {}).get("twoColumnWatchNextResults", {}).get("secondaryResults", {})
               .get("secondaryResults", {}).get("results") or [])
    out = []
    for x in results:
        if "lockupViewModel" in x:
            out.append(_from_lockup(x["lockupViewModel"]))
        elif "compactVideoRenderer" in x:
            out.append(_from_compact(x["compactVideoRenderer"]))
    return [v for v in out if v]


def _related_mix(video_id):
    """Older way: the video's auto-generated mix playlist. YouTube stopped serving it to yt-dlp in 2026."""
    info = _list_dl.extract_info(f"https://www.youtube.com/watch?v={video_id}&list=RD{video_id}", download=False)
    return [_entry(e) for e in info.get("entries") or [] if e and e.get("id") and len(e["id"]) == 11]


def related(video_id, count=12):
    try:
        items = _related_next(video_id)
    except Exception:
        items = []
    if not items:
        items = _related_mix(video_id)
    seen, out = {video_id}, []
    for v in items:
        if v["id"] not in seen:
            seen.add(v["id"])
            out.append(v)
    return out[:count]


def _height(info):
    fmts = info.get("requested_formats") or [info]
    return max((f.get("height") or 0) for f in fmts)


def get_details(video_id, quality="360p", live=False):
    url = f"https://www.youtube.com/watch?v={video_id}"
    if live:
        info = _live_dl(quality).extract_info(url, download=False)
    else:
        try:
            info = _stream_dl(quality).extract_info(url, download=False)
            if _js(quality) and _height(info) < 720:
                try:
                    better = _stream_dl(quality, js=True).extract_info(url, download=False)
                    if _height(better) > _height(info):
                        info = better
                except Exception:
                    pass
        except Exception:
            try:
                info = _live_dl(quality).extract_info(url, download=False)
            except Exception:
                info = {}
            if info.get("live_status") != "is_live":
                raise
    is_live = info.get("live_status") == "is_live"
    if "requested_formats" in info:
        fmts = info["requested_formats"]
        video_url, audio_url = fmts[0]["url"], fmts[1]["url"]
    else:
        fmts = [info]
        video_url, audio_url = info["url"], None
    size = 0 if is_live else sum((f.get("filesize") or f.get("filesize_approx") or 0) for f in fmts)
    return {
        "chapters": [] if is_live else chapters_of(info),
        "subs": sub_tracks(info),
        "id": video_id,
        "title": info.get("title") or "",
        "channel": info.get("channel") or info.get("uploader") or "",
        "duration": 0 if is_live else (info.get("duration") or 0),
        "description": (info.get("description") or "").strip(),
        "live": is_live,
        "video_url": video_url,
        "audio_url": audio_url,
        "size": size,
        "fetched": time.time(),
    }


def suggestions(query, limit=2):
    url = ("https://suggestqueries.google.com/complete/search?client=firefox&ds=yt&q="
           + urllib.parse.quote(query))
    try:
        with urllib.request.urlopen(url, timeout=3) as r:
            data = json.loads(r.read().decode("utf-8", "replace"))
        return [s for s in data[1] if s != query][:limit]
    except Exception:
        return []


class Cancelled(Exception):
    pass


LANG_NAMES = {"ru": "Русский", "en": "English", "uk": "Українська", "de": "Deutsch", "fr": "Français",
              "es": "Español", "it": "Italiano", "pt": "Português", "ja": "日本語", "ko": "한국어",
              "zh": "中文", "tr": "Türkçe", "az": "Azərbaycan", "kk": "Қазақ", "pl": "Polski"}


def chapters_of(info):
    out = []
    for ch in info.get("chapters") or []:
        start = ch.get("start_time")
        if isinstance(start, (int, float)):
            out.append({"start": float(start), "title": (ch.get("title") or "").strip()})
    return out


def _vtt(entries):
    for e in entries or []:
        if e.get("ext") == "vtt" and e.get("url"):
            return e["url"]
    return None


def _lang_name(code):
    base = code.split("-")[0]
    return LANG_NAMES.get(base, code)


def sub_tracks(info):
    manual = info.get("subtitles") or {}
    auto = info.get("automatic_captions") or {}
    orig = (info.get("language") or "").split("-")[0]
    ui = i18n.LANG
    other = "ru" if ui == "en" else "en"  # second language offered for subtitles
    tracks, seen = [], set()

    def add(key, url, name, lang):
        if url and key not in seen:
            seen.add(key)
            tracks.append({"key": key, "url": url, "name": name, "lang": lang})

    for lang in [ui, other] + ([orig] if orig and orig not in (ui, other) else []):
        code = lang if lang in manual else next((k for k in manual if k.split("-")[0] == lang), None)
        if code:
            add("m:" + lang, _vtt(manual[code]), _lang_name(lang), lang)
    if orig:
        code = next((k for k in (orig + "-orig", orig) if k in auto), None)
        if code:
            add("a:" + orig, _vtt(auto[code]), _lang_name(orig) + " " + T("sub_auto"), orig)
    for lang in [ui, other]:
        if lang != orig and lang in auto:
            add("t:" + lang, _vtt(auto[lang]), _lang_name(lang) + " " + T("sub_translated"), lang)
    for code in sorted(manual):
        lang = code.split("-")[0]
        if len(tracks) >= 8:
            break
        add("m:" + lang, _vtt(manual[code]), _lang_name(code), lang)
    return tracks


def save_subs(video_id, folder, tracks, limit=3):
    saved = []
    for t in tracks[:limit]:
        path = os.path.join(folder, f"{video_id}.{t['key'].replace(':', '-')}.vtt")
        try:
            req = urllib.request.Request(t["url"], headers={"User-Agent": "Mozilla/5.0"})
            with urllib.request.urlopen(req, timeout=15) as r:
                data = r.read()
            if data.startswith(b"WEBVTT"):
                with open(path, "wb") as f:
                    f.write(data)
                saved.append({"key": t["key"], "name": t["name"], "lang": t["lang"], "path": path})
        except Exception:
            pass
    return saved


def download(video_id, folder, quality, on_progress, cancelled=lambda: False):
    os.makedirs(folder, exist_ok=True)
    state = {"done_files": 0}
    parts = 1 if quality == "audio" else 2

    def hook(d):
        if cancelled():
            raise Cancelled()
        if d["status"] == "downloading":
            total = d.get("total_bytes") or d.get("total_bytes_estimate") or 0
            part = d.get("downloaded_bytes", 0) / total if total else 0
            on_progress(min(0.99, (state["done_files"] + part) / parts))
        elif d["status"] == "finished":
            state["done_files"] += 1

    audio = quality == "audio"
    if audio:
        folder = MUSIC_DIR
        os.makedirs(folder, exist_ok=True)
    opts = {
        **_BASE, **_js(quality),
        "format": QUALITY.get(quality, QUALITY["360p"]),
        "outtmpl": os.path.join(folder, "%(title).80B [%(id)s].%(ext)s" if audio else "%(id)s.%(ext)s"),
        "merge_output_format": None if audio else "mp4",
        "postprocessors": [{"key": "FFmpegMetadata"}] if audio else [],
        "noprogress": True,
        "progress_hooks": [hook],
        "extractor_args": {"youtube": {"skip": ["hls", "translated_subs"]}},
    }
    try:
        with yt_dlp.YoutubeDL(opts) as ydl:
            info = ydl.extract_info(f"https://www.youtube.com/watch?v={video_id}", download=True)
    except BaseException:
        if cancelled():
            remove_partial(video_id, folder)
            raise Cancelled()
        raise
    if audio:
        reqs = (info or {}).get("requested_downloads") or []
        path = reqs[0].get("filepath") if reqs else None
        if not path or not os.path.exists(path):
            path = next((os.path.join(folder, n) for n in os.listdir(folder) if f"[{video_id}]" in n), "")
        extra = {"chapters": chapters_of(info or {}), "subs": [], "audio": True}
        on_progress(1.0)
        return path, extra
    path = os.path.join(folder, f"{video_id}.mp4")
    extra = {"chapters": chapters_of(info or {}), "subs": save_subs(video_id, folder, sub_tracks(info or {}))}
    on_progress(1.0)
    return path, extra


def format_duration(sec):
    sec = int(sec or 0)
    h, m, s = sec // 3600, sec // 60 % 60, sec % 60
    return f"{h}:{m:02}:{s:02}" if h else f"{m}:{s:02}"


def format_size(num):
    if not num:
        return ""
    if num >= 1024 ** 3:
        return T("gb", n=decimal(num / 1024 ** 3))
    return T("mb", n=round(num / 1024 ** 2))


def remove_partial(video_id, folder):
    try:
        names = os.listdir(folder)
    except OSError:
        return
    for name in names:
        if (name.startswith(video_id + ".") and name != video_id + ".mp4") or (f"[{video_id}]" in name and name.endswith((".part", ".ytdl"))):
            try:
                os.remove(os.path.join(folder, name))
            except OSError:
                pass


RELEASE_API = "https://api.github.com/repos/yt-dlp/yt-dlp/releases/latest"
RELEASE_FILE = "https://github.com/yt-dlp/yt-dlp/releases/download/{tag}/yt-dlp"
_UA = {"User-Agent": "PocketTube"}


def latest_version():
    req = urllib.request.Request(RELEASE_API, headers=_UA)
    with urllib.request.urlopen(req, timeout=10) as r:
        return json.loads(r.read().decode("utf-8"))["tag_name"]


def update_ytdlp(on_progress=lambda p: None):
    tag = latest_version()
    if tag == VERSION:
        return tag, False
    tmp_zip = os.path.join(APP_DIR, "yt-dlp.download")
    new_dir, old_dir = YTDLP_DIR + ".new", YTDLP_DIR + ".old"
    shutil.rmtree(new_dir, ignore_errors=True)
    try:
        req = urllib.request.Request(RELEASE_FILE.format(tag=tag), headers=_UA)
        with urllib.request.urlopen(req, timeout=20) as r, open(tmp_zip, "wb") as f:
            total, got = int(r.headers.get("Content-Length") or 0), 0
            while True:
                chunk = r.read(65536)
                if not chunk:
                    break
                f.write(chunk)
                got += len(chunk)
                if total:
                    on_progress(0.8 * got / total)
        with zipfile.ZipFile(tmp_zip) as z:
            members = [m for m in z.namelist() if m != "__main__.py" and not m.startswith("/") and ".." not in m]
            if not any(m.startswith("yt_dlp/") for m in members):
                raise RuntimeError(T("no_ytdlp_in_archive"))
            z.extractall(new_dir, members)
        on_progress(0.9)
        check = subprocess.run(
            [sys.executable, "-c",
             "import sys;sys.path.insert(0,sys.argv[1]);import yt_dlp;print(yt_dlp.version.__version__)",
             new_dir], capture_output=True, text=True, timeout=180)
        if check.returncode != 0:
            raise RuntimeError(T("new_version_broken"))
        shutil.rmtree(old_dir, ignore_errors=True)
        os.rename(YTDLP_DIR, old_dir)
        os.rename(new_dir, YTDLP_DIR)
        on_progress(1.0)
        return check.stdout.strip() or tag, True
    finally:
        shutil.rmtree(new_dir, ignore_errors=True)
        try:
            os.remove(tmp_zip)
        except OSError:
            pass


def has_rollback():
    return os.path.isdir(YTDLP_DIR + ".old")


def rollback_ytdlp():
    old_dir, bad = YTDLP_DIR + ".old", YTDLP_DIR + ".bad"
    if not os.path.isdir(old_dir):
        return False
    shutil.rmtree(bad, ignore_errors=True)
    os.rename(YTDLP_DIR, bad)
    os.rename(old_dir, YTDLP_DIR)
    shutil.rmtree(bad, ignore_errors=True)
    return True
