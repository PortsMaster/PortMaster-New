import json, os, socket, subprocess, threading, time, urllib.request

import i18n
from i18n import T

APP_DIR = os.path.dirname(os.path.abspath(__file__))
SOCK = "/tmp/pockettube-mpv.sock"
CHAPTERS_FILE = "/tmp/pockettube-chapters.txt"
SUB_DIR = "/tmp/pockettube-subs"
INPUT_CONF = os.path.join(APP_DIR, "player-input.conf")
SPEEDS = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0]
SLEEP_MINUTES = [0, 15, 30, 45, 60, 90]
BLANK = "/sys/class/graphics/fb0/blank"
DARK_AFTER = 8
W, H = 640, 480

WHITE, GREY, RED, BLACK = "FFFFFF", "AAAAAA", "3C21E6", "000000"
ACCENT = "FF5C7C"


def esc(s):
    return str(s).replace("\\", "\\\\").replace("{", "(").replace("}", ")").replace("\n", " ")


def fmt_time(sec):
    sec = int(max(0, sec or 0))
    h, m, s = sec // 3600, sec // 60 % 60, sec % 60
    return f"{h}:{m:02}:{s:02}" if h else f"{m}:{s:02}"


def fmt_speed(x):
    s = f"{x:g}×"
    return s.replace(".", ",") if i18n.LANG in i18n.DECIMAL_COMMA else s


