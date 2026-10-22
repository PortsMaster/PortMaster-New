#!/usr/bin/env python3
"""
Station North SNfetchPLAYER - Native InnerTube Mobile Client Stream Extractor
Portiert aus dem Android-Original (NativeInnerTubeExtractor.kt).
Nutzt gezielt offizielle Android- & VR-Client-Kennungen zur Umgehung von
YouTube-Web-Bot-Sperren, SABR-Drosselung und 429-Rate-Limits.
Liefert direkte googlevideo Stream-URLs in unter 0.4 Sekunden.
"""

import json
import logging
import urllib.request
from typing import Optional, Tuple

logging.basicConfig(level=logging.INFO, format="[%(asctime)s] [%(levelname)s] %(message)s")

PLAYER_ENDPOINT = "https://www.youtube.com/youtubei/v1/player"

CLIENT_PROFILES = [
    {
        "name": "ANDROID",
        "clientName": "ANDROID",
        "clientVersion": "21.02.35",
        "userAgent": "com.google.android.youtube/21.02.35 (Linux; U; Android 11) gzip",
        "androidSdkVersion": 30,
        "osName": "Android",
        "osVersion": "11"
    },
    {
        "name": "ANDROID_VR",
        "clientName": "ANDROID_VR",
        "clientVersion": "1.65.10",
        "userAgent": "com.google.android.apps.youtube.vr.oculus/1.65.10 (Linux; U; Android 12L; eureka-user Build/SQ3A.220605.009.A1) gzip",
        "deviceMake": "Oculus",
        "deviceModel": "Quest 3",
        "androidSdkVersion": 32,
        "osName": "Android",
        "osVersion": "12L"
    }
]

_cache = {}

def get_stream(video_id: str, prefer_audio_only: bool = False) -> Tuple[Optional[str], Optional[str]]:
    """
    Ruft die direkte googlevideo Stream-URL für eine YouTube Video-ID ab.
    Gibt (url, quality_label) zurück.
    """
    cache_key = f"{video_id}_{'audio' if prefer_audio_only else 'video'}"
    if cache_key in _cache:
        logging.info(f"Stream-URL aus Cache geladen für {video_id}")
        return _cache[cache_key]

    for profile in CLIENT_PROFILES:
        try:
            client_ctx = {
                "clientName": profile["clientName"],
                "clientVersion": profile["clientVersion"],
                "hl": "en",
                "gl": "US",
                "androidSdkVersion": profile["androidSdkVersion"],
                "osName": profile["osName"],
                "osVersion": profile["osVersion"]
            }
            if "deviceMake" in profile:
                client_ctx["deviceMake"] = profile["deviceMake"]
                client_ctx["deviceModel"] = profile["deviceModel"]

            payload = {
                "videoId": video_id,
                "context": {
                    "client": client_ctx
                }
            }

            headers = {
                "User-Agent": profile["userAgent"],
                "Content-Type": "application/json",
                "Origin": "https://www.youtube.com"
            }

            req = urllib.request.Request(
                PLAYER_ENDPOINT,
                data=json.dumps(payload).encode("utf-8"),
                headers=headers
            )
            with urllib.request.urlopen(req, timeout=8) as resp:
                data = json.loads(resp.read().decode("utf-8"))

            playability = data.get("playabilityStatus", {})
            status = playability.get("status")
            if status != "OK":
                reason = playability.get("reason", "Unbekannt")
                logging.debug(f"Client {profile['name']} Status {status} ({reason}) für {video_id}")
                continue

            streaming = data.get("streamingData", {})

            # Audio-Only Mode
            if prefer_audio_only:
                adaptive = streaming.get("adaptiveFormats", [])
                for f in adaptive:
                    mime = f.get("mimeType", "")
                    if "audio" in mime and f.get("url"):
                        url = f.get("url")
                        quality = f.get("audioQuality", "AUDIO")
                        _cache[cache_key] = (url, quality)
                        logging.info(f"Erfolg [{profile['name']}] Audio-Stream für {video_id}")
                        return url, quality

            # TV Video Mode: Target 480p/360p for handheld display & battery optimization
            formats = streaming.get("formats", [])
            valid_formats = [f for f in formats if f.get("url")]
            if valid_formats:
                def format_score(f):
                    h = f.get("height", 0)
                    if not h:
                        ql = f.get("qualityLabel", "")
                        if "480" in ql: h = 480
                        elif "360" in ql: h = 360
                        elif "720" in ql: h = 720
                        elif "1080" in ql: h = 1080
                        else: h = 360
                    # Prefer height <= 480 (480 is best, 360 is second best, >480 is worse)
                    return h if h <= 480 else (480 - h)

                best_f = max(valid_formats, key=format_score)
                url = best_f.get("url")
                quality = best_f.get("qualityLabel", "480p")
                _cache[cache_key] = (url, quality)
                logging.info(f"Erfolg [{profile['name']}] Video-Stream ({quality}) für {video_id}")
                return url, quality

            # Fallback auf adaptive Formats (prefer height <= 480)
            adaptive_videos = [f for f in streaming.get("adaptiveFormats", []) if f.get("url") and "video" in f.get("mimeType", "")]
            if adaptive_videos:
                best_af = max(adaptive_videos, key=lambda f: f.get("height", 360) if f.get("height", 360) <= 480 else (480 - f.get("height", 360)))
                url = best_af.get("url")
                quality = best_af.get("qualityLabel", "360p")
                _cache[cache_key] = (url, quality)
                return url, quality

        except Exception as e:
            logging.debug(f"Fehler mit Client {profile['name']}: {e}")

    logging.error(f"Alle Client-Profile fehlgeschlagen für {video_id}")
    return None, None

if __name__ == "__main__":
    import sys
    test_id = sys.argv[1] if len(sys.argv) > 1 else "GxBSyx85Kp8"
    print(f"Teste Extraktion für ID: {test_id}...")
    stream_url, q = get_stream(test_id)
    if stream_url:
        print(f"Erfolg! Qualität: {q}")
        print(f"URL: {stream_url[:90]}...")
    else:
        print("Fehler beim Abruf.")
