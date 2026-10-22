#!/usr/bin/env python3

import array
import ctypes
import gc
import json
import math
import os
import random
import signal
import struct
import sys
import tempfile
import time
from dataclasses import dataclass
from pathlib import Path


WIDTH = 640
HEIGHT = 480
FRAME_STEP = 1.0 / 60.0
SLEEP_FRAME_STEP = 1.0 / 15.0
BEHAVIOUR_STEP = 1.0 / 120.0
FORM_PALETTE = (
    (0, 255, 236),
    (204, 0, 255),
    (255, 0, 206),
    (33, 255, 37),
    (255, 252, 2),
)
EYE_GRADIENT_FADE = 0.08
EYE_SAMPLES = 44
EYE_COLUMNS = tuple(math.sin(math.pi * (index / EYE_SAMPLES - 0.5))
                    for index in range(EYE_SAMPLES + 1))
OPEN_LID = (0.0, 0.0, 0.0)
IDENTITY_VERSION = 1
DEFAULT_IDENTITY = {
    "version": IDENTITY_VERSION,
    "pitch": 470.0,
    "body": 1.0,
    "breathiness": 0.0,
    "vibrato": 6.0,
    "eye_width": 1.0,
    "eye_height": 1.0,
    "eye_spacing": 0.0,
    "eye_shape": 4.0,
    "blink": 1.0,
    "colour": 0,
}


def roll_identity(rng):
    return {
        "version": IDENTITY_VERSION,
        "pitch": round(470.0 * 2.0 ** (rng.uniform(-3.0, 3.0) / 12.0), 1),
        "body": round(rng.uniform(0.92, 1.08), 3),
        "breathiness": round(rng.uniform(0.0, 0.05), 3),
        "vibrato": round(rng.uniform(5.0, 7.0), 2),
        "eye_width": round(rng.uniform(0.94, 1.06), 3),
        "eye_height": round(rng.uniform(0.94, 1.06), 3),
        "eye_spacing": round(rng.uniform(-12.0, 12.0), 1),
        "eye_shape": round(rng.uniform(3.6, 4.6), 2),
        "blink": round(rng.uniform(0.85, 1.2), 3),
        "colour": rng.randrange(len(FORM_PALETTE)),
    }


MEMORY_VERSION = 1
MEMORY_SAVE_INTERVAL = 120.0
IRRITATION_HALF_LIFE = 1800.0
MOOD_HALF_LIFE = 21600.0
FAMILIARITY_HOURS = 3.0
FAMILIARITY_HALF_LIFE = 45 * 86400.0
FAMILIARITY_FLOOR = 0.25
UNKNOWN_AWAY = 7200.0
CLOCK_TRUSTED_FROM = 1790812800.0
CLOCK_RAN_MARGIN = 120.0
RESET_BUTTONS = frozenset((4, 5, 13))
RESET_FORGET_TIME = 5.0
RESET_NEW_TIME = 10.0
FIRST_MEETING_SLOWNESS = 2.2
FAMILIARITY_KNOWN = 0.15
FAMILIARITY_CLOSE = 0.4
WAKE_SLOWNESS = {"first": FIRST_MEETING_SLOWNESS, "brief": 0.6, "short": 1.0,
                 "long": 1.5, "sulk": 1.5}
SULK_POKES = 2
SULK_PATIENCE = 20.0


REPAINT_HOLD = 0.8
REPAINT_REPEAT = 1.0

STROKE_AFTER = 0.6
PURR_INTERVAL = (2.2, 3.4)
RHYTHM_GAP = (0.10, 0.9)
RHYTHM_END = 0.75
RHYTHM_MAX = 8

DREAM_FIRST = (25.0, 45.0)
DREAM_BETWEEN = (40.0, 80.0)
DREAM_LENGTH = (6.0, 12.0)
DREAM_HUSH = 0.45
SEEK_STAGES = (0.45, 0.70, 0.92)

BODY_POLL_INTERVAL = 30.0
LOW_BATTERY = 20
DEVICE_SLEEP_NOTICED = 20.0


def battery_state(root="/sys/class/power_supply"):
    try:
        supplies = sorted(Path(root).iterdir())
    except OSError:
        return None
    for supply in supplies:
        try:
            if (supply / "type").read_text(encoding="ascii").strip().lower() != "battery":
                continue
            capacity = int((supply / "capacity").read_text(encoding="ascii").strip())
            status = (supply / "status").read_text(encoding="ascii").strip().lower()
        except (OSError, ValueError):
            continue
        return max(0, min(100, capacity)), status in ("charging", "full")
    return None


def night_tiredness(hour):
    if hour >= 22.0 or hour < 6.0:
        return 0.6
    if hour >= 21.0:
        return 0.6 * (hour - 21.0)
    if hour < 8.0:
        return 0.3 * (8.0 - hour) / 2.0
    return 0.0


def choose_greeting(away, certain, familiarity, first, ended_asleep):
    if first or away is None:
        return "first"
    if certain and away > 3 * 86400 and familiarity >= FAMILIARITY_KNOWN:
        return "sulk"
    if not certain or away > 3 * 3600 or ended_asleep:
        return "long"
    if away > 600:
        return "short"
    return "brief"


def describe_duration(seconds):
    if seconds < 90:
        return "%d seconds" % seconds
    if seconds < 5400:
        return "%d minutes" % round(seconds / 60)
    if seconds < 172800:
        return "%.1f hours" % (seconds / 3600)
    return "%.1f days" % (seconds / 86400)


def boot_id():
    try:
        return Path("/proc/sys/kernel/random/boot_id").read_text(encoding="ascii").strip()
    except OSError:
        return None


def boot_clock():
    try:
        return time.clock_gettime(time.CLOCK_BOOTTIME)
    except (AttributeError, OSError):
        return None


def time_away(memory, now, current_boot, since_boot):
    last = memory.get("last_seen")
    if last is None:
        return None, True, None
    if (current_boot and memory.get("boot_id") == current_boot and
            since_boot is not None and memory.get("boot_seen") is not None):
        return max(0.0, since_boot - float(memory["boot_seen"])), True, None
    gap = now - float(last)
    clock_sane = now >= CLOCK_TRUSTED_FROM and gap >= 0.0
    if current_boot and memory.get("boot_id") and since_boot is not None:
        if clock_sane and gap > since_boot + CLOCK_RAN_MARGIN:
            return gap, True, True
        return max(since_boot, UNKNOWN_AWAY), False, False
    if clock_sane:
        return gap, True, True
    return UNKNOWN_AWAY, False, False


def fresh_memory():
    return {"version": MEMORY_VERSION, "last_seen": None, "boot_id": None,
            "boot_seen": None, "clock_ok": None, "comfort": 0.72,
            "irritation": 0.0, "curiosity": 0.62, "interest": 0.45,
            "familiarity": 0.0, "visits": 0, "time_together": 0.0, "spot": None,
            "ended_asleep": False}


def write_json(path, data):
    try:
        path.parent.mkdir(parents=True, exist_ok=True)
        handle, temporary = tempfile.mkstemp(prefix="momo_", suffix=".tmp",
                                             dir=str(path.parent))
        with os.fdopen(handle, "w", encoding="utf8") as stream:
            json.dump(data, stream, indent=1)
            stream.write("\n")
        os.replace(temporary, path)
    except OSError:
        pass


_EYE_PROFILES = {}


def eye_profile(shape):
    profile = _EYE_PROFILES.get(shape)
    if profile is None:
        profile = tuple(max(0.0, 1.0 - abs(column) ** shape) ** (1.0 / shape)
                        for column in EYE_COLUMNS)
        _EYE_PROFILES[shape] = profile
    return profile

BLINK_INTERVAL = (3.0, 8.5)
DOUBLE_BLINK_CHANCE = 0.11
IDLE_SLEEPY = 48.0
IDLE_ASLEEP = 92.0
SLEEP_CLOSE_TIME = 5.0
VIEWER_NOTICE_CHANCE = 0.045
ASYMMETRY_RANGE = 0.055
STIMULUS_COALESCE_WINDOW = 0.20
STIMULUS_MAX_WINDOW = 0.42
STIMULUS_STALE_AFTER = 2.4
STIMULUS_DECAY = 0.25
ATTENTION_ACCUMULATION = 0.34
IRRITATION_ACCUMULATION = 0.18
IRRITATION_DECAY = 0.035
CURIOSITY_RECOVERY = 0.025
COMFORT_RECOVERY = 0.020
INTEREST_DECAY = 0.014
EXPRESSION_INTENSITY = 0.13
LID_SPEED = 9.0
LID_SOFTNESS = 9.0
LID_BLINK_CHANGE = 0.2
GAZE_PIXELS_X = 46.0
GAZE_PIXELS_Y = 34.0
SACCADE_BASE = 0.055
SACCADE_PER_PIXEL = 0.0017
SACCADE_OVERSHOOT = 0.04
SACCADE_SETTLE = 0.14
GLIDE_BELOW_SPEED = 4.0
BREATH_PERIOD = 4.2
BREATH_SWELL = 0.012
BREATH_LIFT = 1.2
MICRO_INTERVAL = (1.5, 4.0)
MICRO_SIZE = (0.6, 1.3)
MICRO_LIMIT = 2.0
MICRO_DURATION = 0.07
DRIFT_SPEED = 0.0
STRETCH_PER_PIXEL_SPEED = 0.00009
STRETCH_LIMIT = 0.07
LOOK_BLINK_PIXELS = 30.0
LOOK_BLINK_CHANCE = 0.45
PLATFORM = os.environ.get("MOMO_PLATFORM", "arkos")
PORTMASTER = PLATFORM == "portmaster"
HANDHELD = PLATFORM in ("arkos", "portmaster")
POWER_POLL_INTERVAL = 1.0
REACTION_DELAY = (0.10, 0.38)
REACTIVE_GAZE_DURATION = (0.95, 1.75)
IDLE_GAZE_DURATION = (1.25, 2.35)
CENTRED_REST_DURATION = (2.8, 6.2)
AUTONOMOUS_REST_DURATION = (3.4, 7.8)
WAKE_LOCK_TIME = 1.95
INTENTION_MINIMUM_LIFETIME = 1.25
CHAOS_INPUT_COUNT = 8
CHAOS_IGNORE_TIME = 3.2
CONTACT_RESPONSE_WINDOW = 4.8
MICRO_BEHAVIOUR_PROBABILITY = 0.16
IDLE_VOCALISATION_PROBABILITY = 0.46
VOCALISATION_PROBABILITY = 0.34
VOCAL_DELAY = (0.32, 0.78)
VOCAL_COOLDOWN = 1.35
AUDIO_RATE = 24000
AUDIO_CHANNELS = 1
AUDIO_FRAME_BYTES = 2
WAVE_SIZE = 2048
CONTROL_BLOCK = 32
VOICE_DRIVE = 1.8 if HANDHELD else 0.45
VOICE_CEILING = 0.95
VOWELS = {
    "a": (1100.0, 1800.0),
    "e": (650.0, 2700.0),
    "i": (420.0, 3200.0),
    "o": (700.0, 1150.0),
    "u": (450.0, 950.0),
    "m": (380.0, 1400.0),
}
FORMANT_BANDWIDTH = (130.0, 200.0)
VOWEL_OPENNESS = {"a": 1.0, "o": 0.7, "u": 0.3, "e": 0.0, "i": -0.4, "m": -0.3}
SPEECH_SWELL = 0.05
SPEECH_WIDEN = 0.025
SPEECH_LIFT = 1.6
SPEECH_PITCH_LIFT = 0.35
SPEECH_LEAD = 0.03
VOICE_DETAIL_SPEED = (2.8, 2.0)
AUDIO_LEAD = 0.045
VOICE_INTERRUPT_FADE = 0.020
VOICE_FADE_STEPS = 8
VOICE_VARIATIONS = 2
VOICE_INTENTS = ("acknowledge", "notice", "question", "pleased", "curious",
                 "startled", "protest", "mutter", "sleepy", "wake",
                 "click", "squeak", "chatter", "residue", "flutter",
                 "idle_breath", "idle_pop", "idle_chime", "idle_ripple",
                 "purr", "echo")
PHRASE_INTENTS = tuple("phrase_" + intent for intent in
                       ("acknowledge", "notice", "question", "pleased", "curious",
                        "startled", "protest", "mutter", "sleepy", "wake"))
PHRASE_FOR_INTENT = {intent[7:]: intent for intent in PHRASE_INTENTS}
VOICE_PHRASE_INTERVALS = (3, 2, 4)
VOICE_CHARACTER = {
    "acknowledge": "hum", "notice": "call", "question": "call", "pleased": "song",
    "curious": "call", "startled": "yelp", "protest": "growl", "mutter": "babble",
    "sleepy": "sigh", "wake": "song", "click": "tick", "squeak": "yelp",
    "chatter": "babble", "residue": "hum", "flutter": "song", "idle_breath": "sigh",
    "idle_pop": "tick", "idle_chime": "hum", "idle_ripple": "hum",
    "purr": "purr", "echo": "song",
}
VOCAL_FAMILIES = {
    "acknowledge": ("acknowledge", "click", "flutter", "squeak"),
    "notice": ("notice", "click", "residue", "curious"),
    "question": ("question", "flutter", "chatter"),
    "pleased": ("pleased", "squeak", "flutter", "chatter"),
    "curious": ("curious", "residue", "click"),
    "startled": ("startled", "squeak", "click"),
    "protest": ("protest", "mutter", "residue", "click"),
    "mutter": ("mutter", "residue", "click", "chatter"),
    "sleepy": ("sleepy", "mutter", "residue"),
    "wake": ("wake", "flutter", "squeak", "notice"),
    "click": ("click", "flutter"),
    "squeak": ("squeak", "flutter"),
    "chatter": ("chatter", "residue"),
    "residue": ("residue", "flutter"),
    "flutter": ("flutter", "squeak"),
    "idle_breath": ("idle_breath", "idle_chime"),
    "idle_pop": ("idle_pop", "idle_breath"),
    "idle_chime": ("idle_chime", "idle_ripple"),
    "idle_ripple": ("idle_ripple", "idle_breath"),
    "purr": ("purr",),
    "echo": ("echo",),
}

def clamp(value, low=0.0, high=1.0):
    return max(low, min(high, value))


def approach(current, target, speed, elapsed):
    amount = 1.0 - math.exp(-speed * elapsed)
    return current + (target - current) * amount


def smoothstep(value):
    value = clamp(value)
    return value * value * (3.0 - 2.0 * value)


def build_source():
    table = []
    for index in range(WAVE_SIZE):
        angle = math.tau * index / WAVE_SIZE
        table.append(sum(math.sin(angle * number) / number ** 1.4
                         for number in range(1, 11)))
    peak = max(abs(value) for value in table)
    return [value / peak for value in table]


SOURCE_TABLE = build_source()


NEUTRAL_MOOD = {"valence": 0.3, "arousal": 0.2, "sleepy": 0.0, "irritation": 0.0}