class Ass:
    def __init__(self):
        self.parts = []

    def rect(self, x, y, w, h, color, alpha="00", r=0):
        x2, y2 = x + w, y + h
        if r:
            r = min(r, w // 2, h // 2)
            path = (f"m {x + r} {y} l {x2 - r} {y} b {x2} {y} {x2} {y} {x2} {y + r} l {x2} {y2 - r} "
                    f"b {x2} {y2} {x2} {y2} {x2 - r} {y2} l {x + r} {y2} b {x} {y2} {x} {y2} {x} {y2 - r} "
                    f"l {x} {y + r} b {x} {y} {x} {y} {x + r} {y}")
        else:
            path = f"m {x} {y} l {x2} {y} l {x2} {y2} l {x} {y2}"
        self.parts.append(f"{{\\an7\\pos(0,0)\\bord0\\shad0\\1c&H{color}&\\1a&H{alpha}&\\p1}}{path}{{\\p0}}")

    def text(self, x, y, s, size=16, color=WHITE, an=7, bold=False):
        b = "\\b1" if bold else "\\b0"
        self.parts.append(f"{{\\an{an}\\pos({x},{y})\\fnDejaVu Sans\\fs{size}{b}\\bord0\\shad0\\1c&H{color}&\\1a&H00&}}{esc(s)}")

    def data(self):
        return "\n".join(self.parts)


class Ipc:
    def __init__(self, path, on_event):
        self.sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        self.sock.connect(path)
        self.lock = threading.Lock()
        self.on_event = on_event
        self.alive = True
        threading.Thread(target=self._reader, daemon=True).start()

    def _reader(self):
        buf = b""
        while self.alive:
            try:
                chunk = self.sock.recv(65536)
            except OSError:
                break
            if not chunk:
                break
            buf += chunk
            while b"\n" in buf:
                line, buf = buf.split(b"\n", 1)
                try:
                    self.on_event(json.loads(line.decode("utf-8", "replace")))
                except ValueError:
                    pass
        self.alive = False

    def cmd(self, *args):
        if not self.alive:
            return
        msg = json.dumps({"command": list(args)}, ensure_ascii=False) + "\n"
        with self.lock:
            try:
                self.sock.sendall(msg.encode("utf-8"))
            except OSError:
                self.alive = False

    def close(self):
        self.alive = False
        try:
            self.sock.close()
        except OSError:
            pass


def write_chapters(chapters, duration):
    if not chapters:
        return None
    lines = [";FFMETADATA1"]
    for i, ch in enumerate(chapters):
        start = float(ch.get("start") or 0)
        end = float(chapters[i + 1].get("start")) if i + 1 < len(chapters) else float(duration or start + 1)
        title = str(ch.get("title") or "").replace("\n", " ").replace("=", "-").replace(";", ",").replace("#", " ")
        lines += ["[CHAPTER]", "TIMEBASE=1/1000", f"START={int(start * 1000)}", f"END={int(max(end, start + 1) * 1000)}", f"title={title}"]
    with open(CHAPTERS_FILE, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
    return CHAPTERS_FILE


def set_blank(on):
    try:
        with open(BLANK, "w") as f:
            f.write("1" if on else "0")
        return True
    except OSError:
        return False


def fetch_sub(track):
    if track.get("path"):
        return track["path"]
    os.makedirs(SUB_DIR, exist_ok=True)
    path = os.path.join(SUB_DIR, f"{abs(hash(track['url']))}.vtt")
    if os.path.exists(path):
        return path
    req = urllib.request.Request(track["url"], headers={"User-Agent": "Mozilla/5.0"})
    last = None
    for attempt in range(2):
        try:
            with urllib.request.urlopen(req, timeout=10) as r:
                data = r.read()
            if not data.startswith(b"WEBVTT"):
                raise ValueError("not a subtitle file")
            with open(path, "wb") as f:
                f.write(data)
            return path
        except Exception as e:
            last = e
            time.sleep(1.5)
    raise last


class Player:
    def __init__(self, url, audio_url=None, start=0, title="", live=False, duration=0,
                 chapters=None, subs=None, settings=None, save=lambda: None, audio_only=False, can_video=True):
        self.url, self.audio_url, self.start = url, audio_url, start
        self.title, self.live, self.duration = title, live, duration or 0
        self.chapters = chapters or []
        self.subs = subs or []
        self.settings = settings if settings is not None else {}
        self.save = save
        self.pos, self.paused, self.speed, self.buffering = float(start), False, 1.0, False
        self.chapter = -1
        self.started = False
        self.sub_idx = -1
        self.sub_sids = {}
        self.pending_sub = None
        self.bar_until = 0
        self.pinned = False
        self.flash, self.flash_until = "", 0
        self.mode = "play"
        self.menu_sel, self.list_sel, self.list_kind = 0, 0, ""
        self.help_first = False
        self.dirty = True
        self.lock = threading.Lock()
        self.keys = []
        self.audio_only, self.can_video = audio_only, can_video
        self.dark, self.last_key = False, time.time()
        self.sleep_min, self.sleep_at = 0, 0
        self.end_reason = ""

    def cmdline(self):
        cmd = ["mpv", "--fs", "--vo=sdl", "--hwdec=no", "--cache=yes",
               "--input-default-bindings=no", "--input-conf=" + INPUT_CONF,
               "--input-ipc-server=" + SOCK, "--osd-level=0", "--sub-auto=no",
               "--sub-font=DejaVu Sans", "--sub-font-size=44", "--sub-border-size=3",
               "--force-window=yes", "--keep-open=no"]
        if self.title:
            cmd.append("--force-media-title=" + self.title)
        if self.audio_only:
            cmd.append("--vid=no")
        if self.live:
            cmd += ["--cache-secs=20", "--demuxer-max-bytes=32MiB"]
        elif self.start > 5:
            cmd.append(f"--start={int(self.start)}")
        chf = None if self.live else write_chapters(self.chapters, self.duration)
        if chf:
            cmd.append("--chapters-file=" + chf)
        if self.audio_url:
            cmd.append("--audio-file=" + self.audio_url)
        cmd.append(self.url)
        return cmd

    def on_event(self, ev):
        name = ev.get("event")
        if name == "end-file":
            self.end_reason = ev.get("reason") or ""
        elif name == "property-change":
            n, v = ev.get("name"), ev.get("data")
            with self.lock:
                if n == "time-pos" and isinstance(v, (int, float)):
                    self.pos, self.started = float(v), True
                elif n == "duration" and isinstance(v, (int, float)) and not self.live:
                    self.duration = float(v)
                elif n == "pause":
                    self.paused = bool(v)
                    self.dirty = True
                elif n == "speed" and isinstance(v, (int, float)):
                    self.speed = float(v)
                elif n == "chapter" and isinstance(v, int):
                    self.chapter = v
                elif n == "paused-for-cache":
                    self.buffering = bool(v)
                    self.dirty = True
                elif n == "sid" and self.pending_sub is not None and isinstance(v, int):
                    self.sub_sids[self.pending_sub] = v
                    self.pending_sub = None
        elif name == "client-message":
            args = ev.get("args") or []
            if len(args) >= 2 and args[0] == "tube":
                with self.lock:
                    self.keys.append(args[1])

    def play(self):
        for p in (SOCK,):
            try:
                os.remove(p)
            except OSError:
                pass
        log = open(os.path.join(APP_DIR, "mpv.log"), "w")
        proc = subprocess.Popen(self.cmdline(), stdout=log, stderr=log)
        ipc = None
        for _ in range(100):
            if proc.poll() is not None:
                break
            if os.path.exists(SOCK):
                try:
                    ipc = Ipc(SOCK, self.on_event)
                    break
                except OSError:
                    pass
            time.sleep(0.1)
        if ipc:
            self.ipc = ipc
            for i, prop in enumerate(["time-pos", "duration", "pause", "speed", "chapter", "paused-for-cache", "sid"], 1):
                ipc.cmd("observe_property", i, prop)
            if not self.settings.get("player_hints_shown"):
                self.mode, self.help_first = "help", True
                self.settings["player_hints_shown"] = True
                self.save()
            self.restore_subs()
            self.show_bar(4)
            was_visible = True
            last_draw = 0
            while proc.poll() is None and ipc.alive:
                with self.lock:
                    keys, self.keys = self.keys, []
                for k in keys:
                    self.last_key = time.time()
                    if self.dark:
                        self.set_dark(False)
                        self.show_bar()
                        continue
                    self.on_key(k)
                now = time.time()
                if self.sleep_at and now >= self.sleep_at:
                    self.sleep_at = 0
                    self.ipc.cmd("set_property", "pause", True)
                    self.set_dark(False)
                    self.toast(T("p_sleep_done"), 3)
                    self.draw()
                    time.sleep(2.5)
                    self.ipc.cmd("quit")
                if self.audio_only and not self.dark and self.mode == "play" and now - self.last_key > DARK_AFTER:
                    self.set_dark(True)
                visible = self.mode != "play" or self.pinned or now < self.bar_until or now < self.flash_until or self.paused or self.buffering
                if self.dirty or (visible and now - last_draw > 0.25) or (was_visible and not visible):
                    self.draw()
                    last_draw, self.dirty = now, False
                was_visible = visible
                time.sleep(0.04)
            ipc.close()
        self.set_dark(False)
        proc.wait()
        log.close()
        failed = not self.started and proc.returncode not in (0, 4)
        return self.pos, failed

    def set_dark(self, on):
        if on != self.dark:
            self.dark = on
            set_blank(on)

    def toggle_audio(self):
        if not self.can_video:
            self.toast(T("p_audio_file"))
            return
        self.audio_only = not self.audio_only
        self.ipc.cmd("set_property", "vid", "no" if self.audio_only else "auto")
        self.last_key = time.time()
        self.toast(T("p_audio_on") if self.audio_only else T("p_audio_off"), 2)

    def set_sleep(self, step):
        i = SLEEP_MINUTES.index(self.sleep_min) if self.sleep_min in SLEEP_MINUTES else 0
        self.sleep_min = SLEEP_MINUTES[(i + step) % len(SLEEP_MINUTES)]
        self.sleep_at = time.time() + self.sleep_min * 60 if self.sleep_min else 0
        self.toast(T("p_sleep") + ": " + self.sleep_label(), 1.5)

    def sleep_label(self):
        if not self.sleep_at:
            return T("off")
        return T("p_minutes", n=max(1, int((self.sleep_at - time.time() + 59) // 60)))

    def restore_subs(self):
        want = self.settings.get("sub_lang")
        if not want:
            return
        for i, t in enumerate(self.subs):
            if t["key"] == want:
                threading.Thread(target=self.select_sub, args=(i, False), daemon=True).start()
                return

    def select_sub(self, i, remember=True):
        if i < 0:
            self.ipc.cmd("set_property", "sid", "no")
            self.sub_idx = -1
            if remember:
                self.settings["sub_lang"] = None
                self.save()
            self.toast(T("p_subs_off"))
            return
        track = self.subs[i]
        if remember:
            self.settings["sub_lang"] = self.settings["sub_last"] = track["key"]
            self.save()
        if i in self.sub_sids:
            self.ipc.cmd("set_property", "sid", self.sub_sids[i])
            self.sub_idx = i
            self.toast(T("p_subs_on", name=track["name"]))
            return
        self.toast(T("p_subs_loading"), 30)
        try:
            path = fetch_sub(track)
        except Exception:
            self.toast(T("p_subs_failed"), 3)
            return
        self.pending_sub = i
        self.ipc.cmd("sub-add", path, "select", track["name"], track.get("lang", ""))
        self.sub_idx = i
        self.toast(T("p_subs_on", name=track["name"]))

    def toast(self, text, secs=1.5):
        self.flash, self.flash_until = text, time.time() + secs
        self.dirty = True

    def show_bar(self, secs=3):
        self.bar_until = time.time() + secs
        self.dirty = True

    def seek(self, delta):
        if self.live:
            self.ipc.cmd("seek", delta, "relative")
        else:
            self.ipc.cmd("seek", delta, "relative+exact" if abs(delta) < 30 else "relative")
        self.toast(("+" if delta > 0 else "−") + fmt_time(abs(delta)), 0.8)
        self.show_bar()

    def jump_chapter(self, step):
        if self.chapters and not self.live:
            self.ipc.cmd("add", "chapter", step)
            target = max(0, min(len(self.chapters) - 1, self.chapter + step))
            self.toast(self.chapters[target]["title"] or T("p_chapter_n", n=target + 1), 1.5)
            self.show_bar()
        else:
            self.seek(300 * step)

    def set_speed(self, step):
        i = min(range(len(SPEEDS)), key=lambda j: abs(SPEEDS[j] - self.speed))
        i = max(0, min(len(SPEEDS) - 1, i + step))
        self.speed = SPEEDS[i]
        self.ipc.cmd("set_property", "speed", self.speed)
        self.toast(T("p_speed") + ": " + fmt_speed(self.speed), 1)

    def toggle_subs(self):
        if not self.subs:
            self.toast(T("p_no_subs"))
            return
        if self.sub_idx >= 0:
            threading.Thread(target=self.select_sub, args=(-1,), daemon=True).start()
            return
        want = self.settings.get("sub_lang") or self.settings.get("sub_last")
        i = next((j for j, t in enumerate(self.subs) if t["key"] == want), 0)
        threading.Thread(target=self.select_sub, args=(i,), daemon=True).start()

    def menu_items(self):
        items = [("speed", T("p_speed"), fmt_speed(self.speed))]
        sub = self.subs[self.sub_idx]["name"] if self.sub_idx >= 0 else T("off")
        items.append(("subs", T("p_subtitles"), sub if self.subs else T("p_none")))
        if self.chapters and not self.live:
            cur = self.chapters[self.chapter]["title"] if 0 <= self.chapter < len(self.chapters) else ""
            items.append(("chapters", T("p_chapters"), cur or str(len(self.chapters))))
        items.append(("audio", T("p_audio_only"), T("on") if self.audio_only else T("off")))
        items.append(("sleep", T("p_sleep"), self.sleep_label()))
        items.append(("help", T("p_controls"), ""))
        items.append(("close", T("p_close"), ""))
        return items

    def list_items(self):
        if self.list_kind == "subs":
            return [T("off")] + [t["name"] for t in self.subs]
        if self.list_kind == "speed":
            return [fmt_speed(x) for x in SPEEDS]
        return [f"{fmt_time(c['start'])}  {c['title'] or T('p_chapter_n', n=i + 1)}" for i, c in enumerate(self.chapters)]

    def list_current(self):
        if self.list_kind == "subs":
            return self.sub_idx + 1
        if self.list_kind == "speed":
            return min(range(len(SPEEDS)), key=lambda j: abs(SPEEDS[j] - self.speed))
        return self.chapter

    def on_key(self, k):
        self.dirty = True
        if self.mode == "help":
            self.mode = "play"
            self.show_bar()
            return
        if self.mode == "menu":
            items = self.menu_items()
            self.menu_sel = min(self.menu_sel, len(items) - 1)
            kind = items[self.menu_sel][0]
            if k == "UP":
                self.menu_sel = (self.menu_sel - 1) % len(items)
            elif k == "DOWN":
                self.menu_sel = (self.menu_sel + 1) % len(items)
            elif k in ("LEFT", "RIGHT") and kind == "speed":
                self.set_speed(-1 if k == "LEFT" else 1)
            elif k in ("LEFT", "RIGHT", "A") and kind == "sleep":
                self.set_sleep(-1 if k == "LEFT" else 1)
            elif k in ("LEFT", "RIGHT", "A") and kind == "audio":
                self.toggle_audio()
            elif k in ("A", "RIGHT"):
                if kind == "close":
                    self.mode = "play"
                elif kind == "help":
                    self.mode = "help"
                elif kind == "subs" and not self.subs:
                    self.toast(T("p_no_subs"))
                elif kind in ("subs", "chapters", "speed"):
                    self.mode, self.list_kind = "list", kind
                    self.list_sel = max(0, self.list_current())
            elif k in ("B", "Y", "START"):
                self.mode = "play"
                self.show_bar()
            return
        if self.mode == "list":
            items = self.list_items()
            if k == "UP":
                self.list_sel = (self.list_sel - 1) % len(items)
            elif k == "DOWN":
                self.list_sel = (self.list_sel + 1) % len(items)
            elif k in ("L1", "LEFT"):
                self.list_sel = max(0, self.list_sel - 6)
            elif k in ("R1", "RIGHT"):
                self.list_sel = min(len(items) - 1, self.list_sel + 6)
            elif k == "A":
                if self.list_kind == "subs":
                    threading.Thread(target=self.select_sub, args=(self.list_sel - 1,), daemon=True).start()
                elif self.list_kind == "speed":
                    self.speed = SPEEDS[self.list_sel]
                    self.ipc.cmd("set_property", "speed", self.speed)
                else:
                    self.ipc.cmd("set_property", "chapter", self.list_sel)
                    self.show_bar()
                self.mode = "play"
            elif k == "B":
                self.mode = "menu"
            return
        if k == "A":
            self.ipc.cmd("cycle", "pause")
            self.show_bar()
        elif k == "B":
            self.ipc.cmd("quit")
        elif k == "LEFT":
            self.seek(-10)
        elif k == "RIGHT":
            self.seek(10)
        elif k == "UP":
            self.seek(60)
        elif k == "DOWN":
            self.seek(-60)
        elif k == "L1":
            self.jump_chapter(-1)
        elif k == "R1":
            self.jump_chapter(1)
        elif k == "X":
            self.toggle_subs()
        elif k == "Y":
            self.mode, self.menu_sel = "menu", 0
        elif k == "START":
            self.mode = "help"
        elif k == "SELECT":
            self.pinned = not self.pinned
            self.show_bar()

    def draw(self):
        a = Ass()
        now = time.time()
        if self.mode == "help":
            self.draw_help(a)
        else:
            if self.mode != "play" or self.pinned or now < self.bar_until or self.paused or self.buffering:
                self.draw_bar(a)
            if self.paused and self.mode == "play":
                a.rect(W // 2 - 40, 150, 80, 80, BLACK, "60", 40)
                a.rect(W // 2 - 15, 170, 10, 40, WHITE)
                a.rect(W // 2 + 5, 170, 10, 40, WHITE)
            elif self.buffering:
                a.text(W // 2, 190, T("p_buffering"), 18, WHITE, an=5)
            if now < self.flash_until and self.flash:
                tw = min(560, 24 + 11 * len(self.flash))
                a.rect(W // 2 - tw // 2, 40, tw, 40, BLACK, "50", 10)
                a.text(W // 2, 60, self.flash, 18, WHITE, an=5)
            if self.mode == "menu":
                self.draw_menu(a)
            elif self.mode == "list":
                self.draw_list(a)
        self.ipc.cmd("osd-overlay", 1, "ass-events", a.data(), W, H, 0, False, False)

    def draw_bar(self, a):
        top = 392
        a.rect(0, top, W, H - top, BLACK, "40")
        a.text(16, top + 10, self.title, 16, WHITE, bold=True)
        y = top + 44
        if self.live:
            a.rect(16, y - 2, 560, 4, ACCENT)
            a.rect(586, y - 9, 40, 18, RED, "00", 4)
            a.text(606, y, "LIVE", 11, WHITE, an=5, bold=True)
        else:
            dur = self.duration or 1
            frac = max(0.0, min(1.0, self.pos / dur))
            a.rect(16, y - 2, 608, 4, "5A5A5A")
            a.rect(16, y - 2, int(608 * frac), 4, ACCENT)
            for ch in self.chapters[1:]:
                cx = 16 + int(608 * min(1.0, ch["start"] / dur))
                a.rect(cx - 1, y - 2, 2, 4, BLACK)
            kx = 16 + int(608 * frac)
            a.rect(kx - 6, y - 6, 12, 12, ACCENT, "00", 6)
        line = T("p_live") if self.live else f"{fmt_time(self.pos)} / {fmt_time(self.duration)}"
        if 0 <= self.chapter < len(self.chapters) and not self.live:
            line += "  ·  " + (self.chapters[self.chapter]["title"] or T("p_chapter_n", n=self.chapter + 1))
        a.text(16, top + 56, line, 13, GREY)
        right = []
        if self.audio_only:
            right.append(T("p_audio_short"))
        if self.sleep_at:
            right.append(T("p_sleep_short", t=self.sleep_label()))
        if abs(self.speed - 1.0) > 0.01:
            right.append(fmt_speed(self.speed))
        if self.sub_idx >= 0:
            right.append("CC " + self.subs[self.sub_idx]["name"])
        right.append("Y " + T("p_menu"))
        a.text(624, top + 56, "  ·  ".join(right), 13, GREY, an=9)

    def panel(self, a, title, rows, sel, values=None, current=None):
        n = len(rows)
        vis = min(n, 7)
        first = max(0, min(sel - 3, n - vis))
        pw, rh = 420, 38
        ph = 60 + vis * rh
        px, py = (W - pw) // 2, max(20, (380 - ph) // 2)
        a.rect(px, py, pw, ph, "181818", "10", 14)
        a.text(px + 20, py + 16, title, 17, WHITE, bold=True)
        for i in range(first, first + vis):
            y = py + 48 + (i - first) * rh
            on = i == sel
            if on:
                a.rect(px + 10, y, pw - 20, rh - 4, "F1F1F1", "00", 8)
            color = "0F0F0F" if on else WHITE
            mark = "● " if current is not None and i == current else "   "
            a.text(px + 22, y + 9, mark + rows[i], 15, color)
            if values and values[i]:
                v = values[i]
                if i == sel and title == T("p_menu_title") and self.menu_items()[i][0] in ("speed", "sleep", "audio"):
                    v = "◀ " + v + " ▶"
                a.text(px + pw - 22, y + 9, v, 14, "333333" if on else GREY, an=9)
        if n > vis:
            a.text(px + pw - 20, py + 16, f"{sel + 1}/{n}", 12, GREY, an=9)

    def draw_menu(self, a):
        items = self.menu_items()
        self.menu_sel = min(self.menu_sel, len(items) - 1)
        self.panel(a, T("p_menu_title"), [i[1] for i in items], self.menu_sel, [i[2] for i in items])

    def draw_list(self, a):
        titles = {"subs": T("p_subtitles"), "speed": T("p_speed"), "chapters": T("p_chapters")}
        self.panel(a, titles[self.list_kind], self.list_items(), self.list_sel, current=self.list_current())

    def draw_help(self, a):
        a.rect(0, 0, W, H, "0F0F0F", "18")
        a.text(W // 2, 34, T("p_controls"), 22, WHITE, an=5, bold=True)
        rows = [("A", T("h_pause")), ("B", T("h_exit")), ("◀ ▶", T("h_seek10")), ("▲ ▼", T("h_seek60")),
                ("L1 R1", T("h_chapters")), ("X", T("h_subs")), ("Y", T("h_menu")),
                ("SELECT", T("h_pin")), ("START", T("h_help"))]
        y = 72
        for key, desc in rows:
            kw = max(30, 12 + 10 * len(key))
            a.rect(150 - kw, y, kw, 26, "F1F1F1", "00", 13 if len(key) == 1 else 6)
            a.text(150 - kw // 2, y + 13, key, 13, "0F0F0F", an=5, bold=True)
            a.text(166, y + 4, desc, 15, WHITE)
            y += 36
        a.text(W // 2, H - 40, T("h_any_key"), 14, GREY, an=5)
