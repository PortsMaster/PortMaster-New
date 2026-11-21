import array, math, os

import pygame

RATE = 22050
VOLUME = 0.22

SHAPES = {
    "move":    [(1900, 1700, 14)],
    "confirm": [(1200, 1200, 22), (1800, 1800, 30)],
    "back":    [(1500, 1500, 22), (1000, 1000, 30)],
    "error":   [(240, 220, 90), (0, 0, 40), (240, 220, 110)],
}


def _tone(f0, f1, ms):
    n = int(RATE * ms / 1000)
    out, phase = [], 0.0
    for i in range(n):
        t = i / max(1, n - 1)
        f = f0 + (f1 - f0) * t
        phase += 2 * math.pi * f / RATE
        env = min(1.0, i / (RATE * 0.003)) * (1 - t) ** 1.5
        out.append(math.sin(phase) * env if f else 0.0)
    return out


def prepare_env():
    if not os.environ.get("XDG_RUNTIME_DIR") and os.path.exists("/var/run/pipewire-0"):
        os.environ["XDG_RUNTIME_DIR"] = "/var/run"
    pygame.mixer.pre_init(RATE, -16, 1, 512)


class Sounds:
    def __init__(self, enabled=True):
        self.enabled = enabled
        self.sounds = {}
        self.start()

    def start(self):
        self.sounds = {}
        try:
            if not pygame.mixer.get_init():
                pygame.mixer.init(RATE, -16, 1, 512)
            freq, size, channels = pygame.mixer.get_init()
            for name, parts in SHAPES.items():
                samples = []
                for f0, f1, ms in parts:
                    samples += _tone(f0, f1, ms)
                pcm = array.array("h", (int(max(-1, min(1, x * VOLUME)) * 32767) for x in samples))
                if channels == 2:
                    pcm = array.array("h", (v for x in pcm for v in (x, x)))
                self.sounds[name] = pygame.mixer.Sound(buffer=pcm.tobytes())
        except Exception:
            self.sounds = {}

    def stop(self):
        try:
            if pygame.mixer.get_init():
                pygame.mixer.stop()
                pygame.mixer.quit()
        except Exception:
            pass
        self.sounds = {}

    def play(self, name):
        if self.enabled and name in self.sounds:
            try:
                self.sounds[name].play()
            except Exception:
                pass
