import json, os, threading, time

APP_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_FILE = os.path.join(APP_DIR, "data.json")
# Batocera / KNULLI keep media in /userdata; on other firmware everything stays in the app folder
USERDATA = "/userdata" if os.path.isdir("/userdata/roms") else None
DOWNLOAD_DIRS = ([USERDATA + "/videos/youtube"] if USERDATA else []) + [os.path.join(APP_DIR, "downloads")]
MUSIC_DIR = USERDATA + "/music/youtube" if USERDATA else os.path.join(APP_DIR, "music")
QUALITIES = ["240p", "360p", "480p", "720p"]
DL_QUALITIES = QUALITIES + ["audio"]
WATCH_LATER = "wl"


class Store:
    def __init__(self):
        self.lock = threading.Lock()
        self.data = {
            "settings": {"quality": "360p", "dl_quality": "360p", "dl_dir": DOWNLOAD_DIRS[0],
                         "sounds": True, "lang": "en", "kb_layout": "en",
                         "sub_lang": None, "sub_last": None, "player_hints_shown": False},
            "history": [],
            "queries": [],
            "downloads": [],
            "playlists": [],
        }
        saved = {}
        try:
            with open(DATA_FILE, encoding="utf-8") as f:
                saved = json.load(f)
            for key in self.data:
                if key in saved:
                    if isinstance(self.data[key], dict):
                        self.data[key].update(saved[key])
                    else:
                        self.data[key] = saved[key]
        except (OSError, ValueError):
            pass
        if "lang" not in saved.get("settings", {}):
            self.data["settings"]["lang"] = "ru" if saved else "en"
        if "kb_layout" not in saved.get("settings", {}):
            self.data["settings"]["kb_layout"] = self.data["settings"]["lang"]
        if not any(p.get("id") == WATCH_LATER for p in self.data["playlists"]):
            self.data["playlists"].insert(0, {"id": WATCH_LATER, "name": "", "items": []})
        if self.data["settings"].get("dl_dir") not in DOWNLOAD_DIRS:
            self.data["settings"]["dl_dir"] = DOWNLOAD_DIRS[0]
        if self.data["settings"].get("dl_quality") not in DL_QUALITIES:
            self.data["settings"]["dl_quality"] = "360p"
        for d in self.data["downloads"]:
            if d["status"] == "loading":
                d["status"], d["progress"] = "queued", 0

    def save(self):
        with self.lock:
            tmp = DATA_FILE + ".tmp"
            with open(tmp, "w", encoding="utf-8") as f:
                json.dump(self.data, f, ensure_ascii=False, indent=1)
            os.replace(tmp, DATA_FILE)

    @property
    def settings(self):
        return self.data["settings"]

    @property
    def history(self):
        return self.data["history"]

    @property
    def queries(self):
        return self.data["queries"]

    @property
    def downloads(self):
        return self.data["downloads"]

    def add_query(self, q):
        q = q.strip()
        if not q:
            return
        qs = [x for x in self.queries if x.lower() != q.lower()]
        self.data["queries"] = [q] + qs[:7]
        self.save()

    def add_history(self, video, pos):
        entry = {k: video.get(k) for k in ("id", "title", "channel", "duration", "live")}
        entry["pos"] = pos
        entry["time"] = time.time()
        rest = [h for h in self.history if h["id"] != video["id"]]
        self.data["history"] = [entry] + rest[:49]
        self.save()

    def history_pos(self, video_id):
        for h in self.history:
            if h["id"] == video_id:
                return h.get("pos") or 0
        return 0

    def clear_history(self):
        self.data["history"] = []
        self.data["queries"] = []
        self.save()

    def find_download(self, video_id):
        for d in self.downloads:
            if d["id"] == video_id:
                return d
        return None

    def add_download(self, video):
        if self.find_download(video["id"]):
            return False
        entry = {k: video.get(k) for k in ("id", "title", "channel", "duration")}
        entry.update(status="queued", progress=0, file="", size=0,
                     quality=self.settings["dl_quality"])
        self.downloads.append(entry)
        self.save()
        return True

    def remove_download(self, video_id):
        d = self.find_download(video_id)
        if not d:
            return
        for path in [d.get("file")] + [t.get("path") for t in d.get("subs") or []]:
            if path and os.path.exists(path):
                try:
                    os.remove(path)
                except OSError:
                    pass
        self.data["downloads"] = [x for x in self.downloads if x["id"] != video_id]
        self.save()

    @property
    def playlists(self):
        return self.data["playlists"]

    def playlist(self, pid):
        return next((p for p in self.playlists if p["id"] == pid), None)

    def in_playlist(self, pid, video_id):
        p = self.playlist(pid)
        return bool(p) and any(v["id"] == video_id for v in p["items"])

    def playlist_toggle(self, pid, video):
        p = self.playlist(pid)
        if not p:
            return False
        if self.in_playlist(pid, video["id"]):
            p["items"] = [v for v in p["items"] if v["id"] != video["id"]]
            added = False
        else:
            p["items"].append({k: video.get(k) for k in ("id", "title", "channel", "duration", "live")})
            added = True
        self.save()
        return added

    def playlist_remove(self, pid, video_id):
        p = self.playlist(pid)
        if p:
            p["items"] = [v for v in p["items"] if v["id"] != video_id]
            self.save()

    def playlist_create(self, name, items=None):
        pid = "p" + str(int(time.time() * 1000))
        self.playlists.append({"id": pid, "name": name.strip()[:60], "items": list(items or [])})
        self.save()
        return pid

    def playlist_delete(self, pid):
        if pid != WATCH_LATER:
            self.data["playlists"] = [p for p in self.playlists if p["id"] != pid]
            self.save()
