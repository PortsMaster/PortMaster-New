#!/usr/bin/env python3
"""
Playtime lookup tool (streamed, cached lookup results only)
"""
import csv
import io
import json
import os
import re
import sys
import time
import urllib.request

CACHE_DIR = "/tmp/file_cache"
PLAYTIME_CACHE_FILE = os.path.join(CACHE_DIR, "playtime_lookup_cache.json")
PLAYTIME_CACHE_EXPIRY = 7 * 24 * 3600  # 7 days

PLAYMYDATA_URLS = {
    "nintendo": "https://huggingface.co/datasets/claudioDsi94/PlayMyData/resolve/main/all_games_Nintendo.csv",
    "playstation": "https://huggingface.co/datasets/claudioDsi94/PlayMyData/resolve/main/all_games_PlayStation.csv",
}

HLTB_URLS = [
    "https://raw.githubusercontent.com/KasumiL5x/hltb-scraper/master/all-games-processed.csv",
    "https://raw.githubusercontent.com/KasumiL5x/hltb-scraper/main/all-games-processed.csv",
]

PLAYMYDATA_PLATFORM_FAMILY = {
    "Game Boy": "nintendo",
    "Game Boy Color": "nintendo",
    "Game Boy Advance": "nintendo",
    "NES": "nintendo",
    "Famicom Disk System": "nintendo",
    "SNES": "nintendo",
    "Nintendo DS": "nintendo",
    "Nintendo 64": "nintendo",
    "PlayStation 1": "playstation",
    "PSP": "playstation",
}

HLTB_PLATFORM_ALIASES = {
    "Game Gear": ["Game Gear", "Sega Game Gear"],
    "Master System": ["Sega Master System", "Sega Master System/Mark III", "Master System"],
    "Genesis": ["Sega Mega Drive/Genesis", "Mega Drive", "Genesis"],
    "Saturn": ["Sega Saturn", "Saturn"],
    "Dreamcast": ["Dreamcast", "Sega Dreamcast"],
    "PC Engine": ["TurboGrafx-16/PC Engine", "TurboGrafx-16", "PC Engine"],
}

RETRO_PLATFORMS = {
    "Game Boy",
    "Game Boy Color",
    "Game Boy Advance",
    "NES",
    "Famicom Disk System",
    "SNES",
    "Game Gear",
    "Master System",
    "Genesis",
    "Saturn",
    "Dreamcast",
    "PlayStation 1",
    "PSP",
    "Nintendo DS",
    "Nintendo 64",
    "PC Engine",
}


def ensure_cache_dir():
    if not os.path.exists(CACHE_DIR):
        os.makedirs(CACHE_DIR, exist_ok=True)


def is_cache_valid(cache_file, expiry_seconds):
    if not os.path.exists(cache_file):
        return False
    cache_time = os.path.getmtime(cache_file)
    return (time.time() - cache_time) < expiry_seconds


def load_playtime_cache():
    ensure_cache_dir()
    if is_cache_valid(PLAYTIME_CACHE_FILE, PLAYTIME_CACHE_EXPIRY):
        try:
            with open(PLAYTIME_CACHE_FILE, "r") as f:
                return json.load(f)
        except Exception:
            pass
    return {"meta": {"created": int(time.time()), "version": 1}, "entries": {}}


def save_playtime_cache(cache):
    ensure_cache_dir()
    try:
        with open(PLAYTIME_CACHE_FILE, "w") as f:
            json.dump(cache, f)
    except Exception:
        pass


def normalize_title(filename):
    name = os.path.basename(filename)

    for ext in [".p8.png", ".tar.gz"]:
        if name.lower().endswith(ext):
            name = name[: -len(ext)]

    name, _ = os.path.splitext(name)

    name = re.sub(r"\[[^\]]*\]", " ", name)
    name = re.sub(r"\([^)]*\)", " ", name)
    name = re.sub(r"\{[^}]*\}", " ", name)

    name = re.sub(r"\b(disc|disk|cd|dvd|side|part|vol|volume)\s*\d+\b", " ", name, flags=re.I)
    name = re.sub(r"\b(cd|disc)\s*[a-z]\b", " ", name, flags=re.I)

    name = name.replace("_", " ").replace(".", " ")
    name = re.sub(r"[^a-zA-Z0-9\s]+", " ", name)
    name = re.sub(r"\s+", " ", name).strip().lower()
    return name


