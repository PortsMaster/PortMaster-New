#!/usr/bin/env python3
import os
import sys

def write_dummy_function(file_path, function_name):
    """Completely replace file contents with a no-op function."""
    if not os.path.isfile(file_path):
        print(f"Warning: {os.path.basename(file_path)} not found, skipping.")
        return

    dummy_code = [
        f"function {function_name}()",
        "{",
        "}"
    ]

    with open(file_path, "w") as f:
        f.write("\n".join(dummy_code) + "\n")

def main(gml_dir):
    targets = {
        "gml_GlobalScript_scr_load_palette_shader.gml": "scr_load_palette_shader",
        "gml_GlobalScript_scr_draw_palette_shader.gml": "scr_draw_palette_shader",
    }

    for filename, func_name in targets.items():
        file_path = os.path.join(gml_dir, filename)
        write_dummy_function(file_path, func_name)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: mod.py <gml_directory>")
        sys.exit(1)
    main(sys.argv[1])
