#!/usr/bin/env python3
import os
import sys

def modify_toriel_handhold(gml_dir):
    """Fix obj_mainchara.y calculation in obj_torhandhold1 Create event"""
    filename = "gml_Object_obj_torhandhold1_Create_0.gml"
    file_path = os.path.join(gml_dir, filename)

    if not os.path.isfile(file_path):
        print(f"Warning: {filename} not found, skipping.")
        return

    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Replace the specific line
    old_line = "obj_mainchara.y = y + 28;"
    new_line = "obj_mainchara.y = round(y);"

    if old_line in content:
        content = content.replace(old_line, new_line)
        
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(content)
        
        print(f"Successfully modified {filename}")
    else:
        print(f"Warning: Could not find target line in {filename}, skipping.")


def main(gml_dir):
    print("Fixing Toriel positioning...")
    modify_toriel_handhold(gml_dir)
    print("Modification complete!")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: fix_toriel_handhold.py <gml_directory>")
        sys.exit(1)
    main(sys.argv[1])