def compose_utterance(intent, rng, mood=None):
    phrase = intent.startswith("phrase_")
    base = intent[7:] if phrase else intent
    mood = mood or NEUTRAL_MOOD
    valence, arousal = mood["valence"], mood["arousal"]
    sleepy, irritation = mood["sleepy"], mood["irritation"]
    lift = 1.8 * max(0.0, valence) - 2.5 * irritation - 3.0 * sleepy
    tempo = 1.0 + 0.3 * arousal - 0.35 * sleepy
    spread = 1.0 + 0.4 * arousal + 0.25 * max(0.0, valence) - 0.45 * sleepy
    rasp = 0.15 * irritation + 0.2 * sleepy
    sag = 2.5 * sleepy
    extra = int(max(0.0, valence) + arousal > 1.0 and rng.random() < 0.6)
    hush = mood.get("hush", 1.0)
    shift = rng.uniform(-1.5, 1.5) + lift
    syllables = []
    cursor = [0.0]

    def say(duration, start, end, vowels, loudness=1.0, breath=0.06, voicing=1.0,
            scoop=0.0, burst=0.0, vibrato=0.0, gap=0.025):
        duration *= rng.uniform(0.85, 1.2) / tempo
        wobble = rng.uniform(-0.6, 0.6)
        syllables.append((cursor[0], duration, start * spread + shift + wobble,
                          end * spread + shift + wobble - sag, vowels[0], vowels[-1],
                          loudness * rng.uniform(0.9, 1.05) * hush, breath + rasp, voicing,
                          scoop, burst, vibrato))
        cursor[0] += (duration + gap * rng.uniform(0.6, 1.4)) / tempo

    def vowel():
        return rng.choice("aeiou")

    if base == "acknowledge":
        say(0.13, 0, -1, "mu", 0.8)
    elif base == "notice":
        say(0.15, -1, 2, "oa", burst=0.3)
    elif base == "question":
        say(0.11, -2, -1, "uu", 0.8)
        say(0.20, 0, 6, "ei", vibrato=0.6)
    elif base == "pleased":
        for step in range(rng.choice((2, 3)) + extra):
            say(0.09, 3 + step * 2, 5 + step * 2, rng.choice(("ii", "ai", "ea")),
                burst=0.25, gap=0.015)
    elif base == "curious":
        say(0.22, -1, 4, "ui", scoop=1.0)
    elif base == "startled":
        say(0.08, 9, 5, "ie", 1.1, burst=0.6)
    elif base == "protest":
        say(0.13, 0, -2, "ma", breath=0.2, burst=0.4)
        say(0.20, -2, -6, "ao", breath=0.2)
    elif base == "mutter":
        for _ in range(rng.randint(3, 5)):
            pitch = rng.uniform(-6, -2)
            say(rng.uniform(0.05, 0.09), pitch, pitch + rng.uniform(-1, 1),
                rng.choice(("mo", "ou", "em", "uo")), 0.5, breath=0.15, gap=0.02)
    elif base == "sleepy":
        say(0.50, 0, -6, "au", 0.7, breath=0.3)
    elif base == "wake":
        say(0.12, -4, -2, "mu", 0.7)
        say(0.32, -2, 5, "ua", 0.75, vibrato=0.5)
    elif base == "click":
        say(0.045, 13, 10, "ie", 1.0, voicing=0.9, burst=0.25)
    elif base == "squeak":
        say(0.07, 12, 15, "ii", 0.7)
    elif base == "chatter":
        for _ in range(rng.randint(3, 6) + extra):
            pitch = rng.uniform(0, 8)
            say(rng.uniform(0.045, 0.075), pitch, pitch + rng.uniform(-2, 2),
                vowel() + vowel(), 0.7, burst=rng.choice((0.0, 0.3)), gap=0.015)
    elif base == "residue":
        say(0.12, -3, -5, "mm", 0.45, breath=0.15)
    elif base == "flutter":
        for step in range(rng.choice((2, 3)) + extra):
            say(0.05, (4, 7)[step % 2], (5, 6)[step % 2], "ie", 0.6, gap=0.01)
    elif base == "idle_breath":
        if rng.random() < 0.5:
            say(0.35, 0, 0, "ie", 0.4, breath=1.0, voicing=0.0, gap=0.08)
        say(0.60, 0, 0, "ao", 0.6, breath=1.0, voicing=0.0)
    elif base == "idle_pop":
        say(0.05, 5, 3, "uo", 0.9, voicing=0.9, burst=0.2)
    elif base == "idle_chime":
        say(0.30, 7, 7, "mu", 0.45, vibrato=1.0)
    elif base == "purr":
        for _ in range(rng.randint(6, 9)):
            say(0.07, -9, -8.5, "mm", 0.35, breath=0.25, gap=0.0)
    elif base == "echo":
        onsets = mood.get("rhythm") or (0.0, 0.25, 0.5)
        pitch = rng.uniform(2.0, 5.0)
        for index, onset in enumerate(onsets):
            cursor[0] = onset
            following = onsets[index + 1] - onset if index + 1 < len(onsets) else 0.2
            say(min(0.11, following * 0.6), pitch, pitch + 0.5,
                rng.choice(("ii", "ie", "ei")), 0.75, burst=0.2, gap=0.0)
            pitch = clamp(pitch + rng.choice((-3.0, -2.0, 2.0, 3.0)), -2.0, 9.0)
        if rng.random() < 0.3:
            cursor[0] = onsets[-1] + 0.2
            say(0.12, pitch + 2, pitch + 6, "ia", 0.7)
    else:
        for _ in range(rng.choice((2, 3))):
            pitch = rng.uniform(2, 5)
            say(0.08, pitch, pitch + 1, "mu", 0.4, gap=0.03)
    if phrase:
        last = (syllables[-1][3] - shift + sag) / spread
        say(0.10, last - 2, last - 4, "mm", 0.4, breath=0.12)
    return syllables


def resonator(frequency, bandwidth, rate):
    radius = math.exp(-math.pi * bandwidth / rate)
    angle = math.tau * min(frequency, rate * 0.45) / rate
    gain = (1.0 - radius) * math.sqrt(1.0 - 2.0 * radius * math.cos(2.0 * angle) +
                                      radius * radius)
    return gain, 2.0 * radius * math.cos(angle), radius * radius


