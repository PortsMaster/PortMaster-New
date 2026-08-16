#!/usr/bin/env python3
# Tiny receiver: the PC pushes Claude usage JSON here; the widget reads the file.
# It also appends one sample per distinct push to a history log, which is what
# widget.py's TREND panel and runner.py's whole game are built on.
import http.server
import json
import os
import time

DATA = os.environ.get("RUNNER_DATA", "/tmp/claude_usage.json")
# History lives at the legacy carousel path if one is already there, else next
# to this script; RUNNER_HIST overrides both (the PortMaster launcher sets it).
_LEGACY_HIST = "/roms/tools/claude/usage_hist.jsonl"
HIST = os.environ.get("RUNNER_HIST") or (
    _LEGACY_HIST if os.path.exists(_LEGACY_HIST)
    else os.path.join(os.path.dirname(os.path.abspath(__file__)),
                      "usage_hist.jsonl"))
HIST_MAX = 12000  # lines; trimmed from the front on startup
HEARTBEAT = 600   # log an unchanged sample at least this often, so gaps show

_last = [None, 0.0]  # last (fh, sd, fb, rl) logged, and when


def trim_hist():
    try:
        with open(HIST) as f:
            lines = f.readlines()
    except OSError:
        return
    if len(lines) <= HIST_MAX:
        return
    tmp = HIST + ".tmp"
    try:
        with open(tmp, "w") as f:
            f.writelines(lines[-HIST_MAX:])
        os.replace(tmp, HIST)
    except OSError:
        pass


def log_hist(body):
    """Append {t, fh, sd, fb} for this push. The pusher repeats the same numbers
    every 60s between API fetches, so only changes are logged - plus a heartbeat
    line every HEARTBEAT seconds, which is what makes real gaps (PC asleep)
    distinguishable from a flat window.

    Timestamps are device time, not the PC's `epoch` field: the readers compare
    them against their own time.time(), so a skewed device clock has to be
    consistently wrong rather than half-wrong."""
    try:
        d = json.loads(body)
    except ValueError:
        return
    key = (int(d.get("five_hour_pct", 0)), int(d.get("seven_day_pct", 0)),
           int(d.get("fable_pct", 0)), int(bool(d.get("rl"))))
    now = time.time()
    if key == _last[0] and now - _last[1] < HEARTBEAT:
        return
    _last[0], _last[1] = key, now
    rec = {"t": int(now), "fh": key[0], "sd": key[1], "fb": key[2]}
    if key[3]:
        rec["rl"] = 1
    try:
        os.makedirs(os.path.dirname(HIST), exist_ok=True)
        with open(HIST, "a") as f:
            f.write(json.dumps(rec, separators=(",", ":")) + "\n")
    except OSError:
        pass


class H(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        n = int(self.headers.get("content-length", 0))
        body = self.rfile.read(n)
        with open(DATA, "wb") as f:
            f.write(body)
        log_hist(body)
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"ok")

    def do_GET(self):
        try:
            with open(DATA, "rb") as f:
                body = f.read()
            self.send_response(200)
        except OSError:
            body = b"{}"
            self.send_response(404)
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *a):
        pass


trim_hist()
try:
    srv = http.server.HTTPServer(("0.0.0.0", 8788), H)
except OSError:
    # Another receiver (a second install, or pocket-clawd's netd) already owns
    # the port; whoever got there first writes DATA for everyone.
    raise SystemExit(0)
srv.serve_forever()
