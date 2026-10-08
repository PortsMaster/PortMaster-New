import hashlib
import json

from pathlib import Path

BUILD_CRITICAL_ATTR_KEYS = {"runtime", "arch", "reqs"}

def get_port_build_hash(port_json_data: dict) -> str:
    if not isinstance(port_json_data, dict):
        return ""

    filtered = {
        "name": port_json_data.get("name"),
        "items": sorted(port_json_data.get("items", []) or []),
        "items_opt": sorted(port_json_data.get("items_opt", []) or []),
        "attr": {
            k: port_json_data.get("attr", {}).get(k)
            for k in BUILD_CRITICAL_ATTR_KEYS
            if k in port_json_data.get("attr", {})
            },
        }

    serialized = json.dumps(filtered, sort_keys=True, separators=(",", ":"))
    return hashlib.md5(serialized.encode("utf-8")).hexdigest()

manifest_file = Path("releases/manifest.json")
if not manifest_file.is_file():
    print("Error: releases/manifest.json not found!")
    exit(1)

with open(manifest_file, "r") as f:
    manifest = json.load(f)

ports_dir = Path("ports")
count = 0

for port_dir in sorted(ports_dir.iterdir()):
    if not port_dir.is_dir():
        continue

    port_json_file = port_dir / "port.json"
    if not port_json_file.is_file():
        continue

    rel_path = f"{port_dir.name}/port.json"
    if rel_path in manifest:
        try:
            with open(port_json_file, "r") as f:
                port_data = json.load(f)

            old_hash = manifest[rel_path]
            build_hash = get_port_build_hash(port_data)

            manifest[f"{rel_path}:v2"] = f"{build_hash}:{old_hash}"
            count += 1
        except Exception as e:
            print(f"Error processing {rel_path}: {e}")

manifest["0000.version"] = "2.0"

with open(manifest_file, "w") as f:
    json.dump(manifest, f, indent=2, sort_keys=True)

print(f"Successfully backfilled {count} port entries with :v2 build hashes.")