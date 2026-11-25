import glob, os, queue, shutil, socket, subprocess, threading, time, urllib.request

import pygame

from i18n import T

APP_DIR = os.path.dirname(os.path.abspath(__file__))
CACHE_DIR = os.path.join(APP_DIR, "cache", "thumbs")


class Thumbs:

    def __init__(self, url_for):
        os.makedirs(CACHE_DIR, exist_ok=True)
        self.url_for = url_for
        self.images = {}
        self.requested = set()
        self.q = queue.Queue()
        self.need_bmp = not pygame.image.get_extended()
        threading.Thread(target=self._worker, daemon=True).start()

    def _path(self, vid):
        return os.path.join(CACHE_DIR, vid + (".bmp" if self.need_bmp else ".jpg"))

    def _worker(self):
        while True:
            vid = self.q.get()
            jpg = os.path.join(CACHE_DIR, vid + ".jpg")
            try:
                if not os.path.exists(jpg):
                    with urllib.request.urlopen(self.url_for(vid), timeout=8) as r:
                        data = r.read()
                    with open(jpg + ".part", "wb") as f:
                        f.write(data)
                    os.replace(jpg + ".part", jpg)
                if self.need_bmp:
                    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", jpg,
                                    self._path(vid)], timeout=20)
            except Exception:
                pass

    def fetch(self, vid):
        if vid not in self.requested:
            self.requested.add(vid)
            self.q.put(vid)

    def get(self, vid, w, h):
        key = (vid, w, h)
        if key in self.images:
            return self.images[key]
        path = self._path(vid)
        if os.path.exists(path):
            try:
                img = pygame.transform.smoothscale(pygame.image.load(path), (w, h))
                self.images[key] = img
                return img
            except pygame.error:
                return None
        self.fetch(vid)
        return None


class Downloader:

    def __init__(self, store, youtube, thumbs, notify):
        self.store, self.yt, self.thumbs, self.notify = store, youtube, thumbs, notify
        self.wake = threading.Event()
        self.current = None
        self.cancel_id = None
        threading.Thread(target=self._worker, daemon=True).start()
        self.wake.set()

    def _next(self):
        for d in self.store.downloads:
            if d["status"] == "queued":
                return d
        return None

    def _worker(self):
        while True:
            self.wake.wait(10)
            self.wake.clear()
            while True:
                d = self._next()
                if not d or not is_online():
                    break
                d["status"], d["progress"] = "loading", 0
                self.current, self.cancel_id = d["id"], None
                self.store.save()
                self.thumbs.fetch(d["id"])
                folder = self.store.settings["dl_dir"]
                try:
                    path, extra = self.yt.download(d["id"], folder, d.get("quality", "360p"),
                                            lambda p, d=d: d.__setitem__("progress", p),
                                            lambda vid=d["id"]: self.cancel_id == vid)
                    d["file"] = path
                    d["chapters"], d["subs"] = extra["chapters"], extra["subs"]
                    d["audio"] = bool(extra.get("audio"))
                    d["size"] = os.path.getsize(path) if os.path.exists(path) else 0
                    d["status"], d["progress"] = "done", 1.0
                    self.notify(T("dl_done", title=d["title"]), "ok")
                except Exception as e:
                    if self.cancel_id == d["id"] or isinstance(e, self.yt.Cancelled):
                        self.yt.remove_partial(d["id"], folder)
                        self.store.remove_download(d["id"])
                        self.notify(T("dl_cancelled"))
                        continue
                    if self.store.find_download(d["id"]) is None:
                        continue
                    d["status"] = "error"
                    self.notify(T("dl_failed", err=str(e)[:60]), "error")
                finally:
                    self.current = self.cancel_id = None
                self.store.save()

    def kick(self):
        self.wake.set()

    def cancel(self, video_id):
        if self.current == video_id:
            self.cancel_id = video_id
        else:
            self.store.remove_download(video_id)


_online = {"value": True}


def check_online():
    try:
        socket.create_connection(("www.youtube.com", 443), timeout=3).close()
        _online["value"] = True
    except OSError:
        _online["value"] = False
    return _online["value"]


def is_online():
    return _online["value"]


def start_network_monitor(period=15):
    def loop():
        while True:
            check_online()
            time.sleep(period)
    threading.Thread(target=loop, daemon=True).start()


_battery = {"value": None, "checked": 0}


def battery_level():
    now = time.time()
    if now - _battery["checked"] < 10:
        return _battery["value"]
    _battery["checked"] = now
    _battery["value"] = _read_battery()
    return _battery["value"]


def _read_battery():
    for path in glob.glob("/sys/class/power_supply/*/capacity"):
        try:
            with open(path) as f:
                return int(f.read().strip())
        except (OSError, ValueError):
            continue
    return None


def free_space(path):
    try:
        os.makedirs(path, exist_ok=True)
        return shutil.disk_usage(path).free
    except OSError:
        return 0