class VoiceStream:

    def __init__(self, intent, variation=0, rate=AUDIO_RATE, detail=2, seed=None,
                 mood=None, identity=None):
        self.intent = intent
        identity = identity or DEFAULT_IDENTITY
        self.home_pitch = identity["pitch"]
        self.body = identity["body"]
        self.breathiness = identity["breathiness"]
        self.vibrato_rate = identity["vibrato"]
        self.rate = rate
        self.detail = detail
        self.random = random.Random(seed)
        self.syllables = [
            (int(start * rate), max(1, int(duration * rate))) + tuple(rest)
            for start, duration, *rest in compose_utterance(intent, self.random, mood)
        ]
        last = max(begin + length for begin, length, *_ in self.syllables)
        self.total = last + int(0.18 * rate)
        self.position = 0
        self.cache = bytearray()
        self.phase = 0.0
        self.low = [0.0, 0.0]
        self.high = [0.0, 0.0]
        self.room_a = [0.0] * int(0.031 * rate)
        self.room_b = [0.0] * int(0.043 * rate)
        self.room_a_index = self.room_b_index = 0
        self.fade_out = int(0.02 * rate)

    @property
    def done(self):
        return self.position >= self.total and not self.cache

    def activity(self, sample):
        for (begin, length, pitch_from, pitch_to, vowel_from, vowel_to, loudness,
             _, voicing, *_rest) in self.syllables:
            if sample < begin:
                break
            if sample < begin + length:
                local = (sample - begin) / self.rate
                duration = length / self.rate
                progress = smoothstep(local / duration)
                level = (smoothstep(local / min(0.012, duration * 0.3)) *
                         smoothstep((duration - local) / min(0.04, duration * 0.5)) *
                         min(1.0, loudness) * (0.4 + 0.6 * voicing))
                openness = (VOWEL_OPENNESS[vowel_from] +
                            (VOWEL_OPENNESS[vowel_to] - VOWEL_OPENNESS[vowel_from]) * progress)
                return level, pitch_from + (pitch_to - pitch_from) * progress, openness
        return 0.0, 0.0, 0.0

    def read(self, count):
        wanted = count * AUDIO_FRAME_BYTES
        if len(self.cache) < wanted:
            self.render(count - len(self.cache) // AUDIO_FRAME_BYTES)
        data = bytes(self.cache[:wanted])
        del self.cache[:wanted]
        return data

    def render(self, count):
        end = min(self.total, self.position + count)
        sample = self.position
        values = array.array("h")
        append = values.append
        rate = self.rate
        noise = self.random.random
        tanh = math.tanh
        table = SOURCE_TABLE
        detail = self.detail
        drive = VOICE_DRIVE
        ceiling = VOICE_CEILING
        last = self.total - 1
        fade_out = self.fade_out
        room_a, room_b = self.room_a, self.room_b
        room_a_size, room_b_size = len(room_a), len(room_b)
        room_a_index, room_b_index = self.room_a_index, self.room_b_index
        low_1, low_2 = self.low
        high_1, high_2 = self.high
        phase = self.phase
        while sample < end:
            syllable = None
            boundary = end
            for item in self.syllables:
                if sample < item[0]:
                    boundary = min(boundary, item[0])
                    break
                if sample < item[0] + item[1]:
                    syllable = item
                    boundary = min(boundary, item[0] + item[1])
                    break
            size = min(CONTROL_BLOCK, boundary - sample)
            if syllable is None:
                envelope = step = burst = burst_step = 0.0
                increment = breath = voicing = 0.0
                low_gain = high_gain = 0.0
                low_a = low_b = high_a = high_b = 0.0
            else:
                (begin, length, pitch_from, pitch_to, vowel_from, vowel_to, loudness,
                 breath, voicing, scoop, burst_amount, vibrato) = syllable
                local = (sample - begin) / rate
                duration = length / rate
                progress = smoothstep(local / duration)
                semitone = pitch_from + (pitch_to - pitch_from) * progress
                semitone -= scoop * 3.0 * (1.0 - smoothstep(local / 0.06))
                semitone += vibrato * 0.35 * math.sin(local * math.tau * self.vibrato_rate)
                semitone += self.random.gauss(0.0, 0.06)
                increment = (self.home_pitch * 2.0 ** (semitone / 12.0) /
                             rate * WAVE_SIZE)
                if voicing:
                    wide = 1.0
                    attack = min(0.004 if burst_amount else 0.012, duration * 0.3)
                    release = min(0.04, duration * 0.5)
                else:
                    wide = 6.0
                    attack = duration * 0.45
                    release = duration * 0.5
                first, second = VOWELS[vowel_from], VOWELS[vowel_to]
                breath += self.breathiness
                low_gain, low_a, low_b = resonator(
                    (first[0] + (second[0] - first[0]) * progress) * self.body,
                    FORMANT_BANDWIDTH[0] * wide, rate)
                high_gain, high_a, high_b = resonator(
                    (first[1] + (second[1] - first[1]) * progress) * self.body,
                    FORMANT_BANDWIDTH[1] * wide, rate)
                after = local + size / rate

                def shape(at):
                    return (smoothstep(at / attack) *
                            smoothstep((duration - at) / release) * loudness)

                envelope = shape(local)
                step = (shape(after) - envelope) / size
                burst = burst_amount * math.exp(-local / 0.008)
                burst_step = (burst_amount * math.exp(-after / 0.008) - burst) / size
            for _ in range(size):
                if syllable is None:
                    voice = 0.0
                else:
                    phase += increment
                    if phase >= WAVE_SIZE:
                        phase -= WAVE_SIZE
                    source = table[int(phase)] * voicing
                    hiss = (noise() - 0.5) * 2.0
                    excitation = source + hiss * (breath + burst)
                    high = high_gain * excitation + high_a * high_1 - high_b * high_2
                    high_2 = high_1
                    high_1 = high
                    if detail:
                        low = low_gain * excitation + low_a * low_1 - low_b * low_2
                        low_2 = low_1
                        low_1 = low
                    else:
                        low = 0.0
                    voice = (low * 0.8 + high * 0.6 + source * 0.25 +
                             hiss * burst * 0.5) * envelope
                    envelope += step
                    burst += burst_step
                if detail:
                    reflected_a = room_a[room_a_index]
                    room_a[room_a_index] = voice + reflected_a * 0.42
                    room_a_index += 1
                    if room_a_index == room_a_size:
                        room_a_index = 0
                    if detail > 1:
                        reflected_b = room_b[room_b_index]
                        room_b[room_b_index] = voice + reflected_b * 0.38
                        room_b_index += 1
                        if room_b_index == room_b_size:
                            room_b_index = 0
                        voice += (reflected_a + reflected_b) * 0.06
                    else:
                        voice += reflected_a * 0.10
                level = tanh(voice * drive) * ceiling
                if last - sample < fade_out:
                    level *= smoothstep((last - sample) / fade_out)
                append(int(level * 32767))
                sample += 1
        self.phase = phase
        self.low = [low_1, low_2]
        self.high = [high_1, high_2]
        self.room_a_index, self.room_b_index = room_a_index, room_b_index
        self.position = sample
        self.cache.extend(values.tobytes())


def voice_signature(intent):
    return intent if intent in PHRASE_INTENTS else VOICE_CHARACTER[intent]


@dataclass
class EyeGeometry:
    left_x: float
    right_x: float
    left_y: float
    right_y: float
    left_width: float
    right_width: float
    left_height: float
    right_height: float
    left_upper: tuple = OPEN_LID
    right_upper: tuple = OPEN_LID
    left_lower: tuple = OPEN_LID
    right_lower: tuple = OPEN_LID
    shape: float = 4.0


def power_input_state(root="/sys/class/power_supply"):
    try:
        supplies = tuple(Path(root).iterdir())
    except OSError:
        return None
    external = []
    battery_states = []
    for supply in supplies:
        try:
            kind = (supply / "type").read_text(encoding="ascii").strip().lower()
        except OSError:
            continue
        if kind == "battery":
            try:
                status = (supply / "status").read_text(encoding="ascii").strip().lower()
            except OSError:
                continue
            if status in ("charging", "full"):
                battery_states.append(True)
            elif status == "discharging":
                battery_states.append(False)
        elif kind in ("mains", "usb", "usb_cdp", "usb_dcp", "usb_pd", "usb_type_c"):
            try:
                online = (supply / "online").read_text(encoding="ascii").strip()
            except OSError:
                continue
            if online in ("0", "1"):
                external.append(online == "1")
    if external:
        return any(external)
    if battery_states:
        return any(battery_states)
    return None


class PowerMonitor:
    def __init__(self, root="/sys/class/power_supply"):
        self.root = root
        self.next_poll = 0.0
        self.candidate = None
        self.candidate_count = 0
        self.confirmed = None

    def poll(self, now):
        if now < self.next_poll:
            return False
        self.next_poll = now + POWER_POLL_INTERVAL
        state = power_input_state(self.root)
        if state is None:
            self.candidate = None
            self.candidate_count = 0
            return False
        if state != self.candidate:
            self.candidate = state
            self.candidate_count = 1
        else:
            self.candidate_count += 1
        if self.candidate_count < 2 or state == self.confirmed:
            return False
        previously_unplugged = self.confirmed is False
        self.confirmed = state
        return previously_unplugged and state


class Momo:
    def __init__(self, profile, seed=None):
        self.profile = Path(profile)
        self.random = random.Random(seed)
        self.identity = self.load_identity()
        self.colour_index = self.identity["colour"]
        self.requested_colour_index = self.colour_index
        self.elapsed = 0.0
        self.idle = 0.0
        self.stimulation = 0.0
        self.irritation = 0.0
        self.curiosity = 0.62
        self.comfort = 0.72
        self.interest_in_user = 0.45
        self.last_stimulus = -10.0
        self.stimulus_started = -10.0
        self.stimulus_due = 0.0
        self.stimulus_x = 0.0
        self.stimulus_y = 0.0
        self.stimulus_weight = 0.0
        self.stimulus_strength = 0.0
        self.stimulus_count = 0
        self.stimulus_kinds = {}
        self.recent_directions = []
        self.recent_idle_behaviours = []
        self.mood = "waking"
        self.expression = "calm"
        self.reactive_expression = False
        self.expression_side = self.random.choice((-1, 1))
        self.expression_until = 0.0
        self.fixation_until = 2.2
        self.decision_due = 2.2
        self.reaction_lock_until = WAKE_LOCK_TIME
        self.ignore_until = 0.0
        self.attention_x = 0.0
        self.attention_y = 0.0
        self.target_x = 0.0
        self.target_y = 0.0
        self.attention_return_due = 0.0
        self.shift_speed = 7.0
        self.saccade_to = (0.0, 0.0)
        self.saccade_from = (0.0, 0.0)
        self.saccade_time = 0.0
        self.saccade_duration = 0.0
        self.saccade_overshoot = 0.0
        self.saccade_active = False
        self.saccade_glide = False
        self.breath_phase = self.random.random()
        self.breath_period = BREATH_PERIOD
        self.breath = 0.0
        self.micro_x = 0.0
        self.micro_y = 0.0
        self.micro_from = (0.0, 0.0)
        self.micro_to = (0.0, 0.0)
        self.micro_time = 0.0
        self.micro_active = False
        self.micro_length = MICRO_DURATION
        self.micro_due = 1.0
        self.drift = (0.0, 0.0)
        self.previous_attention = (0.0, 0.0)
        self.stretch_x = 0.0
        self.stretch_y = 0.0
        self.voice_activity = (0.0, 0.0, 0.0)
        self.speech = 0.0
        self.speech_pitch = 0.0
        self.speech_open = 0.0
        self.correction_due = 0.0
        self.correction_pending = False
        self.openness = 0.0
        self.blink_phase = "startup"
        self.blink_kind = "startup"
        self.blink_time = 0.0
        self.blink_start_openness = 1.0
        self.blink_rest_openness = 1.0
        self.next_blink = self.blink_interval()
        self.double_blink_pending = False
        self.sleep_progress = 0.0
        self.sleep_start_openness = 1.0
        self.wake_time = 0.0
        self.wake_left_first = True
        self.rouse_time = 0.0
        self.rouse_start_openness = 1.0
        self.asymmetry = 0.0
        self.pending_reaction = None
        self.pending_voice = None
        self.voice_ready = None
        self.voice_cooldown_until = 0.0
        self.voice_serial = 0
        self.voice_family_cursor = {}
        self.voices_since_phrase = 0
        self.voice_phrase_interval_index = 0
        self.last_voice_form = None
        self.voice_repeat_count = 0
        self.contact_waiting = False
        self.contact_deadline = 0.0
        self.contact_answered = False
        self.sleepy_voice_used = False
        self.anticipation = 0.0
        self.last_interactions = []
        self.last_side_poke_expression = None
        self.last_reaction_expression = None
        self.last_side_variant = None
        self.side_variant = None
        self.side_reaction_side = 0
        self.side_reaction_started = 0.0
        self.side_release_used = False
        self.pose_width = 1.0
        self.pose_height = 1.0
        self.pose_spacing = 226.0
        self.pose_vertical = 0.0
        self.pose_left_scale = 1.0
        self.pose_right_scale = 1.0
        self.pose_left_offset = 0.0
        self.pose_right_offset = 0.0
        self.pose_left_width = 1.0
        self.pose_right_width = 1.0
        self.lids = [list(OPEN_LID) for _ in range(4)]
        self.lid_target_total = 0.0
        self.slow_blink_next = False
        self.idle_followup = None
        self.wink_side = None
        self.wink_phase = "open"
        self.wink_time = 0.0
        self.left_wink = 1.0
        self.right_wink = 1.0
        self.select_only = False
        self.select_hold = 0.0
        self.next_repaint = REPAINT_HOLD
        self.spot = [1.0, 0.0]
        self.dreaming = False
        self.dream_due = 0.0
        self.dream_until = 0.0
        self.seek_stage = 0
        self.held_side = 0
        self.held_since = 0.0
        self.stroking = False
        self.stroke_blink_due = 0.0
        self.next_purr = 0.0
        self.rhythm_taps = []
        self.battery = None
        self.charging = False
        self.tiredness = 0.0
        self.body_due = 0.0
        self.clock_ok = False
        self.greet_on_wake = False
        self.script = []
        self.sulking = 0
        self.sulk_until = 0.0
        self.greeting = "first"
        self.wake_slowness = 1.0
        self.reset_held = False
        self.reset_hold = 0.0
        self.reset_sighed = False
        self.memory_save_due = MEMORY_SAVE_INTERVAL
        self.remember()

    def blink_interval(self):
        return (self.random.uniform(*BLINK_INTERVAL) * self.identity["blink"] *
                (1.0 + 0.5 * getattr(self, "tiredness", 0.0)))

    def load_identity(self):
        path = self.profile / "identity.json"
        try:
            stored = json.loads(path.read_text(encoding="utf8"))
            identity = dict(DEFAULT_IDENTITY)
            identity.update({key: float(stored[key]) for key in DEFAULT_IDENTITY
                             if key in stored and key != "version"})
            if "colour" not in stored:
                legacy = self.load_colour()
                identity["colour"] = legacy if legacy is not None else 0
                self.save_identity(identity)
            identity["colour"] = int(identity["colour"]) % len(FORM_PALETTE)
            return identity
        except (OSError, ValueError, TypeError, json.JSONDecodeError):
            pass
        identity = roll_identity(random.Random())
        legacy = self.load_colour()
        if legacy is not None:
            identity["colour"] = legacy
        self.save_identity(identity)
        return identity

    def save_identity(self, identity):
        write_json(self.profile / "identity.json", identity)

    def load_memory(self):
        memory = fresh_memory()
        try:
            stored = json.loads((self.profile / "memory.json").read_text(encoding="utf8"))
            for key, value in stored.items():
                if key in memory and key != "version":
                    memory[key] = value
        except (OSError, ValueError, TypeError, json.JSONDecodeError):
            pass
        return memory

    def save_memory(self):
        memory = self.memory
        memory.update({
            "clock_ok": self.clock_ok,
            "last_seen": time.time(),
            "boot_id": boot_id(),
            "boot_seen": boot_clock(),
            "comfort": round(self.comfort, 4),
            "irritation": round(self.irritation, 4),
            "curiosity": round(self.curiosity, 4),
            "interest": round(self.interest_in_user, 4),
            "familiarity": round(self.familiarity, 5),
            "time_together": round(self.time_together, 1),
            "ended_asleep": self.mood == "asleep",
        })
        write_json(self.profile / "memory.json", memory)

    def let_time_pass(self, seconds):
        settle = 0.5 ** (seconds / MOOD_HALF_LIFE)
        self.irritation *= 0.5 ** (seconds / IRRITATION_HALF_LIFE)
        self.comfort = 0.72 + (self.comfort - 0.72) * settle
        self.curiosity = 0.62 + (self.curiosity - 0.62) * settle
        self.interest_in_user = 0.45 + (self.interest_in_user - 0.45) * settle

    def device_slept(self, seconds):
        log("device slept for %s" % describe_duration(seconds))
        self.let_time_pass(seconds)
        if seconds < 60.0:
            self.begin_blink()
            return
        self.greeting = choose_greeting(seconds, True, self.familiarity, False,
                                        self.mood == "asleep")
        self.wake_slowness = WAKE_SLOWNESS[self.greeting]
        self.greet_on_wake = True
        self.script = []
        self.sulking = 0
        self.pending_reaction = None
        self.pending_voice = None
        self.idle = 0.0
        self.mood = "calm"
        self.openness = 0.0
        self.start_wake()
        self.save_memory()

    def update_body(self):
        state = battery_state()
        battery, charging = state if state else (None, False)
        if battery is not None and (battery != self.battery or charging != self.charging):
            low_now = battery < LOW_BATTERY and not charging
            low_before = (self.battery is not None and self.battery < LOW_BATTERY and
                          not self.charging)
            if self.battery is None or low_now != low_before or charging != self.charging:
                log("battery %d%%%s" % (battery, ", charging" if charging else ""))
        self.battery, self.charging = battery, charging
        tiredness = 0.0
        if battery is not None and not charging and battery < LOW_BATTERY:
            tiredness = 0.9 * (LOW_BATTERY - battery) / LOW_BATTERY
        if self.clock_ok and time.time() >= CLOCK_TRUSTED_FROM:
            moment = time.localtime()
            tiredness = max(tiredness, night_tiredness(moment.tm_hour + moment.tm_min / 60.0))
        if abs(tiredness - self.tiredness) > 0.15:
            log("tiredness %.2f" % tiredness)
        self.tiredness = tiredness

    def update_dreams(self):
        if self.dreaming:
            if self.elapsed >= self.dream_until:
                self.dreaming = False
                self.dream_due = self.elapsed + self.random.uniform(*DREAM_BETWEEN)
            return
        if self.elapsed >= self.dream_due and self.openness <= 0.05:
            self.dreaming = True
            self.dream_until = self.elapsed + self.random.uniform(*DREAM_LENGTH)
            log("dreaming")
            mumble = self.random.choice(("mutter", "residue", "residue", "pleased"))
            self.schedule_voice(mumble, delay=self.random.uniform(1.0, 4.0),
                                probability=0.55, priority=2, exact=True,
                                extra={"hush": DREAM_HUSH})

    def update_seeking(self):
        threshold = self.sleepy_after()
        if self.idle < threshold * SEEK_STAGES[0]:
            self.seek_stage = 0
            return
        if (self.seek_stage >= len(SEEK_STAGES) or self.script or self.sulking or
                self.stroking or self.reset_hold or self.tiredness > 0.5 or
                (self.familiarity < FAMILIARITY_KNOWN and self.comfort < 0.85) or
                self.idle < threshold * SEEK_STAGES[self.seek_stage]):
            return
        stage = self.seek_stage
        self.seek_stage += 1
        if stage == 0:
            self.initiate_contact()
        elif stage == 1:
            self.act(expression="excited", look=(0.0, -0.15), hold=1.6, voice="chatter",
                     reactive=True)
        else:
            self.act(expression="sleepy", look=(0.0, 0.1), hold=2.2, voice="idle_breath")
        self.decision_due = self.elapsed + 4.0

    def drowsiness(self):
        if self.mood in ("sleepy", "asleep"):
            return 1.0
        threshold = self.sleepy_after()
        nodding = clamp((self.idle - threshold * 0.5) / (threshold * 0.5))
        return max(nodding, self.tiredness)

    def sleepy_after(self):
        return IDLE_SLEEPY * (1.0 - 0.45 * self.tiredness)

    def asleep_after(self):
        return IDLE_ASLEEP * (1.0 - 0.45 * self.tiredness)

    def remember(self):
        memory = self.load_memory()
        away, certain, clock_verdict = time_away(memory, time.time(), boot_id(), boot_clock())
        if clock_verdict is not None:
            memory["clock_ok"] = clock_verdict
        self.clock_ok = bool(memory["clock_ok"])
        self.memory = memory
        self.first_meeting = int(memory["visits"]) == 0
        self.time_together = float(memory["time_together"])
        familiarity = float(memory["familiarity"])
        if away is not None:
            self.irritation = float(memory["irritation"])
            self.comfort = float(memory["comfort"])
            self.curiosity = float(memory["curiosity"])
            self.interest_in_user = float(memory["interest"])
            self.let_time_pass(away)
            familiarity = max(familiarity * 0.5 ** (away / FAMILIARITY_HALF_LIFE),
                              familiarity * FAMILIARITY_FLOOR)
        self.familiarity = familiarity
        self.greeting = choose_greeting(away, certain, familiarity, self.first_meeting,
                                        bool(memory["ended_asleep"]))
        self.greet_on_wake = not self.first_meeting
        self.wake_slowness = WAKE_SLOWNESS[self.greeting]
        if away is None:
            log("first meeting")
        else:
            log("back after %s (%s); familiarity %.2f; greeting: %s" % (
                describe_duration(away), "certain" if certain else "unsure",
                familiarity, self.greeting))
        spot = memory.get("spot")
        if not spot:
            spot = [self.random.choice((-1.0, 1.0)), self.random.uniform(-0.6, 0.4)]
        else:
            spot = [float(spot[0]), clamp(float(spot[1]) + self.random.uniform(-0.2, 0.2),
                                          -0.6, 0.5)]
            if self.random.random() < 0.15:
                spot[0] = -spot[0]
        memory["spot"] = spot
        self.spot = spot
        memory["visits"] = int(memory["visits"]) + 1
        self.save_memory()

    def load_colour(self):
        try:
            value = json.loads((self.profile / "colour.json").read_text(encoding="utf8"))
            return int(value["colour_index"]) % len(FORM_PALETTE)
        except (OSError, ValueError, TypeError, KeyError, json.JSONDecodeError):
            return None

    def save_colour(self):
        self.identity["colour"] = self.colour_index
        self.save_identity(self.identity)

    def take_identity(self, identity):
        self.identity = identity
        self.save_identity(identity)
        self.colour_index = self.requested_colour_index = identity["colour"]

    def update_repaint(self, elapsed):
        if self.select_only and not self.reset_hold:
            self.select_hold += elapsed
            if self.select_hold >= self.next_repaint:
                self.next_repaint += REPAINT_REPEAT
                self.cycle_colour()
        else:
            self.select_hold = 0.0
            self.next_repaint = REPAINT_HOLD

    def cycle_colour(self):
        self.register_activity(0.35)
        self.requested_colour_index = ((self.requested_colour_index + 1) %
                                       len(FORM_PALETTE))
        if self.mood not in ("waking", "rousing") and self.blink_phase == "open":
            self.begin_blink("colour")

    def begin_blink(self, kind="normal"):
        if self.blink_phase != "open" or self.wink_phase != "open":
            return
        self.blink_phase = "closing"
        self.blink_time = 0.0
        self.blink_kind = kind
        self.blink_start_openness = clamp(self.openness)
        self.blink_rest_openness = 0.62 if self.mood == "sleepy" else 1.0
        self.asymmetry = self.random.uniform(-ASYMMETRY_RANGE, ASYMMETRY_RANGE)
        if kind == "normal":
            self.double_blink_pending = self.random.random() < DOUBLE_BLINK_CHANCE

    def register_activity(self, strength=1.0):
        was_sleeping = self.mood in ("asleep", "sleepy")
        was_fully_asleep = self.mood == "asleep" and self.openness <= 0.05
        repeated = self.elapsed - self.last_stimulus < 0.62
        self.last_stimulus = self.elapsed
        self.idle = 0.0
        self.stimulation = clamp(self.stimulation + strength * ATTENTION_ACCUMULATION)
        if repeated:
            self.irritation = clamp(self.irritation + strength * IRRITATION_ACCUMULATION *
                                    (1.2 - 0.5 * self.familiarity))
            self.comfort = clamp(self.comfort - strength * 0.055)
        else:
            self.irritation = clamp(self.irritation - 0.08)
            self.curiosity = clamp(self.curiosity + strength * 0.08)
        if was_fully_asleep:
            self.start_wake()
        elif was_sleeping:
            self.start_rouse()
        return was_sleeping

    def receive_stimulus(self, kind, x=0.0, y=0.0, strength=0.7):
        if self.reset_held or self.reset_hold:
            return
        if self.stroking:
            if strength < 0.8:
                self.register_activity(0.0)
                return
            self.stroking = False
        if self.sulking:
            self.register_activity(strength * 0.3)
            self.sulking -= 1
            if self.sulking:
                self.act(expression="suspicious", hold=SULK_PATIENCE,
                         look=(-0.9 if self.target_x > 0 else 0.9, 0.1))
                self.schedule_voice("mutter", delay=0.2, probability=0.6, priority=2)
            else:
                self.end_sulk()
            return
        self.script = []
        self.register_activity(strength)
        self.idle_followup = None
        if self.stimulus_count == 0:
            self.stimulus_started = self.elapsed
            self.stimulus_due = self.elapsed + STIMULUS_COALESCE_WINDOW
        else:
            self.stimulus_due = min(self.stimulus_started + STIMULUS_MAX_WINDOW,
                                    self.elapsed + STIMULUS_COALESCE_WINDOW)
        magnitude = math.hypot(x, y)
        if magnitude:
            x, y = x / magnitude, y / magnitude
        self.stimulus_x += x * strength
        self.stimulus_y += y * strength
        self.stimulus_weight += strength
        self.stimulus_strength = clamp(self.stimulus_strength + strength * 0.24)
        self.stimulus_count += 1
        self.stimulus_kinds[kind] = self.stimulus_kinds.get(kind, 0) + 1
        if self.contact_waiting and self.elapsed <= self.contact_deadline:
            self.contact_answered = True
            self.interest_in_user = clamp(self.interest_in_user + 0.24)
            self.comfort = clamp(self.comfort + 0.10)

    def clear_stimulus(self):
        self.stimulus_x = 0.0
        self.stimulus_y = 0.0
        self.stimulus_weight = 0.0
        self.stimulus_strength = 0.0
        self.stimulus_count = 0
        self.stimulus_kinds.clear()
        self.stimulus_due = 0.0

    def voice_mood(self):
        if self.mood in ("sleepy", "asleep"):
            sleepy = 0.8
        else:
            sleepy = max(clamp((self.idle - 30.0) / 18.0, 0.0, 0.4), 0.6 * self.tiredness)
        return {
            "valence": clamp((self.comfort - 0.6) * 2.5 - self.irritation * 1.5, -1.0, 1.0),
            "arousal": clamp(self.stimulation + self.irritation * 0.3),
            "sleepy": sleepy,
            "irritation": self.irritation,
        }

    def talkativeness(self, mood):
        return clamp((0.9 + 1.4 * max(0.0, mood["valence"]) + 0.8 * mood["arousal"] -
                      1.2 * mood["irritation"] - 0.8 * mood["sleepy"]) *
                     (0.75 + 0.5 * self.familiarity), 0.35, 2.4)

    def schedule_voice(self, intent, delay=None, probability=VOCALISATION_PROBABILITY,
                       priority=0, exact=False, extra=None):
        mood = self.voice_mood()
        if extra:
            mood.update(extra)
        if priority < 2:
            probability = min(0.95, probability * self.talkativeness(mood))
        phrase = intent in PHRASE_INTENTS
        if (intent not in VOICE_INTENTS and not phrase) or self.random.random() > probability:
            return
        if self.elapsed < self.voice_cooldown_until or self.voice_ready is not None:
            return
        if self.pending_voice is not None and priority <= self.pending_voice["priority"]:
            return
        due = self.elapsed + (delay if delay is not None else
                              self.random.uniform(*VOCAL_DELAY))
        family = ((intent,) if phrase or exact else
                  tuple(dict.fromkeys(VOCAL_FAMILIES[intent])))
        cursor = self.voice_family_cursor.get(intent, 0)
        actual_intent = family[cursor % len(family)]
        self.voice_family_cursor[intent] = cursor + 1
        if intent in PHRASE_FOR_INTENT and not phrase and not exact:
            self.voices_since_phrase += 1
            phrase_interval = VOICE_PHRASE_INTERVALS[self.voice_phrase_interval_index]
            strongly_expressive = (intent in ("question", "pleased", "protest", "wake")
                                   and (self.stimulation > 0.62 or self.irritation > 0.48))
            if (self.voices_since_phrase >= phrase_interval or
                    (strongly_expressive and self.voices_since_phrase >= 2)):
                actual_intent = PHRASE_FOR_INTENT[intent]
                self.voices_since_phrase = 0
                self.voice_phrase_interval_index = (
                    (self.voice_phrase_interval_index + 1) % len(VOICE_PHRASE_INTERVALS))
        signature = voice_signature(actual_intent)
        if signature == self.last_voice_form and self.voice_repeat_count >= 2 and not exact:
            alternatives = [item for item in family
                            if voice_signature(item) != self.last_voice_form]
            if alternatives:
                actual_intent = alternatives[cursor % len(alternatives)]
                signature = voice_signature(actual_intent)
        if signature == self.last_voice_form:
            self.voice_repeat_count += 1
        else:
            self.last_voice_form = signature
            self.voice_repeat_count = 1
        candidate = {"intent": actual_intent, "source_intent": intent,
                     "due": due, "priority": priority, "mood": mood}
        self.pending_voice = candidate

    def update_voice(self):
        if self.pending_voice and self.elapsed >= self.pending_voice["due"]:
            if self.elapsed >= self.voice_cooldown_until and self.voice_ready is None:
                intent = self.pending_voice["intent"]
                mood = self.pending_voice["mood"]
                self.voice_ready = (intent, self.voice_serial % VOICE_VARIATIONS, mood)
                self.voice_serial += 1
                self.voice_cooldown_until = self.elapsed + VOCAL_COOLDOWN / (
                    0.75 + 0.25 * self.talkativeness(mood))
            self.pending_voice = None

    def take_voice(self):
        voice = self.voice_ready
        self.voice_ready = None
        return voice

    def commit_reaction(self, expression, target=None, hold=2.6, blink=False,
                        voice=None, voice_probability=VOCALISATION_PROBABILITY,
                        voice_priority=0, voice_lag=(0.28, 0.62),
                        side_variant=None, side=0):
        delay = self.random.uniform(*REACTION_DELAY)
        self.pending_reaction = {
            "due": self.elapsed + delay,
            "expression": expression,
            "target": target,
            "hold": max(INTENTION_MINIMUM_LIFETIME, hold),
            "blink": blink,
            "side_variant": side_variant,
            "side": side,
        }
        self.reaction_lock_until = self.elapsed + delay + self.pending_reaction["hold"]
        self.fixation_until = self.reaction_lock_until
        self.decision_due = (self.reaction_lock_until +
                             self.random.uniform(*AUTONOMOUS_REST_DURATION))
        self.idle_followup = None
        if voice:
            self.schedule_voice(voice, delay + self.random.uniform(*voice_lag),
                                voice_probability, voice_priority)

    def consume_stimulus(self):
        if not self.stimulus_count:
            return
        if self.elapsed - self.last_stimulus > STIMULUS_STALE_AFTER:
            self.clear_stimulus()
            return
        count = self.stimulus_count
        kinds = dict(self.stimulus_kinds)
        weight = max(0.001, self.stimulus_weight)
        x = clamp(self.stimulus_x / weight, -1.0, 1.0)
        y = clamp(self.stimulus_y / weight, -1.0, 1.0)
        strength = self.stimulus_strength
        self.clear_stimulus()

        if self.elapsed < self.ignore_until:
            return
        target = (x, y) if abs(x) + abs(y) > 0.08 else (0.0, 0.0)
        answered = self.contact_answered
        self.contact_waiting = False
        self.contact_answered = False

        if count >= CHAOS_INPUT_COUNT or self.irritation > 0.76 or strength > 0.94:
            away = (-x * 0.55, -y * 0.35) if target != (0.0, 0.0) else (0.0, 0.0)
            self.curiosity = clamp(self.curiosity - 0.28)
            self.comfort = clamp(self.comfort - 0.20)
            self.ignore_until = self.elapsed + CHAOS_IGNORE_TIME
            self.commit_reaction("irritated", away, 4.2, blink=count < 12,
                                 voice="protest", voice_probability=0.72,
                                 voice_priority=3)
        elif count >= 4 or self.irritation > 0.50:
            self.curiosity = clamp(self.curiosity - 0.12)
            self.commit_reaction("suspicious", target, 3.8,
                                 voice="mutter", voice_probability=0.48,
                                 voice_priority=2)
        elif answered:
            self.commit_reaction("delighted", (0.0, -0.12), 3.0,
                                 voice="pleased", voice_probability=0.68,
                                 voice_priority=2)
        elif kinds.get("call"):
            self.interest_in_user = clamp(self.interest_in_user + 0.14)
            self.commit_reaction("listening", (0.0, 0.0),
                                 self.random.uniform(3.0, 3.6),
                                 voice="question", voice_probability=0.72,
                                 voice_priority=2)
        elif any(kinds.get(kind) for kind in
                 ("edge_left", "edge_right", "flinch", "peek")):
            left = bool(kinds.get("edge_left") or kinds.get("flinch"))
            right = bool(kinds.get("edge_right") or kinds.get("peek"))
            strong = bool(kinds.get("flinch") or kinds.get("peek"))
            both = left and right
            if both:
                expression = "suspicious"
            elif strong:
                expression = "surprised"
            elif self.irritation > 0.28:
                expression = "suspicious"
            else:
                expression = self.pick_expression(
                    (("curious", 0.4), ("attentive", 0.4), ("suspicious", 0.2)),
                    self.last_side_poke_expression)
            self.last_side_poke_expression = expression
            if both:
                toward = (0.0, -0.04)
                variant = None
                side = 0
            else:
                toward = (x * 0.72, self.random.uniform(-0.12, 0.08))
                side = -1 if left else 1
                variants = ("glance", "linger", "blink")
                available = [item for item in variants if item != self.last_side_variant]
                if self.irritation > 0.28 and "glance" in available:
                    variant = "glance"
                elif self.comfort > 0.70 and "linger" in available:
                    variant = "linger"
                else:
                    variant = self.random.choice(available)
                self.last_side_variant = variant
            self.commit_reaction(expression, toward,
                                 self.random.uniform(1.8, 2.4),
                                 blink=variant == "blink",
                                 voice="startled" if strong else "click",
                                 voice_probability=0.48 if strong else 0.42,
                                 voice_priority=1,
                                 voice_lag=(0.08, 0.22),
                                 side_variant=variant, side=side)
        elif strength > 0.50 + 0.15 * self.familiarity:
            self.commit_reaction("surprised", target, 2.0,
                                 voice="startled", voice_probability=0.44,
                                 voice_priority=1)
        elif kinds.get("boop"):
            self.interest_in_user = clamp(self.interest_in_user + 0.05)
            if self.irritation > 0.45:
                self.commit_reaction("suspicious", (0.0, 0.0), 2.0, voice="mutter",
                                     voice_probability=0.7, voice_priority=1)
            else:
                warm = self.familiarity >= FAMILIARITY_KNOWN or self.comfort > 0.8
                self.comfort = clamp(self.comfort + 0.04)
                chirp = self.random.choice(("pleased", "squeak", "flutter") if warm else
                                           ("squeak", "notice", "acknowledge"))
                self.commit_reaction("delighted" if warm else "attentive", (0.0, -0.08),
                                     2.0, blink=True, voice=chirp, voice_probability=0.85,
                                     voice_priority=1, voice_lag=(0.08, 0.2))
        elif kinds.get("soothe") or kinds.get("watch"):
            self.comfort = clamp(self.comfort + 0.12)
            self.commit_reaction("attentive", target, 3.0,
                                 voice="acknowledge", voice_probability=0.28)
        elif kinds.get("play"):
            self.curiosity = clamp(self.curiosity + 0.12)
            self.commit_reaction("delighted", target, 2.8,
                                 voice="pleased", voice_probability=0.40)
        else:
            if self.curiosity > 0.38:
                options = (("curious", self.curiosity * 0.6),
                           ("attentive", 0.30 + self.comfort * 0.25),
                           ("listening", 0.20))
            else:
                options = (("suspicious", 0.6), ("attentive", 0.4))
            expression = self.pick_expression(options, self.last_reaction_expression)
            self.commit_reaction(expression, target, 3.1,
                                 voice="curious", voice_probability=0.34)

    def pick_expression(self, options, avoid=None):
        options = [item for item in options if item[0] != avoid] or options
        point = self.random.uniform(0.0, sum(weight for _, weight in options))
        for expression, weight in options:
            point -= weight
            if point <= 0.0:
                return expression
        return options[-1][0]

    def stimulus(self, x, y, strength=1.0):
        self.receive_stimulus("direction", x, y, strength)

    def interact(self, kind):
        self.last_interactions.append(kind)
        self.last_interactions = self.last_interactions[-4:]
        spatial = {
            "surprise": (0.0, -1.0, 0.72),
            "soothe": (0.0, 1.0, 0.42),
            "tease": (-1.0, 0.0, 0.58),
            "greet": (1.0, 0.0, 0.52),
            "edge_left": (-1.0, 0.0, 0.62),
            "edge_right": (1.0, 0.0, 0.62),
            "flinch": (-1.0, 0.0, 0.88),
            "peek": (1.0, 0.0, 0.88),
            "lean_in": (0.0, -0.5, 0.50),
            "boop": (0.0, -0.3, 0.45),
            "withdraw": (0.0, 0.7, 0.66),
        }
        if kind == "startle":
            self.receive_stimulus("call", 0.0, 0.0, 0.66)
        elif kind in spatial:
            x, y, strength = spatial[kind]
            self.receive_stimulus(kind, x, y, strength)
        else:
            self.receive_stimulus(kind, 0.0, 0.0, 0.52)

    def press_shoulder(self, button):
        self.held_side = -1 if button == 4 else 1
        self.held_since = self.elapsed

    def begin_stroke(self):
        if self.sulking:
            self.end_sulk()
        self.stroking = True
        self.stroke_blink_due = self.elapsed + self.random.uniform(3.5, 6.0)
        self.clear_stimulus()
        self.pending_reaction = None
        self.idle_followup = None
        self.script = []
        self.next_purr = self.elapsed + 0.4

    def end_stroke(self):
        self.stroking = False
        self.slow_blink_next = True
        self.expression = "content"
        self.expression_until = self.elapsed + 1.8
        self.return_attention_to_rest()
        self.decision_due = self.elapsed + 3.0
        self.schedule_voice("acknowledge", delay=0.3, probability=0.4, priority=1, exact=True)

    def tap_rhythm(self):
        now = self.elapsed
        if not self.rhythm_taps or now - self.rhythm_taps[-1] > RHYTHM_GAP[1]:
            self.rhythm_taps = [now]
            self.interact("play")
            return
        if now - self.rhythm_taps[-1] < RHYTHM_GAP[0]:
            return
        self.rhythm_taps.append(now)
        self.register_activity(0.0)
        if len(self.rhythm_taps) == 2:
            self.clear_stimulus()
            self.pending_reaction = None
            self.expression = "listening"
            self.reactive_expression = True
            self.set_attention(0.0, -0.05)
        self.expression_until = self.elapsed + 2.0
        if len(self.rhythm_taps) >= RHYTHM_MAX:
            self.finish_rhythm()

    def finish_rhythm(self):
        taps, self.rhythm_taps = self.rhythm_taps, []
        if len(taps) < 3:
            return
        onsets = tuple(round(tap - taps[0], 3) for tap in taps)
        self.voice_cooldown_until = self.elapsed
        self.pending_voice = None
        self.schedule_voice("echo", delay=0.2, probability=1.0, priority=3, exact=True,
                            extra={"rhythm": onsets})
        self.expression = "delighted"
        self.reactive_expression = True
        self.expression_until = self.elapsed + onsets[-1] + 1.6
        self.comfort = clamp(self.comfort + 0.1)
        self.curiosity = clamp(self.curiosity + 0.1)
        self.decision_due = self.expression_until + 2.0

    def update_touch(self, elapsed):
        if (self.held_side and not self.stroking and not self.reset_held and
                self.elapsed - self.held_since >= STROKE_AFTER):
            self.begin_stroke()
        if self.stroking:
            if self.reset_held:
                self.stroking = False
            else:
                self.target_x, self.target_y = self.held_side * 0.35, 0.05
                self.attention_return_due = 0.0
                self.shift_speed = 2.6
                self.expression = "content"
                self.reactive_expression = False
                self.expression_until = self.elapsed + 1.0
                self.comfort = clamp(self.comfort + 0.06 * elapsed)
                self.irritation = max(0.0, self.irritation - 0.10 * elapsed)
                self.idle = 0.0
                self.last_stimulus = self.elapsed
                if self.elapsed >= self.stroke_blink_due:
                    self.stroke_blink_due = self.elapsed + self.random.uniform(4.0, 8.0)
                    self.begin_blink("slow")
                if (self.elapsed >= self.next_purr and self.voice_ready is None and
                        self.pending_voice is None and
                        self.elapsed >= self.voice_cooldown_until):
                    self.next_purr = self.elapsed + self.random.uniform(*PURR_INTERVAL)
                    self.schedule_voice("purr", delay=0.05, probability=1.0, priority=2,
                                        exact=True)
        if self.rhythm_taps and self.elapsed - self.rhythm_taps[-1] > RHYTHM_END:
            self.finish_rhythm()

    def release_shoulder(self, button):
        if button in (4, 5) and (-1 if button == 4 else 1) == self.held_side:
            self.held_side = 0
            if self.stroking:
                self.end_stroke()
                return
        side = -1 if button in (4, 6) else 1
        if (self.side_variant == "linger" and self.side_reaction_side == side and
                not self.side_release_used and self.attention_return_due > self.elapsed):
            self.attention_return_due += 0.18
            self.side_release_used = True

    def power_connected(self):
        self.register_activity(0.75)
        self.comfort = clamp(self.comfort + 0.18)
        self.curiosity = clamp(self.curiosity + 0.12)
        self.commit_reaction("excited", (0.0, -0.16), 4.2, blink=True,
                             voice="pleased", voice_probability=1.0,
                             voice_priority=3)
        if self.mood == "waking":
            self.pending_reaction["due"] = self.elapsed + 1.75
            if self.pending_voice:
                self.pending_voice["due"] = max(self.pending_voice["due"],
                                                 self.elapsed + 2.0)

    @property
    def brightness(self):
        if self.reset_hold <= RESET_FORGET_TIME:
            return 1.0
        return 1.0 - smoothstep((self.reset_hold - RESET_FORGET_TIME) /
                                (RESET_NEW_TIME - RESET_FORGET_TIME))

    def update_reset(self, elapsed):
        if self.reset_held:
            if self.reset_hold == 0.0:
                self.clear_stimulus()
                self.pending_reaction = None
                self.pending_voice = None
                self.idle_followup = None
                self.contact_waiting = False
                self.return_attention_to_rest()
                self.expression = "calm"
                self.expression_until = self.elapsed
            self.reset_hold += elapsed
            if self.reset_hold >= RESET_FORGET_TIME and not self.reset_sighed:
                self.reset_sighed = True
                self.schedule_voice("sleepy", delay=0.05, probability=1.0, priority=3)
        elif self.reset_hold > 0.0:
            hold = self.reset_hold
            self.reset_hold = 0.0
            self.reset_sighed = False
            if hold < RESET_FORGET_TIME:
                self.expression = "surprised"
                self.reactive_expression = True
                self.expression_until = self.elapsed + 1.2
                self.schedule_voice("startled", delay=0.1, probability=1.0, priority=3)
            else:
                self.forget(new_identity=hold >= RESET_NEW_TIME)

    def forget(self, new_identity=False):
        if new_identity:
            self.take_identity(roll_identity(random.Random()))
        memory = fresh_memory()
        memory["visits"] = 1
        self.memory = memory
        self.comfort, self.irritation = memory["comfort"], memory["irritation"]
        self.curiosity, self.interest_in_user = memory["curiosity"], memory["interest"]
        self.familiarity = 0.0
        self.time_together = 0.0
        self.save_memory()
        self.first_meeting = True
        self.greet_on_wake = False
        self.greeting = "first"
        self.wake_slowness = FIRST_MEETING_SLOWNESS
        self.script = []
        self.sulking = 0
        self.mood = "calm"
        self.idle = 0.0
        self.openness = 0.0
        self.start_wake()

    def act(self, expression=None, look=None, hold=1.5, voice=None, reactive=False,
            blink=None):
        if look is not None:
            self.set_attention(*look, reactive=reactive)
        if expression is not None:
            self.expression = expression
            self.reactive_expression = reactive
            self.expression_until = self.elapsed + hold
            self.expression_side = self.random.choice((-1, 1))
        if blink:
            self.begin_blink()
            self.double_blink_pending = blink == "double"
        if voice:
            self.schedule_voice(voice, delay=0.05, probability=1.0, priority=2, exact=True)

    def queue(self, beats):
        self.script = [(self.elapsed + delay, beat) for delay, beat in beats]
        self.decision_due = self.elapsed + beats[-1][0] + 3.0

    def recognise(self):
        if self.familiarity >= FAMILIARITY_CLOSE:
            return dict(expression="excited", look=(0.0, -0.12), hold=3.2,
                        voice="phrase_pleased", reactive=True, blink="double")
        if self.familiarity >= FAMILIARITY_KNOWN:
            return dict(expression="delighted", look=(0.0, -0.08), hold=2.8,
                        voice="pleased", reactive=True)
        return dict(expression="curious", look=(0.0, -0.05), hold=2.4, voice="notice")

    def begin_greeting(self):
        side = self.random.choice((-1.0, 1.0))
        kind = self.greeting
        if kind == "brief":
            self.queue([(0.0, dict(expression="attentive", look=(0.0, -0.05), hold=1.6)),
                        (0.25, dict(voice="acknowledge"))])
        elif kind == "short":
            self.queue([(0.0, dict(blink=True)),
                        (0.6, dict(look=(side * 0.7, -0.1))),
                        (1.8, self.recognise() if self.familiarity >= FAMILIARITY_KNOWN
                         else dict(expression="attentive", look=(0.0, -0.05), hold=2.0,
                                   voice="notice"))])
        elif kind == "long":
            self.queue([(0.0, dict(expression="sleepy", hold=1.5)),
                        (0.3, dict(voice="wake")),
                        (1.7, dict(expression="suspicious", look=(0.0, -0.02), hold=1.2)),
                        (3.0, self.recognise())])
        elif kind == "sulk":
            self.queue([(0.0, dict(expression="sleepy", hold=1.3)),
                        (1.5, dict(expression="suspicious", look=(side * 0.9, 0.1),
                                   hold=SULK_PATIENCE)),
                        (1.9, dict(voice="mutter"))])
            self.sulking = SULK_POKES
            self.sulk_until = self.elapsed + SULK_PATIENCE

    def update_script(self):
        if self.mood in ("waking", "rousing") or self.reset_hold:
            return
        while self.script and self.elapsed >= self.script[0][0]:
            _, beat = self.script.pop(0)
            self.act(**beat)
        if self.sulking and self.elapsed >= self.sulk_until:
            self.end_sulk()

    def end_sulk(self):
        self.sulking = 0
        self.script = []
        self.idle = 0.0
        self.seek_stage = 0
        self.voice_cooldown_until = self.elapsed
        self.act(**self.recognise())
        self.decision_due = self.elapsed + 5.0

    def finish_first_meeting(self):
        self.first_meeting = False
        self.set_attention(-0.8, -0.1)
        self.expression = "curious"
        self.expression_until = self.elapsed + 1.4
        self.idle_followup = {"due": self.elapsed + 1.6, "expression": "attentive",
                              "target": (0.0, -0.05), "hold": 2.6}
        self.schedule_voice("notice", delay=2.3, probability=1.0, priority=2)

    def begin_wink(self, side=None):
        if self.wink_phase != "open" or self.blink_phase != "open":
            return
        self.wink_side = side or self.random.choice(("left", "right"))
        self.wink_phase = "closing"
        self.wink_time = 0.0

    def update_wink(self, elapsed):
        if self.wink_phase == "open":
            return
        self.wink_time += elapsed
        affected = "left_wink" if self.wink_side == "left" else "right_wink"
        if self.wink_phase == "closing":
            setattr(self, affected, 1.0 - smoothstep(self.wink_time / 0.11))
            if self.wink_time >= 0.11:
                setattr(self, affected, 0.0)
                self.wink_phase = "closed"
                self.wink_time = 0.0
        elif self.wink_phase == "closed":
            if self.wink_time >= 0.075:
                self.wink_phase = "opening"
                self.wink_time = 0.0
        elif self.wink_phase == "opening":
            setattr(self, affected, smoothstep(self.wink_time / 0.19))
            if self.wink_time >= 0.19:
                self.left_wink = 1.0
                self.right_wink = 1.0
                self.wink_phase = "open"
                self.wink_side = None

    def apply_pending_reaction(self):
        reaction = self.pending_reaction
        if not reaction or self.elapsed < reaction["due"]:
            return
        self.pending_reaction = None
        self.anticipation = 0.0
        self.expression = reaction["expression"]
        self.last_reaction_expression = self.expression
        self.reactive_expression = True
        self.side_variant = reaction["side_variant"]
        self.side_reaction_side = reaction["side"]
        self.side_reaction_started = self.elapsed
        self.side_release_used = False
        if self.expression == "curious":
            self.expression_side = self.random.choice((-1, 1))
        self.expression_until = self.elapsed + reaction["hold"]
        target = reaction["target"]
        if target is not None:
            self.set_attention(*target, reactive=True)
            self.fixation_until = self.expression_until
            if self.side_variant == "glance":
                self.attention_return_due = self.elapsed + self.random.uniform(0.95, 1.15)
            elif self.side_variant == "linger":
                self.attention_return_due = self.elapsed + self.random.uniform(1.65, 2.05)
        if reaction["blink"] and self.blink_phase == "open":
            self.begin_blink()

    def apply_idle_followup(self):
        reaction = self.idle_followup
        if (not reaction or self.pending_reaction or self.stimulus_count or
                self.elapsed < reaction["due"]):
            return
        self.idle_followup = None
        self.expression = reaction["expression"]
        self.reactive_expression = False
        if self.expression == "curious":
            self.expression_side = self.random.choice((-1, 1))
        self.expression_until = self.elapsed + reaction["hold"]
        self.set_attention(*reaction["target"], reactive=True)
        self.fixation_until = self.expression_until
        self.decision_due = (self.expression_until +
                             self.random.uniform(*AUTONOMOUS_REST_DURATION))

    def set_attention(self, x, y, reactive=False):
        self.target_x = clamp(x, -1.0, 1.0)
        self.target_y = clamp(y, -1.0, 1.0)
        self.shift_speed = 13.0 if reactive else self.random.uniform(7.0, 11.0)
        displaced = abs(self.target_x) > 0.01 or abs(self.target_y) > 0.01
        self.correction_pending = displaced
        if displaced:
            self.expression_side = self.random.choice((-1, 1))
            self.correction_due = self.elapsed + self.random.uniform(0.18, 0.34)
            duration = REACTIVE_GAZE_DURATION if reactive else IDLE_GAZE_DURATION
            self.attention_return_due = self.elapsed + self.random.uniform(*duration)
            self.fixation_until = (self.attention_return_due +
                                   self.random.uniform(*CENTRED_REST_DURATION))
        else:
            self.attention_return_due = 0.0
            self.fixation_until = self.elapsed + self.random.uniform(*CENTRED_REST_DURATION)

    def return_attention_to_rest(self):
        self.target_x = 0.0
        self.target_y = 0.0
        self.attention_return_due = 0.0
        self.correction_pending = False
        self.shift_speed = 5.2 if self.side_variant == "linger" else 6.5
        self.side_variant = None
        self.side_reaction_side = 0

    def start_wake(self):
        if self.mood == "waking":
            return
        self.mood = "waking"
        self.expression = "attentive"
        self.expression_until = self.elapsed + 1.9
        self.wake_time = 0.0
        self.wake_left_first = self.random.random() < 0.5
        self.sleep_progress = 0.0
        self.blink_phase = "startup"
        self.blink_kind = "startup"
        self.pending_reaction = None
        self.idle_followup = None
        self.pending_voice = None
        self.reaction_lock_until = self.elapsed + WAKE_LOCK_TIME

    def start_rouse(self):
        if self.mood == "rousing":
            return
        self.mood = "rousing"
        self.expression = "attentive"
        self.expression_until = self.elapsed + 1.1
        self.rouse_time = 0.0
        self.rouse_start_openness = max(0.08, self.openness)
        self.sleep_progress = 0.0
        self.blink_phase = "open"
        self.blink_kind = "normal"
        self.double_blink_pending = False
        self.pending_reaction = None
        self.idle_followup = None
        self.pending_voice = None
        self.return_attention_to_rest()
        self.reaction_lock_until = self.elapsed + 1.05
        self.schedule_voice("idle_breath", delay=0.30, probability=0.42)

    def initiate_contact(self):
        self.contact_waiting = True
        self.contact_answered = False
        self.contact_deadline = self.elapsed + CONTACT_RESPONSE_WINDOW
        self.expression = "attentive"
        self.expression_until = self.contact_deadline
        self.set_attention(0.0, 0.0)
        self.reaction_lock_until = self.elapsed + 1.2
        self.decision_due = self.contact_deadline + self.random.uniform(3.0, 6.0)
        self.schedule_voice("question", delay=self.random.uniform(0.62, 0.94),
                            probability=0.78, priority=1)

    def update_contact(self):
        if not self.contact_waiting or self.elapsed < self.contact_deadline:
            return
        self.contact_waiting = False
        self.contact_answered = False
        self.expression = "calm"
        self.expression_until = self.elapsed
        if self.random.random() < MICRO_BEHAVIOUR_PROBABILITY:
            self.begin_blink()

    def choose_attention(self):
        notice = VIEWER_NOTICE_CHANCE * (0.4 + 1.6 * self.familiarity)
        if self.random.random() < notice and self.idle < self.sleepy_after():
            self.initiate_contact()
            return
        directions = [(-1.0, -0.25), (1.0, -0.2), (-0.7, 0.55),
                      (0.72, 0.5), (0.0, -0.8), (0.0, 0.65),
                      (-1.0, 0.05), (1.0, 0.08), (0.0, 0.0)]
        available = [item for item in directions if item not in self.recent_directions[-2:]]
        direction = self.random.choice(available or directions)
        self.recent_directions.append(direction)
        self.recent_directions = self.recent_directions[-4:]
        if self.irritation > 0.58:
            self.set_attention(*direction)
            self.expression = "irritated"
            behaviour = "irritated"
        else:
            behaviours = ("glance", "glance", "glance", "spot", "spot", "edge", "slow_look",
                          "inspect", "curious_wink", "double_take", "delighted",
                          "surprised", "quiet", "quiet")
            available_behaviours = [item for item in behaviours
                                    if item not in self.recent_idle_behaviours[-2:]]
            behaviour = self.random.choice(available_behaviours or behaviours)
            self.recent_idle_behaviours.append(behaviour)
            self.recent_idle_behaviours = self.recent_idle_behaviours[-4:]
            if ((behaviour == "delighted" and self.stimulation <= 0.22) or
                    (behaviour == "surprised" and self.random.random() > 0.35)):
                behaviour = "glance"
            if self.tiredness > 0.25 and self.random.random() < 0.35 * self.tiredness:
                behaviour = "yawn"
        if behaviour == "spot":
            spot_x, spot_y = self.spot
            self.set_attention(spot_x, spot_y)
            roll = self.random.random()
            if roll < 0.08:
                self.expression = "surprised"
                self.schedule_voice("notice", delay=0.25, probability=1.0, priority=1,
                                    exact=True)
            else:
                self.expression = "curious" if roll < 0.35 else "calm"
            follow = self.random.random()
            if follow < 0.25:
                self.idle_followup = {"due": self.attention_return_due + 0.7,
                                      "expression": "attentive",
                                      "target": (spot_x, spot_y), "hold": 1.4}
            elif follow < 0.45:
                self.idle_followup = {"due": self.attention_return_due + 0.5,
                                      "expression": "attentive",
                                      "target": (0.0, -0.05), "hold": 2.0}
                self.schedule_voice("question", delay=self.attention_return_due -
                                    self.elapsed + 0.7, probability=0.7, priority=1,
                                    exact=True)
        elif behaviour == "yawn":
            self.set_attention(0.0, 0.08)
            self.expression = "sleepy"
            self.fixation_until += self.random.uniform(1.0, 2.0)
            self.schedule_voice("sleepy", delay=0.3, probability=0.8, priority=2, exact=True)
        elif behaviour == "glance":
            self.set_attention(*direction)
            self.expression = "calm"
        elif behaviour == "curious_wink":
            self.set_attention(*direction)
            self.expression = "curious"
            self.begin_wink()
            self.fixation_until += self.random.uniform(1.0, 2.2)
        elif behaviour == "edge":
            edge = self.random.choice((-1.0, 1.0))
            self.set_attention(edge, self.random.uniform(-0.32, 0.22))
            self.expression = self.pick_expression(
                (("calm", 0.5), ("attentive", 0.3), ("curious", 0.2)))
            self.fixation_until += self.random.uniform(1.8, 3.4)
        elif behaviour == "inspect":
            self.set_attention(0.0, self.random.uniform(-0.1, 0.18))
            self.expression = "suspicious"
            self.fixation_until += self.random.uniform(2.0, 4.0)
        elif behaviour == "double_take":
            first = self.random.choice(((-0.72, -0.22), (0.72, -0.22)))
            second = (-first[0] * 0.7, first[1] + 0.1)
            self.set_attention(*first)
            self.expression = "surprised"
            self.idle_followup = {
                "due": self.attention_return_due + self.random.uniform(0.45, 0.75),
                "expression": "attentive",
                "target": second,
                "hold": self.random.uniform(2.4, 4.2),
            }
        elif behaviour == "delighted":
            self.set_attention(*direction)
            self.expression = "delighted"
        elif behaviour == "surprised":
            self.set_attention(*direction)
            self.expression = "surprised"
        elif behaviour == "slow_look":
            self.set_attention(direction[0] * 0.5, -0.62)
            self.shift_speed = self.random.uniform(2.4, 3.2)
            self.expression = "calm"
            self.fixation_until += self.random.uniform(3.0, 5.0)
        else:
            self.set_attention(0.0, 0.0)
            self.expression = "calm"
        self.expression_until = self.fixation_until
        self.decision_due = (max(self.expression_until, self.attention_return_due) +
                             self.random.uniform(*AUTONOMOUS_REST_DURATION))
        idle_voices = {
            "quiet": "idle_breath",
            "slow_look": "idle_chime",
            "inspect": "idle_ripple",
            "curious_wink": "idle_pop",
            "edge": "idle_pop",
            "double_take": "idle_ripple",
            "delighted": "idle_chime",
            "surprised": "idle_pop",
        }
        if behaviour in idle_voices:
            self.schedule_voice(idle_voices[behaviour],
                                delay=self.random.uniform(0.36, 0.82),
                                probability=IDLE_VOCALISATION_PROBABILITY)

    def expression_targets(self):
        emphasis = 1.0 + (EXPRESSION_INTENSITY if self.reactive_expression else 0.0)
        targets = [1.0, 1.0, 226.0, 0.0, 1.0, 1.0, 0.0, 0.0,
                   1.0, 1.0]
        if self.expression == "curious":
            targets[4], targets[5] = 1.07, 0.99
            targets[6], targets[7] = -4.0 * emphasis, 1.0
            targets[8], targets[9] = 0.98, 1.01
            if self.expression_side < 0:
                targets[4], targets[5] = targets[5], targets[4]
                targets[6], targets[7] = targets[7], targets[6]
                targets[8], targets[9] = targets[9], targets[8]
        elif self.expression == "delighted":
            targets[0], targets[1], targets[3] = (1.0 + 0.07 * emphasis,
                                                     1.0 + 0.15 * emphasis,
                                                     -10.0 * emphasis)
        elif self.expression == "excited":
            targets[0], targets[1], targets[2], targets[3] = (1.08, 1.30, 238.0, -12.0)
        elif self.expression == "suspicious":
            targets[2] = 214.0
        elif self.expression == "irritated":
            targets[2] = 216.0
            targets[8], targets[9] = 1.04, 1.04
        elif self.expression == "surprised":
            targets[0], targets[1] = 0.93, 1.0 + 0.27 * emphasis
            targets[8], targets[9] = 0.96, 0.96
        elif self.expression == "attentive":
            targets[1] = 1.0 + 0.12 * emphasis
        elif self.expression == "content":
            targets[0], targets[1], targets[3] = 1.05, 0.95, -8.0
            if self.stroking:
                targets[6], targets[7] = -7.0 * self.held_side, 7.0 * self.held_side
        elif self.expression == "listening":
            targets[1], targets[2] = 1.0 + 0.12 * emphasis, 208.0
        if self.side_reaction_side and self.side_variant:
            age = self.elapsed - self.side_reaction_started
            first = 4 if self.side_reaction_side < 0 else 5
            second = 5 if self.side_reaction_side < 0 else 4
            if 0.0 <= age < 0.17:
                targets[first] *= 0.88
            if 0.08 <= age < 0.29:
                targets[second] *= 0.94
        return targets

    def lid_targets(self):
        emphasis = 1.0 + (EXPRESSION_INTENSITY if self.reactive_expression else 0.0)
        expression = self.expression
        upper = [OPEN_LID, OPEN_LID]
        lower = [OPEN_LID, OPEN_LID]
        lead, other = (0, 1) if self.expression_side >= 0 else (1, 0)
        if expression == "curious":
            upper[other] = (0.10 * emphasis, -0.10, 0.05)
        elif expression == "delighted":
            lower = [(0.14 * emphasis, 0.0, 0.55)] * 2
        elif expression == "excited":
            lower = [(0.08 * emphasis, 0.0, 0.40)] * 2
        elif expression == "suspicious":
            upper[lead] = (0.32 * emphasis, 0.18, 0.0)
            upper[other] = (0.24 * emphasis, 0.12, 0.0)
            lower = [(0.15 * emphasis, -0.05, 0.0)] * 2
        elif expression == "irritated":
            upper = [(0.24 * emphasis, 0.62, -0.06)] * 2
            lower = [(0.08 * emphasis, 0.0, 0.0)] * 2
        elif expression == "sleepy":
            upper = [(0.34, -0.10, -0.28)] * 2
        elif expression == "content":
            upper = [(0.10, 0.0, -0.35)] * 2
            lower = [(0.28, 0.0, 0.80)] * 2
        weight = 0.14 * self.tiredness
        if weight and expression != "surprised":
            upper = [(amount + weight, angle, bend) for amount, angle, bend in upper]
        return upper + lower

    def update_lids(self, elapsed):
        targets = self.lid_targets()
        total = sum(target[0] for target in targets)
        if abs(total - self.lid_target_total) > LID_BLINK_CHANGE:
            if self.slow_blink_next:
                self.slow_blink_next = False
                self.begin_blink("slow")
            elif self.random.random() < 0.5 and self.mood in ("calm", "attentive"):
                self.begin_blink()
        self.lid_target_total = total
        speed = 13.0 if self.expression == "surprised" else LID_SPEED
        if self.blink_phase == "closing":
            speed = 1.0
        elif self.blink_phase == "closed":
            speed = 40.0
        elif self.blink_phase == "opening":
            speed = 20.0
        for lid, target in zip(self.lids, targets):
            for index in range(3):
                lid[index] = approach(lid[index], target[index], speed, elapsed)

    def begin_saccade(self, target):
        start = (self.attention_x, self.attention_y)
        pixels = math.hypot((target[0] - start[0]) * GAZE_PIXELS_X,
                            (target[1] - start[1]) * GAZE_PIXELS_Y)
        self.saccade_from = start
        self.saccade_to = target
        self.saccade_time = 0.0
        self.saccade_active = True
        self.saccade_glide = self.shift_speed < GLIDE_BELOW_SPEED
        pace = clamp(9.0 / max(0.1, self.shift_speed), 0.9, 1.6)
        drowsy = self.drowsiness()
        self.saccade_duration = ((SACCADE_BASE + SACCADE_PER_PIXEL * pixels) * pace *
                                 (1.0 + 0.8 * drowsy))
        self.saccade_overshoot = (SACCADE_OVERSHOOT * min(1.0, pixels / 40.0) *
                                  (1.0 - drowsy))
        if (not self.saccade_glide and pixels > LOOK_BLINK_PIXELS and
                self.mood in ("calm", "attentive") and self.expression != "surprised" and
                self.random.random() < LOOK_BLINK_CHANCE):
            self.begin_blink()

    def update_gaze(self, elapsed):
        target = (self.target_x, self.target_y)
        if target != self.saccade_to:
            self.begin_saccade(target)
        if not self.saccade_active:
            return
        if self.saccade_glide:
            self.attention_x = approach(self.attention_x, target[0], self.shift_speed, elapsed)
            self.attention_y = approach(self.attention_y, target[1], self.shift_speed, elapsed)
            if (abs(self.attention_x - target[0]) < 0.002 and
                    abs(self.attention_y - target[1]) < 0.002):
                self.saccade_active = False
            return
        self.saccade_time += elapsed
        progress = self.saccade_time / self.saccade_duration
        overshoot = self.saccade_overshoot
        if progress < 1.0:
            travel = (1.0 + overshoot) * smoothstep(progress ** 0.75)
        else:
            settle = (self.saccade_time - self.saccade_duration) / SACCADE_SETTLE
            travel = 1.0 + overshoot * (1.0 - smoothstep(settle))
            if settle >= 1.0:
                travel = 1.0
                self.saccade_active = False
        start_x, start_y = self.saccade_from
        self.attention_x = start_x + (target[0] - start_x) * travel
        self.attention_y = start_y + (target[1] - start_y) * travel

    def update_speech(self, elapsed):
        level, pitch, openness = self.voice_activity
        self.speech = approach(self.speech, level, 28.0, elapsed)
        self.speech_pitch = approach(self.speech_pitch, pitch, 14.0, elapsed)
        self.speech_open = approach(self.speech_open, openness, 18.0, elapsed)

    def update_stretch(self, elapsed):
        previous_x, previous_y = self.previous_attention
        self.previous_attention = (self.attention_x, self.attention_y)
        speed_x = speed_y = 0.0
        if self.saccade_active and not self.saccade_glide and elapsed > 0.0:
            speed_x = abs(self.attention_x - previous_x) * GAZE_PIXELS_X / elapsed
            speed_y = abs(self.attention_y - previous_y) * GAZE_PIXELS_Y / elapsed
        soften = 1.0 - 0.6 * self.drowsiness()
        self.stretch_x = approach(self.stretch_x,
                                  min(STRETCH_LIMIT, speed_x * STRETCH_PER_PIXEL_SPEED) * soften,
                                  35.0, elapsed)
        self.stretch_y = approach(self.stretch_y,
                                  min(STRETCH_LIMIT, speed_y * STRETCH_PER_PIXEL_SPEED) * soften,
                                  35.0, elapsed)

    def update_life(self, elapsed):
        if self.mood == "asleep":
            period = 6.0
        elif self.mood == "sleepy":
            period = 5.4
        elif self.expression in ("excited", "irritated", "surprised"):
            period = 2.9
        elif self.expression == "delighted":
            period = 3.4
        else:
            period = BREATH_PERIOD
        self.breath_period = approach(self.breath_period, period, 0.6, elapsed)
        self.breath_phase = (self.breath_phase + elapsed / self.breath_period) % 1.0
        angle = self.breath_phase * math.tau
        self.breath = (math.sin(angle) + 0.22 * math.sin(angle * 2.0)) / 1.1

        if (self.mood == "waking" or (self.mood == "asleep" and not self.dreaming) or
                self.saccade_active):
            self.micro_active = False
            self.micro_x = approach(self.micro_x, 0.0, 12.0, elapsed)
            self.micro_y = approach(self.micro_y, 0.0, 12.0, elapsed)
            self.micro_due = max(self.micro_due, self.elapsed + 0.25)
            return
        if self.micro_active:
            self.micro_time += elapsed
            travel = smoothstep(self.micro_time / self.micro_length)
            self.micro_x = self.micro_from[0] + (self.micro_to[0] - self.micro_from[0]) * travel
            self.micro_y = self.micro_from[1] + (self.micro_to[1] - self.micro_from[1]) * travel
            if self.micro_time >= self.micro_length:
                self.micro_active = False
            return
        self.micro_x = clamp(self.micro_x + self.drift[0] * elapsed, -MICRO_LIMIT, MICRO_LIMIT)
        self.micro_y = clamp(self.micro_y + self.drift[1] * elapsed, -MICRO_LIMIT, MICRO_LIMIT)
        if self.elapsed >= self.micro_due and self.dreaming:
            self.micro_from = (self.micro_x, self.micro_y)
            self.micro_to = (self.random.uniform(-5.0, 5.0), self.random.uniform(-1.0, 1.0))
            self.micro_time = 0.0
            self.micro_length = MICRO_DURATION
            self.micro_active = True
            self.micro_due = self.elapsed + self.random.uniform(0.12, 0.45)
        elif self.elapsed >= self.micro_due:
            drowsy = self.drowsiness()
            direction = self.random.uniform(0.0, math.tau)
            size = self.random.uniform(*MICRO_SIZE) * (1.0 - 0.45 * drowsy)
            target_x = -self.micro_x * 0.6 + math.cos(direction) * size
            target_y = -self.micro_y * 0.6 + math.sin(direction) * size * 0.7
            self.micro_from = (self.micro_x, self.micro_y)
            self.micro_to = (clamp(target_x, -MICRO_LIMIT, MICRO_LIMIT),
                             clamp(target_y, -MICRO_LIMIT, MICRO_LIMIT))
            self.micro_time = 0.0
            self.micro_length = MICRO_DURATION * (1.0 + 1.5 * drowsy)
            self.micro_active = True
            drift = self.random.uniform(0.0, math.tau)
            self.drift = (math.cos(drift) * DRIFT_SPEED, math.sin(drift) * DRIFT_SPEED * 0.7)
            focus = 1.8 if self.expression in ("attentive", "listening") else 1.0
            self.micro_due = (self.elapsed + self.random.uniform(*MICRO_INTERVAL) * focus *
                              (1.0 + 2.0 * drowsy))

    def update_expression_pose(self, elapsed):
        targets = self.expression_targets()
        speed = 13.0 if self.expression == "surprised" else 5.8
        self.pose_width = approach(self.pose_width, targets[0], speed, elapsed)
        self.pose_height = approach(self.pose_height, targets[1], speed, elapsed)
        self.pose_spacing = approach(self.pose_spacing, targets[2], speed, elapsed)
        self.pose_vertical = approach(self.pose_vertical, targets[3], speed, elapsed)
        self.pose_left_scale = approach(self.pose_left_scale, targets[4], speed, elapsed)
        self.pose_right_scale = approach(self.pose_right_scale, targets[5], speed, elapsed)
        self.pose_left_offset = approach(self.pose_left_offset, targets[6], speed, elapsed)
        self.pose_right_offset = approach(self.pose_right_offset, targets[7], speed, elapsed)
        self.pose_left_width = approach(self.pose_left_width, targets[8], speed, elapsed)
        self.pose_right_width = approach(self.pose_right_width, targets[9], speed, elapsed)

    def update_startup(self, elapsed):
        self.wake_time += elapsed / self.wake_slowness
        if self.wake_time < 0.28:
            self.openness = 0.0
        elif self.wake_time < 0.62:
            self.openness = 0.05
        elif self.wake_time < 0.92:
            self.openness = 0.32
        elif self.wake_time < 1.34:
            self.openness = approach(self.openness, 0.88, 7.0, elapsed)
        else:
            self.openness = approach(self.openness, 1.0, 8.0, elapsed)
        if self.wake_time >= 1.72:
            self.mood = "calm"
            self.blink_phase = "open"
            self.openness = 1.0
            self.set_attention(0.0, 0.0)
            self.reaction_lock_until = self.elapsed + 0.30
            self.decision_due = self.elapsed + self.random.uniform(2.6, 5.2)
            self.next_blink = self.elapsed + self.blink_interval()
            if self.requested_colour_index != self.colour_index:
                self.begin_blink("colour")
            elif self.first_meeting:
                self.finish_first_meeting()
            elif self.greet_on_wake:
                self.greet_on_wake = False
                self.begin_greeting()
            else:
                self.schedule_voice("wake", delay=0.24, probability=0.20)

    def update_rouse(self, elapsed):
        self.rouse_time += elapsed
        progress = smoothstep(self.rouse_time / 0.82)
        self.openness = self.rouse_start_openness + (1.0 - self.rouse_start_openness) * progress
        if self.rouse_time >= 0.82:
            self.mood = "calm"
            self.openness = 1.0
            self.expression = "calm"
            self.expression_until = self.elapsed
            self.reaction_lock_until = self.elapsed + 0.18
            self.decision_due = self.elapsed + self.random.uniform(2.8, 5.4)
            self.next_blink = self.elapsed + self.blink_interval()

    def update_blink(self, elapsed):
        if self.blink_phase in ("open", "sleeping"):
            return
        if self.blink_phase == "startup":
            return
        self.blink_time += elapsed
        close_time = {"colour": 0.075, "slow": 0.16}.get(self.blink_kind, 0.095)
        hold_time = {"colour": 0.075, "slow": 0.12}.get(self.blink_kind, 0.035)
        open_time = 0.32 if self.mood == "sleepy" or self.blink_kind == "slow" else 0.15
        if self.blink_phase == "closing":
            self.openness = self.blink_start_openness * (1.0 - smoothstep(self.blink_time / close_time))
            if self.blink_time >= close_time:
                self.openness = 0.0
                self.blink_phase = "closed"
                self.blink_time = 0.0
                if self.blink_kind == "colour":
                    self.colour_index = self.requested_colour_index
                    self.save_colour()
        elif self.blink_phase == "closed":
            if self.blink_time >= hold_time:
                self.blink_phase = "opening"
                self.blink_time = 0.0
        elif self.blink_phase == "opening":
            self.openness = self.blink_rest_openness * smoothstep(self.blink_time / open_time)
            if self.blink_time >= open_time:
                self.openness = self.blink_rest_openness
                self.blink_phase = "open"
                if self.double_blink_pending:
                    self.double_blink_pending = False
                    self.next_blink = self.elapsed + 0.16
                else:
                    multiplier = 1.45 if self.mood == "sleepy" else 1.0
                    self.next_blink = self.elapsed + self.blink_interval() * multiplier
                if self.blink_kind == "colour":
                    if self.colour_index != self.requested_colour_index:
                        self.begin_blink("colour")
                    else:
                        self.schedule_voice("acknowledge", delay=0.18,
                                            probability=0.38)

    def update(self, elapsed):
        elapsed = min(0.1, max(0.0, elapsed))
        self.elapsed += elapsed
        self.update_reset(elapsed)
        self.update_repaint(elapsed)
        if self.elapsed >= self.body_due:
            self.body_due = self.elapsed + BODY_POLL_INTERVAL
            self.update_body()
        if self.charging:
            self.comfort = approach(self.comfort, 0.85, 0.05, elapsed)
        self.idle += elapsed
        if self.elapsed - self.last_stimulus < 4.0 and self.elapsed > 4.0:
            self.familiarity += (elapsed * (1.0 - self.familiarity) /
                                 (FAMILIARITY_HOURS * 3600.0))
            self.time_together += elapsed
        if self.elapsed >= self.memory_save_due:
            self.memory_save_due = self.elapsed + MEMORY_SAVE_INTERVAL
            self.save_memory()
        self.stimulation = max(0.0, self.stimulation - STIMULUS_DECAY * elapsed)
        self.irritation = max(0.0, self.irritation - IRRITATION_DECAY * elapsed)
        self.curiosity = approach(self.curiosity, 0.62, CURIOSITY_RECOVERY, elapsed)
        self.comfort = approach(self.comfort, 0.72, COMFORT_RECOVERY, elapsed)
        self.interest_in_user = approach(self.interest_in_user, 0.45,
                                         INTEREST_DECAY, elapsed)

        if self.pending_reaction:
            remaining = self.pending_reaction["due"] - self.elapsed
            target = 1.0 if 0.0 < remaining < 0.13 else 0.0
            self.anticipation = approach(self.anticipation, target, 18.0, elapsed)
        else:
            self.anticipation = approach(self.anticipation, 0.0, 14.0, elapsed)
        self.apply_pending_reaction()
        self.apply_idle_followup()
        self.update_contact()
        self.update_script()
        self.update_touch(elapsed)

        if self.mood == "waking":
            self.update_startup(elapsed)
        elif self.mood == "rousing":
            self.update_rouse(elapsed)
        elif self.idle >= self.asleep_after():
            if self.mood != "asleep":
                self.sleep_progress = 0.0
                self.sleep_start_openness = clamp(self.openness)
                if self.blink_phase == "open":
                    self.asymmetry = 0.0
                self.blink_phase = "sleeping"
                self.double_blink_pending = False
                self.dream_due = self.elapsed + self.random.uniform(*DREAM_FIRST)
            self.mood = "asleep"
            self.update_dreams()
            self.sleep_progress = clamp(self.sleep_progress + elapsed / SLEEP_CLOSE_TIME)
            self.openness = self.sleep_start_openness * (1.0 - smoothstep(self.sleep_progress))
            self.return_attention_to_rest()
        elif self.idle >= self.sleepy_after():
            self.dreaming = False
            self.mood = "sleepy"
            self.expression = "sleepy"
            self.return_attention_to_rest()
            if self.blink_phase == "open":
                self.openness = approach(self.openness, 0.62, 0.45, elapsed)
            if self.blink_phase == "open" and self.elapsed >= self.next_blink:
                self.begin_blink("sleepy")
            if not self.sleepy_voice_used and self.idle > self.sleepy_after() + 18.0:
                self.sleepy_voice_used = True
                self.schedule_voice("sleepy", probability=0.28)
        else:
            self.dreaming = False
            self.sleepy_voice_used = False
            self.mood = "attentive" if self.stimulation > 0.42 else "calm"
            self.update_seeking()
            if self.blink_phase == "open":
                self.openness = approach(self.openness, 1.0, 8.0, elapsed)
            if self.elapsed >= self.next_blink and self.blink_phase == "open":
                self.begin_blink()
            if (not self.reset_hold and not self.script and
                    not self.sulking and not self.stroking and not self.rhythm_taps and
                    self.elapsed >= self.decision_due and self.blink_phase == "open" and
                    not self.pending_reaction and not self.idle_followup and
                    not self.stimulus_count and self.expression == "calm"):
                self.choose_attention()

        if (self.stimulus_count and self.mood not in ("waking", "rousing") and
                self.elapsed >= self.stimulus_due and
                self.elapsed >= self.reaction_lock_until and
                self.pending_reaction is None):
            self.consume_stimulus()

        if self.elapsed >= self.expression_until and self.expression not in ("sleepy",):
            self.expression = "calm"
            self.reactive_expression = False

        self.update_blink(elapsed)
        self.update_wink(elapsed)
        if self.attention_return_due and self.elapsed >= self.attention_return_due:
            self.return_attention_to_rest()
        if self.correction_pending and self.elapsed >= self.correction_due:
            self.correction_pending = False
            self.target_x = clamp(self.target_x + self.random.uniform(-0.065, 0.065), -1.0, 1.0)
            self.target_y = clamp(self.target_y + self.random.uniform(-0.04, 0.04), -1.0, 1.0)
        self.update_gaze(elapsed)
        self.update_stretch(elapsed)
        self.update_speech(elapsed)
        self.update_life(elapsed)
        self.update_expression_pose(elapsed)
        self.update_lids(elapsed)
        self.update_voice()

    def geometry(self):
        width_scale = self.pose_width
        height_scale = self.pose_height * (1.0 - 0.055 * self.anticipation)
        identity = self.identity
        spacing = self.pose_spacing + identity["eye_spacing"]
        vertical = self.pose_vertical
        left_scale = self.pose_left_scale
        right_scale = self.pose_right_scale
        left_offset = self.pose_left_offset
        right_offset = self.pose_right_offset

        if self.mood == "waking" and 0.52 <= self.wake_time < 1.08:
            if self.wake_left_first:
                right_scale *= 0.48
            else:
                left_scale *= 0.48

        openness = clamp(self.openness)
        if self.reset_hold:
            openness *= 1.0 - 0.97 * smoothstep(self.reset_hold / RESET_FORGET_TIME)
        depth = 1.4 if self.mood in ("sleepy", "asleep") else 1.0
        breath = self.breath * depth
        speech = self.speech
        speech_height = 1.0 + SPEECH_SWELL * speech * (0.6 + 0.4 * self.speech_open)
        speech_width = 1.0 + SPEECH_WIDEN * speech * max(0.0, -self.speech_open)
        base_width = (184.0 * identity["eye_width"] * width_scale * speech_width *
                      (1.0 + self.stretch_x - 0.5 * self.stretch_y))
        base_height = (154.0 * identity["eye_height"] * height_scale * speech_height *
                       (1.0 + BREATH_SWELL * breath) *
                       (1.0 + self.stretch_y - 0.5 * self.stretch_x))
        height = base_height * openness
        move_x = self.attention_x * GAZE_PIXELS_X + self.micro_x
        move_y = (self.attention_y * GAZE_PIXELS_Y + vertical + self.micro_y -
                  BREATH_LIFT * breath -
                  speech * (SPEECH_LIFT + SPEECH_PITCH_LIFT * max(0.0, self.speech_pitch)))
        centre_y = 240.0 + move_y
        asymmetry = self.asymmetry * (1.0 - openness) if self.blink_phase != "open" else 0.0
        slit = 4.0 + (1.2 * (breath + 1.0) if self.mood == "asleep" else 0.0)
        left_height = max(slit, height * left_scale * (1.0 - asymmetry) * self.left_wink)
        right_height = max(slit, height * right_scale * (1.0 + asymmetry) * self.right_wink)
        centre_x = 320.0 + move_x
        result = EyeGeometry(
            centre_x - spacing / 2.0,
            centre_x + spacing / 2.0,
            centre_y + left_offset,
            centre_y + right_offset,
            base_width * self.pose_left_width,
            base_width * self.pose_right_width,
            left_height,
            right_height,
            tuple(self.lids[0]),
            tuple(self.lids[1]),
            tuple(self.lids[2]),
            tuple(self.lids[3]),
            identity["eye_shape"],
        )
        return result


def eye_columns(centre_x, centre_y, width, height, inward,
                upper=OPEN_LID, lower=OPEN_LID, shape=4.0):
    half_width = width * 0.5
    half_height = height * 0.5
    upper_amount, upper_angle, upper_bend = upper
    lower_amount, lower_angle, lower_bend = lower
    soft = LID_SOFTNESS
    upper_hide = soft * max(0.0, 1.0 - upper_amount * height / (2.0 * soft))
    lower_hide = soft * max(0.0, 1.0 - lower_amount * height / (2.0 * soft))
    columns = []
    for column, profile in zip(EYE_COLUMNS, eye_profile(shape)):
        side = column * inward
        curve = 0.5 * (1.0 - side * side)
        top = centre_y - half_height * profile
        bottom = centre_y + half_height * profile
        lid = centre_y - half_height - upper_hide + height * (
            upper_amount + 0.5 * upper_angle * side + upper_bend * curve)
        if lid > top - soft:
            if lid >= top + soft:
                top = lid
            else:
                blend = 0.5 + 0.5 * (lid - top) / soft
                top += (lid - top) * blend + soft * blend * (1.0 - blend)
        lid = centre_y + half_height + lower_hide - height * (
            lower_amount + 0.5 * lower_angle * side + lower_bend * curve)
        if lid < bottom + soft:
            if lid <= bottom - soft:
                bottom = lid
            else:
                blend = 0.5 + 0.5 * (bottom - lid) / soft
                bottom += (lid - bottom) * blend - soft * blend * (1.0 - blend)
        if bottom < top:
            top = bottom = (top + bottom) * 0.5
        columns.append((centre_x + column * half_width, top, bottom))
    return columns


def geometry_columns(geometry):
    return (
        (eye_columns(geometry.left_x, geometry.left_y, geometry.left_width,
                     geometry.left_height, 1, geometry.left_upper,
                     geometry.left_lower, geometry.shape),
         geometry.left_y, geometry.left_height),
        (eye_columns(geometry.right_x, geometry.right_y, geometry.right_width,
                     geometry.right_height, -1, geometry.right_upper,
                     geometry.right_lower, geometry.shape),
         geometry.right_y, geometry.right_height),
    )


def frame_pacing_delay(deadline, now, step=FRAME_STEP):
    deadline += step
    if now - deadline > step:
        deadline = now
    remaining = deadline - now
    return deadline, math.ceil(remaining * 1000) if remaining >= 0.002 else 0


class SDLRect(ctypes.Structure):
    _fields_ = (("x", ctypes.c_int), ("y", ctypes.c_int),
                ("w", ctypes.c_int), ("h", ctypes.c_int))


class SDLKeysym(ctypes.Structure):
    _fields_ = (("scancode", ctypes.c_int), ("sym", ctypes.c_int),
                ("mod", ctypes.c_uint16), ("unused", ctypes.c_uint32))


class SDLKeyboardEvent(ctypes.Structure):
    _fields_ = (("type", ctypes.c_uint32), ("timestamp", ctypes.c_uint32),
                ("window_id", ctypes.c_uint32), ("state", ctypes.c_uint8),
                ("repeat", ctypes.c_uint8), ("padding2", ctypes.c_uint8),
                ("padding3", ctypes.c_uint8), ("keysym", SDLKeysym))


class SDLJoyAxisEvent(ctypes.Structure):
    _fields_ = (("type", ctypes.c_uint32), ("timestamp", ctypes.c_uint32),
                ("which", ctypes.c_int32), ("axis", ctypes.c_uint8),
                ("padding1", ctypes.c_uint8), ("padding2", ctypes.c_uint8),
                ("padding3", ctypes.c_uint8), ("value", ctypes.c_int16),
                ("padding4", ctypes.c_uint16))


class SDLJoyButtonEvent(ctypes.Structure):
    _fields_ = (("type", ctypes.c_uint32), ("timestamp", ctypes.c_uint32),
                ("which", ctypes.c_int32), ("button", ctypes.c_uint8),
                ("state", ctypes.c_uint8), ("padding1", ctypes.c_uint8),
                ("padding2", ctypes.c_uint8))


class SDLMouseMotionEvent(ctypes.Structure):
    _fields_ = (("type", ctypes.c_uint32), ("timestamp", ctypes.c_uint32),
                ("window_id", ctypes.c_uint32), ("which", ctypes.c_uint32),
                ("state", ctypes.c_uint32), ("x", ctypes.c_int32),
                ("y", ctypes.c_int32), ("xrel", ctypes.c_int32),
                ("yrel", ctypes.c_int32))


class SDLMouseButtonEvent(ctypes.Structure):
    _fields_ = (("type", ctypes.c_uint32), ("timestamp", ctypes.c_uint32),
                ("window_id", ctypes.c_uint32), ("which", ctypes.c_uint32),
                ("button", ctypes.c_uint8), ("state", ctypes.c_uint8),
                ("clicks", ctypes.c_uint8), ("padding1", ctypes.c_uint8),
                ("x", ctypes.c_int32), ("y", ctypes.c_int32))


class SDLEvent(ctypes.Union):
    _fields_ = (("type", ctypes.c_uint32), ("key", SDLKeyboardEvent),
                ("jaxis", SDLJoyAxisEvent), ("jbutton", SDLJoyButtonEvent),
                ("motion", SDLMouseMotionEvent), ("mouse_button", SDLMouseButtonEvent),
                ("padding", ctypes.c_uint8 * 56))


class SDLAudioSpec(ctypes.Structure):
    _fields_ = (("freq", ctypes.c_int), ("format", ctypes.c_uint16),
                ("channels", ctypes.c_uint8), ("silence", ctypes.c_uint8),
                ("samples", ctypes.c_uint16), ("padding", ctypes.c_uint16),
                ("size", ctypes.c_uint32), ("callback", ctypes.c_void_p),
                ("userdata", ctypes.c_void_p))


class Renderer:
    def __init__(self, profile=None):
        self.profile = Path(profile) if profile else None
        self.sdl = None
        names = ["libSDL2-2.0.so.0", "libSDL2.so", "SDL2.dll"]
        if os.environ.get("MOMO_SDL_DIR"):
            names.insert(0, str(Path(os.environ["MOMO_SDL_DIR"]) / "SDL2.dll"))
        for name in names:
            try:
                self.sdl = ctypes.CDLL(name)
                break
            except OSError:
                continue
        if self.sdl is None:
            raise RuntimeError("SDL2 runtime was not found")
        self.bind()
        self.sdl.SDL_SetHint(b"SDL_RENDER_SCALE_QUALITY", b"0")
        if self.sdl.SDL_Init(0x20 | 0x200 | (0x2000 if PORTMASTER else 0)) != 0:
            raise RuntimeError("SDL2 could not initialise video and joystick")
        flags = 4 if os.environ.get("MOMO_WINDOWED") else 0x00001005
        self.window = self.sdl.SDL_CreateWindow(b"MOMO", 0x2FFF0000, 0x2FFF0000,
                                                WIDTH, HEIGHT, flags)
        if not self.window:
            raise RuntimeError("SDL2 could not create the MOMO window")
        self.renderer = self.sdl.SDL_CreateRenderer(self.window, -1, 2 | 4)
        if not self.renderer:
            self.renderer = self.sdl.SDL_CreateRenderer(self.window, -1, 1)
        if not self.renderer:
            raise RuntimeError("SDL2 could not create the MOMO renderer")
        self.sdl.SDL_RenderSetLogicalSize(self.renderer, WIDTH, HEIGHT)
        try:
            self.render_geometry = self.sdl.SDL_RenderGeometry
            self.render_geometry.argtypes = (ctypes.c_void_p, ctypes.c_void_p,
                                             ctypes.c_void_p, ctypes.c_int,
                                             ctypes.c_void_p, ctypes.c_int)
            self.render_geometry.restype = ctypes.c_int
        except AttributeError:
            self.render_geometry = None
        columns = EYE_SAMPLES + 1
        self.vertex_count = columns * 4
        self.vertex_format = struct.Struct("<" + "ffBBBBff" * self.vertex_count)
        self.vertex_buffer = ctypes.create_string_buffer(self.vertex_format.size)
        indices = []
        for eye in range(2):
            base = eye * columns * 2
            for index in range(EYE_SAMPLES):
                top, bottom = base + index * 2, base + index * 2 + 1
                indices.extend((top, bottom, top + 2, bottom, bottom + 2, top + 2))
        self.index_count = len(indices)
        self.index_buffer = (ctypes.c_int * len(indices))(*indices)
        self.controller = None
        self.joystick = None
        if PORTMASTER:
            for index in range(self.sdl.SDL_NumJoysticks()):
                if self.sdl.SDL_IsGameController(index):
                    self.controller = self.sdl.SDL_GameControllerOpen(index)
                    if self.controller:
                        break
        if not self.controller and self.sdl.SDL_NumJoysticks():
            self.joystick = self.sdl.SDL_JoystickOpen(0)
        self.rectangle_buffer = (SDLRect * (EYE_SAMPLES * 2))()
        self.audio = 0
        self.voice = None
        self.fading_voice = None
        self.prepared = None
        self.prepared_for = None
        self.voice_detail = 2
        self.present_wait = 0.0
        self.identity = None
        self.voice_sent = 0
        self.audio_gaps = 0
        if self.sdl.SDL_InitSubSystem(0x10) == 0:
            wanted = SDLAudioSpec()
            obtained = SDLAudioSpec()
            wanted.freq = AUDIO_RATE
            wanted.format = 0x8010
            wanted.channels = AUDIO_CHANNELS
            wanted.samples = 512
            self.audio = self.sdl.SDL_OpenAudioDevice(
                None, 0, ctypes.byref(wanted), ctypes.byref(obtained), 0)
            if self.audio:
                self.sdl.SDL_PauseAudioDevice(self.audio, 0)
            else:
                self.log_audio_error("SDL_OpenAudioDevice")
        else:
            self.log_audio_error("SDL_InitSubSystem")

    def bind(self):
        for name in ("SDL_CreateWindow", "SDL_CreateRenderer", "SDL_JoystickOpen",
                     "SDL_GameControllerOpen"):
            getattr(self.sdl, name).restype = ctypes.c_void_p
        self.sdl.SDL_GameControllerOpen.argtypes = (ctypes.c_int,)
        self.sdl.SDL_IsGameController.argtypes = (ctypes.c_int,)
        self.sdl.SDL_IsGameController.restype = ctypes.c_int
        self.sdl.SDL_GameControllerClose.argtypes = (ctypes.c_void_p,)
        self.sdl.SDL_CreateWindow.argtypes = (ctypes.c_char_p, ctypes.c_int, ctypes.c_int,
                                              ctypes.c_int, ctypes.c_int, ctypes.c_uint32)
        self.sdl.SDL_CreateRenderer.argtypes = (ctypes.c_void_p, ctypes.c_int, ctypes.c_uint32)
        self.sdl.SDL_SetHint.argtypes = (ctypes.c_char_p, ctypes.c_char_p)
        self.sdl.SDL_RenderSetLogicalSize.argtypes = (ctypes.c_void_p, ctypes.c_int, ctypes.c_int)
        self.sdl.SDL_SetRenderDrawColor.argtypes = (ctypes.c_void_p, ctypes.c_uint8,
                                                    ctypes.c_uint8, ctypes.c_uint8,
                                                    ctypes.c_uint8)
        self.sdl.SDL_RenderClear.argtypes = (ctypes.c_void_p,)
        self.sdl.SDL_RenderFillRects.argtypes = (ctypes.c_void_p,
                                                 ctypes.POINTER(SDLRect), ctypes.c_int)
        self.sdl.SDL_RenderPresent.argtypes = (ctypes.c_void_p,)
        self.sdl.SDL_PollEvent.argtypes = (ctypes.POINTER(SDLEvent),)
        self.sdl.SDL_JoystickClose.argtypes = (ctypes.c_void_p,)
        self.sdl.SDL_DestroyRenderer.argtypes = (ctypes.c_void_p,)
        self.sdl.SDL_DestroyWindow.argtypes = (ctypes.c_void_p,)
        self.sdl.SDL_Delay.argtypes = (ctypes.c_uint32,)
        self.sdl.SDL_OpenAudioDevice.restype = ctypes.c_uint32
        self.sdl.SDL_OpenAudioDevice.argtypes = (
            ctypes.c_char_p, ctypes.c_int, ctypes.POINTER(SDLAudioSpec),
            ctypes.POINTER(SDLAudioSpec), ctypes.c_int)
        self.sdl.SDL_QueueAudio.argtypes = (
            ctypes.c_uint32, ctypes.c_void_p, ctypes.c_uint32)
        self.sdl.SDL_MixAudioFormat.argtypes = (
            ctypes.c_void_p, ctypes.c_void_p, ctypes.c_uint16,
            ctypes.c_uint32, ctypes.c_int)
        self.sdl.SDL_MixAudioFormat.restype = None
        self.sdl.SDL_PauseAudioDevice.argtypes = (ctypes.c_uint32, ctypes.c_int)
        self.sdl.SDL_CloseAudioDevice.argtypes = (ctypes.c_uint32,)
        self.sdl.SDL_GetQueuedAudioSize.argtypes = (ctypes.c_uint32,)
        self.sdl.SDL_GetQueuedAudioSize.restype = ctypes.c_uint32
        self.sdl.SDL_GetError.restype = ctypes.c_char_p

    def log_audio_error(self, operation):
        if not self.profile:
            return
        error = self.sdl.SDL_GetError()
        message = error.decode("utf8", "replace") if error else "unknown SDL error"
        try:
            self.profile.mkdir(parents=True, exist_ok=True)
            (self.profile / "audio_error.log").write_text(
                operation + ": " + message + "\n", encoding="utf8")
        except OSError:
            pass

    def play_voice(self, intent, variation, mood=None):
        if not self.audio:
            return False
        if self.voice:
            fade = int(AUDIO_RATE * VOICE_INTERRUPT_FADE)
            self.fading_voice = [self.voice, fade, fade]
        self.voice_sent = 0
        if self.prepared and self.prepared.intent == intent:
            self.voice = self.prepared
        else:
            self.voice = VoiceStream(intent, variation, detail=self.voice_detail, mood=mood,
                                     identity=self.identity)
        self.prepared = None
        self.prepared_for = None
        return True

    def prepare_voice(self, pending, frame_step=FRAME_STEP):
        if not self.audio:
            return
        if pending is None:
            self.prepared = None
            self.prepared_for = None
            return
        if pending is not self.prepared_for:
            self.prepared_for = pending
            self.prepared = VoiceStream(pending["intent"], detail=self.voice_detail,
                                        mood=pending.get("mood"), identity=self.identity)
        stream = self.prepared
        if stream.position < stream.total:
            share = 0.35 if self.voice else 1.0
            stream.render(max(64, int(AUDIO_RATE * frame_step * share)))

    def voice_activity(self):
        if not self.audio or not self.voice:
            return 0.0, 0.0, 0.0
        queued = self.sdl.SDL_GetQueuedAudioSize(self.audio) // AUDIO_FRAME_BYTES
        return self.voice.activity(max(0, self.voice_sent - queued +
                                       int(SPEECH_LEAD * AUDIO_RATE)))

    def mix_voice(self, destination, stream, samples, volume=128):
        data = stream.read(samples)
        if data:
            source = ctypes.create_string_buffer(data, len(data))
            self.sdl.SDL_MixAudioFormat(destination, source, 0x8010, len(data), volume)
        return len(data) // AUDIO_FRAME_BYTES

    def pump_audio(self, frame_step=FRAME_STEP):
        if not self.audio:
            return
        lead = max(AUDIO_LEAD, frame_step * 2.5)
        wanted = int(AUDIO_RATE * lead) * AUDIO_FRAME_BYTES
        queued = self.sdl.SDL_GetQueuedAudioSize(self.audio)
        if not queued and self.voice:
            self.audio_gaps += 1
        needed = wanted - queued
        needed -= needed % AUDIO_FRAME_BYTES
        if needed < 256 * AUDIO_FRAME_BYTES:
            return
        chunk = ctypes.create_string_buffer(needed)
        destination = ctypes.addressof(chunk)
        samples = needed // AUDIO_FRAME_BYTES
        fading = self.fading_voice
        if fading:
            stream, left, total = fading
            step = max(1, total // VOICE_FADE_STEPS)
            offset = 0
            while offset < samples and left > 0 and not stream.done:
                take = self.mix_voice(destination + offset * AUDIO_FRAME_BYTES, stream,
                                      min(step, left, samples - offset),
                                      int(128 * left / total))
                left -= take
                offset += take
            fading[1] = left
            if left <= 0 or stream.done:
                self.fading_voice = None
        if self.voice:
            self.voice_sent += self.mix_voice(destination, self.voice, samples)
            if self.voice.done:
                self.voice = None
        self.sdl.SDL_QueueAudio(self.audio, chunk, needed)

    def draw(self, momo):
        self.sdl.SDL_SetRenderDrawColor(self.renderer, 0, 0, 0, 255)
        self.sdl.SDL_RenderClear(self.renderer)
        eyes = geometry_columns(momo.geometry())
        red, green, blue = (channel * momo.brightness
                            for channel in FORM_PALETTE[momo.colour_index])
        if self.render_geometry:
            values = []
            extend = values.extend
            for columns, centre_y, height in eyes:
                eye_top = centre_y - height * 0.5
                fade = EYE_GRADIENT_FADE / max(1.0, height)
                red_fade, green_fade, blue_fade = red * fade, green * fade, blue * fade
                for x, top, bottom in columns:
                    down_top = max(0.0, top - eye_top)
                    down_bottom = max(0.0, bottom - eye_top)
                    extend((x, top, int(red - red_fade * down_top),
                            int(green - green_fade * down_top),
                            int(blue - blue_fade * down_top), 255, 0.0, 0.0,
                            x, bottom, int(red - red_fade * down_bottom),
                            int(green - green_fade * down_bottom),
                            int(blue - blue_fade * down_bottom), 255, 0.0, 0.0))
            self.vertex_format.pack_into(self.vertex_buffer, 0, *values)
            if self.render_geometry(self.renderer, None, self.vertex_buffer,
                                    self.vertex_count, self.index_buffer,
                                    self.index_count) != 0:
                self.render_geometry = None
        if not self.render_geometry:
            count = 0
            for columns, _, _ in eyes:
                for (x0, t0, b0), (x1, t1, b1) in zip(columns, columns[1:]):
                    left, right = int(round(x0)), int(round(x1))
                    top, bottom = int(round((t0 + t1) * 0.5)), int(round((b0 + b1) * 0.5))
                    if right > left and bottom > top:
                        self.rectangle_buffer[count] = SDLRect(left, top, right - left,
                                                               bottom - top)
                        count += 1
            shade = 1.0 - EYE_GRADIENT_FADE * 0.5
            self.sdl.SDL_SetRenderDrawColor(self.renderer, int(red * shade),
                                            int(green * shade), int(blue * shade), 255)
            self.sdl.SDL_RenderFillRects(self.renderer, self.rectangle_buffer, count)
        presented = time.perf_counter()
        self.sdl.SDL_RenderPresent(self.renderer)
        self.present_wait = time.perf_counter() - presented

    def close(self):
        if self.audio:
            self.sdl.SDL_CloseAudioDevice(self.audio)
        if getattr(self, "controller", None):
            self.sdl.SDL_GameControllerClose(self.controller)
        if self.joystick:
            self.sdl.SDL_JoystickClose(self.joystick)
        self.sdl.SDL_DestroyRenderer(self.renderer)
        self.sdl.SDL_DestroyWindow(self.window)
        self.sdl.SDL_Quit()


DPAD_INTERACTIONS = {8: "surprise", 9: "soothe", 10: "tease", 11: "greet"}
BUTTON_INTERACTIONS = {0: "startle", 2: "play", 3: "watch",
                       4: "edge_left", 5: "edge_right",
                       6: "flinch", 7: "peek"}
KEY_BUTTONS = {
    82: 8, 81: 9, 80: 10, 79: 11,
    29: 1, 44: 1,
    27: 0,
    4: 4, 22: 5,
    20: 6, 26: 7,
    40: 13, 42: 12,
    6: 2, 25: 3,
}


CONTROLLER_BUTTONS = {
    0: 1,
    1: 0,
    2: 2,
    3: 3,
    4: 12,
    6: 13,
    9: 4,
    10: 5,
    11: 8,
    12: 9,
    13: 10,
    14: 11,
}
CONTROLLER_TRIGGERS = {4: 6, 5: 7}
TRIGGER_PRESS = 16000
TRIGGER_RELEASE = 8000


def controller_button(momo, pressed_buttons, button, down):
    internal = CONTROLLER_BUTTONS.get(button)
    if internal is None:
        return False
    return joystick_button(momo, pressed_buttons, internal, down)


def controller_trigger(momo, pressed_buttons, trigger_state, axis, value):
    internal = CONTROLLER_TRIGGERS[axis]
    held = trigger_state.get(axis, False)
    if not held and value > TRIGGER_PRESS:
        trigger_state[axis] = True
        return joystick_button(momo, pressed_buttons, internal, True)
    if held and value < TRIGGER_RELEASE:
        trigger_state[axis] = False
        return joystick_button(momo, pressed_buttons, internal, False)
    return False


def joystick_button(momo, pressed_buttons, button, down):
    if update_protected_exit(pressed_buttons, button, down):
        return True
    if down and button not in (12, 13):
        handle_button(momo, button)
    elif not down and button in (4, 5, 6, 7):
        momo.release_shoulder(button)
    return False


def stick_axis(momo, axis_state, axis, value):
    direction = axis_direction(value)
    if direction != axis_state[axis]:
        axis_state[axis] = direction
        if direction:
            if axis in (0, 1):
                momo.stimulus(direction if axis == 0 else 0,
                              direction if axis == 1 else 0, 0.8)
            elif axis == 2:
                momo.interact("edge_left" if direction < 0 else "edge_right")
            else:
                momo.interact("lean_in" if direction < 0 else "withdraw")


def axis_direction(value):
    if value < -14000:
        return -1
    if value > 14000:
        return 1
    return 0


def handle_button(momo, button):
    if button in (4, 5):
        momo.press_shoulder(button)
    if button == 1:
        momo.interact("boop")
    elif button == 2:
        momo.tap_rhythm()
    elif button in DPAD_INTERACTIONS:
        momo.interact(DPAD_INTERACTIONS[button])
    elif button in BUTTON_INTERACTIONS:
        momo.interact(BUTTON_INTERACTIONS[button])


def update_protected_exit(pressed_buttons, button, down):
    if down:
        pressed_buttons.add(button)
    else:
        pressed_buttons.discard(button)
    return 12 in pressed_buttons and 13 in pressed_buttons


def handle_key(momo, pressed_buttons, scancode, down, repeat=False):
    if scancode == 41:
        return down
    button = KEY_BUTTONS.get(scancode)
    if button is None:
        return False
    if not repeat and update_protected_exit(pressed_buttons, button, down):
        return True
    if button in (12, 13):
        return False
    if down and not repeat:
        handle_button(momo, button)
    elif not down and button in (4, 5, 6, 7):
        momo.release_shoulder(button)
    return False


class WindowsMouseInput:

    def __init__(self):
        self.last_position = None
        self.last_motion = None
        self.armed = False
        self.notice_origin = None
        self.hover_side = None
        self.hover_position = None
        self.hover_since = 0.0
        self.hover_sent = False
        self.left_press = None
        self.last_eye_click = None
        self.pending_space_click = None

    @staticmethod
    def eye_at(momo, x, y):
        geometry = momo.geometry()
        for side, centre_x, centre_y, width, height in (
            ("left", geometry.left_x, geometry.left_y,
             geometry.left_width, geometry.left_height),
            ("right", geometry.right_x, geometry.right_y,
             geometry.right_width, geometry.right_height),
        ):
            if (abs(x - centre_x) <= width / 2 + 22 and
                    abs(y - centre_y) <= max(height / 2, 48) + 22):
                return side
        return None

    def motion(self, momo, x, y):
        now = momo.elapsed
        previous = self.last_position
        quiet = self.last_motion is not None and now - self.last_motion >= 2.5
        self.last_position = (x, y)
        self.last_motion = now
        if self.left_press is not None:
            return
        side = self.eye_at(momo, x, y)
        if side != self.hover_side:
            self.hover_side = side
            self.hover_position = (x, y)
            self.hover_since = now
            self.hover_sent = False
        elif side and self.hover_position and (
                (x - self.hover_position[0]) ** 2 +
                (y - self.hover_position[1]) ** 2 > 8 ** 2):
            self.hover_position = (x, y)
            self.hover_since = now
        if previous is None or now < WAKE_LOCK_TIME:
            return
        if quiet:
            self.armed = True
            self.notice_origin = previous
        origin = self.notice_origin
        if self.armed and origin and (
                (x - origin[0]) ** 2 + (y - origin[1]) ** 2 >= 38 ** 2):
            self.armed = False
            self.notice_origin = None
            momo.receive_stimulus("watch", (x - WIDTH / 2) / (WIDTH / 2),
                                  (y - HEIGHT / 2) / (HEIGHT / 2), 0.20)

    def button_down(self, momo, button, x, y):
        self.armed = False
        self.notice_origin = None
        self.last_position = (x, y)
        self.last_motion = momo.elapsed
        if button == 3:
            momo.cycle_colour()
        elif button == 1:
            self.left_press = (momo.elapsed, x, y)
            self.hover_side = None

    def button_up(self, momo, button, x, y):
        if button != 1 or self.left_press is None:
            return
        started, start_x, start_y = self.left_press
        self.left_press = None
        duration = momo.elapsed - started
        dx, dy = x - start_x, y - start_y
        self.last_position = (x, y)
        self.last_motion = momo.elapsed
        if dx * dx + dy * dy >= 55 ** 2:
            self.pending_space_click = None
            self.last_eye_click = None
            magnitude = math.hypot(dx, dy)
            momo.stimulus(dx / magnitude, dy / magnitude, 0.80)
            return
        side = self.eye_at(momo, x, y)
        if duration >= 0.65:
            self.pending_space_click = None
            self.last_eye_click = None
            momo.interact("soothe" if side else "watch")
        elif side:
            self.pending_space_click = None
            prior = self.last_eye_click
            if (prior and prior[0] == side and momo.elapsed - prior[1] <= 0.38 and
                    (x - prior[2]) ** 2 + (y - prior[3]) ** 2 <= 40 ** 2):
                self.last_eye_click = None
                momo.interact("flinch" if side == "left" else "peek")
            else:
                self.last_eye_click = (side, momo.elapsed, x, y)
                momo.interact("edge_left" if side == "left" else "edge_right")
        else:
            prior = self.pending_space_click
            if (prior and momo.elapsed - prior[0] <= 0.38 and
                    (x - prior[1]) ** 2 + (y - prior[2]) ** 2 <= 40 ** 2):
                self.pending_space_click = None
                momo.interact("play")
            else:
                if prior:
                    momo.interact("startle")
                self.pending_space_click = (momo.elapsed, x, y)

    def update(self, momo):
        if (self.pending_space_click and
                momo.elapsed - self.pending_space_click[0] >= 0.38):
            self.pending_space_click = None
            momo.interact("startle")
        if (self.hover_side and not self.hover_sent and self.left_press is None and
                momo.elapsed >= WAKE_LOCK_TIME and
                momo.elapsed - self.hover_since >= 1.0):
            self.hover_sent = True
            momo.interact("soothe")


def voice_speed():
    VoiceStream("acknowledge", detail=2, seed=1).render(4000)
    best = 0.0
    for _ in range(2):
        started = time.perf_counter()
        stream = VoiceStream("phrase_pleased", detail=2, seed=1)
        stream.render(stream.total)
        best = max(best, stream.total / AUDIO_RATE /
                   max(1e-6, time.perf_counter() - started))
    return best


HISTORY_LIMIT = 48000
_history = {"path": None, "started": time.monotonic()}


def start_history(profile):
    path = Path(profile) / "history.txt"
    try:
        path.parent.mkdir(parents=True, exist_ok=True)
        if path.exists() and path.stat().st_size > HISTORY_LIMIT:
            text = path.read_text(encoding="utf8", errors="replace")
            path.write_text(text[-HISTORY_LIMIT // 2:].split("\n", 1)[-1], encoding="utf8")
        _history["path"] = path
        _history["started"] = time.monotonic()
        stamp = (time.strftime("%Y-%m-%d %H:%M") if time.time() >= CLOCK_TRUSTED_FROM
                 else "clock unknown")
        with path.open("a", encoding="utf8") as stream:
            stream.write("\n--- session, %s\n" % stamp)
    except OSError:
        _history["path"] = None


def log(message):
    print("MOMO: " + message, flush=True)
    if _history["path"]:
        try:
            with _history["path"].open("a", encoding="utf8") as stream:
                stream.write("%6ds  %s\n" % (time.monotonic() - _history["started"], message))
        except OSError:
            pass


def run(profile):
    try:
        signal.signal(signal.SIGTERM, lambda *_: sys.exit(0))
    except (ValueError, OSError, AttributeError):
        pass
    start_history(profile)
    momo = Momo(profile)
    renderer = Renderer(profile)
    platform = PLATFORM
    mouse = WindowsMouseInput() if platform in ("windows", "linux") else None
    power_monitor = (PowerMonitor() if HANDHELD
                     else None)
    trigger_state = {}
    event = SDLEvent()
    axis_state = {0: 0, 1: 0, 2: 0, 3: 0}
    pressed_buttons = set()
    running = True
    previous = time.monotonic()
    frame_deadline = time.perf_counter()
    accumulator = 0.0
    gc.collect()
    gc.freeze()
    speed = voice_speed()
    renderer.voice_detail = (2 if speed >= VOICE_DETAIL_SPEED[0] else
                             1 if speed >= VOICE_DETAIL_SPEED[1] else 0)
    log("voice synthesis runs at %.1fx real time; voice detail %d of 2" %
        (speed, renderer.voice_detail))
    frames = 0
    work_total = work_worst = 0.0
    session = {"frames": 0, "work": 0.0, "worst": 0.0, "gaps": 0, "sleeps": 0}
    slept_this_frame = False
    last_boot_clock = boot_clock()
    last_monotonic = time.monotonic()
    report_due = time.monotonic() + 60.0
    try:
        while running:
            work_started = time.perf_counter()
            now = time.monotonic()
            elapsed = min(0.08, now - previous)
            previous = now
            accumulator = min(0.1, accumulator + elapsed)
            while renderer.sdl.SDL_PollEvent(ctypes.byref(event)):
                if event.type == 0x100:
                    running = False
                elif mouse and event.type == 0x400:
                    mouse.motion(momo, event.motion.x, event.motion.y)
                elif mouse and event.type == 0x401:
                    mouse.button_down(momo, event.mouse_button.button,
                                      event.mouse_button.x, event.mouse_button.y)
                elif mouse and event.type == 0x402:
                    mouse.button_up(momo, event.mouse_button.button,
                                    event.mouse_button.x, event.mouse_button.y)
                elif not mouse and event.type in (0x300, 0x301):
                    if handle_key(momo, pressed_buttons,
                                  event.key.keysym.scancode,
                                  event.type == 0x300,
                                  bool(event.key.repeat)):
                        running = False
                elif renderer.controller and event.type in (0x651, 0x652):
                    if controller_button(momo, pressed_buttons, event.jbutton.button,
                                         event.type == 0x651):
                        running = False
                elif renderer.controller and event.type == 0x650:
                    axis = event.jaxis.axis
                    if axis in CONTROLLER_TRIGGERS:
                        if controller_trigger(momo, pressed_buttons, trigger_state,
                                              axis, event.jaxis.value):
                            running = False
                    elif axis in axis_state:
                        stick_axis(momo, axis_state, axis, event.jaxis.value)
                elif renderer.controller:
                    pass
                elif not mouse and event.type in (0x603, 0x604):
                    if joystick_button(momo, pressed_buttons, event.jbutton.button,
                                       event.type == 0x603):
                        running = False
                elif not mouse and event.type == 0x600 and event.jaxis.axis in axis_state:
                    stick_axis(momo, axis_state, event.jaxis.axis, event.jaxis.value)
            momo.reset_held = RESET_BUTTONS <= pressed_buttons
            momo.select_only = pressed_buttons == {12}
            if mouse:
                mouse.update(momo)
            while accumulator >= BEHAVIOUR_STEP:
                momo.update(BEHAVIOUR_STEP)
                accumulator -= BEHAVIOUR_STEP
            if power_monitor and power_monitor.poll(momo.elapsed):
                momo.power_connected()
            now_boot, now_monotonic = boot_clock(), time.monotonic()
            if now_boot is not None and last_boot_clock is not None:
                slept = (now_boot - last_boot_clock) - (now_monotonic - last_monotonic)
                if slept > DEVICE_SLEEP_NOTICED:
                    momo.device_slept(slept)
                    slept_this_frame = True
                    session["sleeps"] += 1
            last_boot_clock, last_monotonic = now_boot, now_monotonic
            step = (SLEEP_FRAME_STEP if momo.mood == "asleep" and momo.openness <= 0.02 and
                    not momo.dreaming
                    else FRAME_STEP)
            renderer.identity = momo.identity
            voice = momo.take_voice()
            if voice:
                renderer.play_voice(*voice)
            renderer.prepare_voice(momo.pending_voice, step)
            renderer.pump_audio(step)
            momo.voice_activity = renderer.voice_activity()
            renderer.draw(momo)
            work = time.perf_counter() - work_started - renderer.present_wait
            if slept_this_frame:
                slept_this_frame = False
            else:
                frames += 1
                work_total += work
                work_worst = max(work_worst, work)
                session["frames"] += 1
                session["work"] += work
                session["worst"] = max(session["worst"], work)
            if now >= report_due and frames:
                log("frame work %.1f ms average, %.1f ms worst, %d audio gaps" %
                    (work_total / frames * 1000, work_worst * 1000, renderer.audio_gaps))
                session["gaps"] += renderer.audio_gaps
                frames = 0
                work_total = work_worst = 0.0
                renderer.audio_gaps = 0
                report_due = now + 60.0
            frame_deadline, delay = frame_pacing_delay(
                frame_deadline, time.perf_counter(), step)
            if delay:
                renderer.sdl.SDL_Delay(delay)
    finally:
        momo.save_memory()
        if session["frames"]:
            log("session ended after %s: frame work %.1f ms average, %.1f ms worst; "
                "%d audio gaps; voice detail %d; device slept %d times" % (
                    describe_duration(time.monotonic() - _history["started"]),
                    session["work"] / session["frames"] * 1000, session["worst"] * 1000,
                    session["gaps"] + renderer.audio_gaps, renderer.voice_detail,
                    session["sleeps"]))
        renderer.close()


if __name__ == "__main__":
    profile_path = sys.argv[1] if len(sys.argv) > 1 else str(Path.home() / ".momo")
    run(profile_path)