def parse_float(value):
    if value is None:
        return None
    value = str(value).strip()
    if value == "" or value.lower() in {"missing", "null"}:
        return None
    try:
        return float(value)
    except ValueError:
        return None


def open_csv_stream(url, timeout=120):
    req = urllib.request.Request(url)
    req.add_header("User-Agent", "Playtime Lookup/1.0")
    response = urllib.request.urlopen(req, timeout=timeout)
    text = io.TextIOWrapper(response, encoding="utf-8", errors="ignore")
    reader = csv.DictReader(text)
    return response, reader


def platform_matches(platform_name, platform_list):
    aliases = HLTB_PLATFORM_ALIASES.get(platform_name, [])
    if not aliases:
        return False
    for p in platform_list:
        pl = p.lower()
        for alias in aliases:
            if alias.lower() in pl:
                return True
    return False


def estimate_hours(main, extra, completionist):
    values = [v for v in [main, extra, completionist] if v is not None]
    if not values:
        return None
    return round(sum(values) / len(values), 2)


def lookup_playmydata_stream(family, key):
    url = PLAYMYDATA_URLS.get(family)
    if not url:
        return None
    response = None
    try:
        response, reader = open_csv_stream(url, timeout=120)
        for row in reader:
            title = row.get("name") or row.get("title")
            if not title:
                continue
            if normalize_title(title) != key:
                continue
            main = parse_float(row.get("main"))
            extra = parse_float(row.get("extra"))
            completionist = parse_float(row.get("completionist"))
            est = estimate_hours(main, extra, completionist)
            return {
                "source": f"playmydata_{family}",
                "title": title,
                "estimated_hours": est,
                "main": main,
                "extra": extra,
                "completionist": completionist,
            }
    finally:
        if response:
            response.close()
    return None


def lookup_hltb_stream(platform_name, key):
    fallback = None
    for url in HLTB_URLS:
        response = None
        try:
            response, reader = open_csv_stream(url, timeout=180)
            for row in reader:
                title = row.get("title")
                if not title:
                    continue
                if normalize_title(title) != key:
                    continue
                platforms_raw = row.get("platforms", "")
                platforms = [p.strip() for p in platforms_raw.split(",") if p.strip()]
                main = parse_float(row.get("main_story"))
                extra = parse_float(row.get("main_plus_extras"))
                completionist = parse_float(row.get("completionist"))
                est = estimate_hours(main, extra, completionist)

                entry = {
                    "source": "hltb_scraper",
                    "title": title,
                    "estimated_hours": est,
                    "main": main,
                    "extra": extra,
                    "completionist": completionist,
                }

                if platform_matches(platform_name, platforms):
                    return entry
                if fallback is None:
                    fallback = {**entry, "note": "platform_match_fallback"}
        except Exception:
            continue
        finally:
            if response:
                response.close()
    return fallback


def get_playtime_info(platform_name, filename):
    if platform_name not in RETRO_PLATFORMS:
        return None

    key = normalize_title(filename)
    if not key:
        return None

    cache_key = f"{platform_name}::{key}"
    cache = load_playtime_cache()
    cached = cache.get("entries", {}).get(cache_key)
    if cached is not None:
        return cached

    family = PLAYMYDATA_PLATFORM_FAMILY.get(platform_name)
    if family:
        entry = lookup_playmydata_stream(family, key)
        if entry:
            cache["entries"][cache_key] = entry
            save_playtime_cache(cache)
            return entry

    entry = lookup_hltb_stream(platform_name, key)
    if entry:
        cache["entries"][cache_key] = entry
        save_playtime_cache(cache)
        return entry

    return None


def main():
    if len(sys.argv) != 4 or sys.argv[1] != "--playtime":
        print("Usage: python3 playtime.py --playtime <platform_name> <file_filename>")
        sys.exit(1)

    platform = sys.argv[2]
    file_name = sys.argv[3]
    info = get_playtime_info(platform, file_name)

    if info:
        print(json.dumps({"status": "success", "playtime": info}, indent=2))
    else:
        print(json.dumps({"status": "not_found", "playtime": None}, indent=2))


if __name__ == "__main__":
    main()
