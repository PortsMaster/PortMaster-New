#!/usr/bin/env python3
import os
import sys

def modify_code_game_init(gml_dir):
    """Append performance initialization to gml_Object_code_game_init_Create_0.gml"""
    filename = "gml_Object_code_game_init_Create_0.gml"
    file_path = os.path.join(gml_dir, filename)

    if not os.path.isfile(file_path):
        print(f"Warning: {filename} not found, skipping.")
        return

    append_lines = [
        "global.framecounter = 0;",
        'ini_open("config.ini");',
        'global.frameskip = ini_read_real("Performance", "FrameSkip", 0);',
        'global.IdolSFX = ini_read_real("Performance", "IdolSFX", 1);',
        "ini_close();"
    ]

    with open(file_path, "r") as f:
        lines = f.readlines()

    lines += [line + "\n" for line in append_lines]

    with open(file_path, "w") as f:
        f.writelines(lines)


def modify_god_gem_draw(gml_dir):
    """Replace the entire draw code in gml_Object_obj_god_gem_slot_controller_Draw_0.gml"""
    filename = "gml_Object_obj_god_gem_slot_controller_Draw_0.gml"
    file_path = os.path.join(gml_dir, filename)

    if not os.path.isfile(file_path):
        print(f"Warning: {filename} not found, skipping.")
        return

    new_code = [
        "if (global.IdolSFX == 1) {",
        "    if (!surface_exists(global.smallDrawingSurface)) {",
        "        global.smallDrawingSurface = surface_create(384, 216);",
        "        drawSurfaceSmall = global.smallDrawingSurface;",
        "    }",
        "",
        "    global.framecounter++;",
        "",
        "    if (global.framecounter >= global.frameskip) {",
        "        global.framecounter = 0;",
        "        surface_set_target(drawSurfaceSmall);",
        "        draw_clear_alpha(c_white, 0);",
        "        var angleIncrement = angleInc;",
        "",
        "        for (var i = 0; i < gemCount; i++) {",
        "            with (self.gemArray[i]) {",
        "                var angle = angle_clamp(point_direction(x, y, focalPointX, focalPointY) - angleIncrement);",
        "                var x2 = focalPointX;",
        "                var y2 = focalPointY;",
        "                draw_set_color(lineColor);",
        "                draw_line_curved_width(x, y, x2, y2, angle, false, 8, 3);",
        "                draw_line_curved_width(x, y, x2, y2, angle, true, 8, 3);",
        "            }",
        "        }",
        "",
        "        surface_reset_target();",
        "    }",
        "",
        "    draw_surface(drawSurfaceSmall, 0, 0);",
        "}"
    ]

    with open(file_path, "w") as f:
        f.writelines(line + "\n" for line in new_code)


def insert_font_cleanup(gml_dir):
    """Insert font clearing block before font_setup() in localization_load_language()"""
    filename = "gml_GlobalScript_localization_functions.gml"
    file_path = os.path.join(gml_dir, filename)

    if not os.path.isfile(file_path):
        print(f"Warning: {filename} not found, skipping.")
        return

    insert_block = [
        "if (ds_exists(global.fontMap, ds_type_map))",
        "{",
        "    var key = ds_map_find_first(global.fontMap);",
        "    while (!is_undefined(key))",
        "    {",
        "        var font = ds_map_find_value(global.fontMap, key);",
        "        if (font_exists(font))",
        "            font_delete(font);",
        "        key = ds_map_find_next(global.fontMap, key);",
        "    }",
        "    ds_map_clear(global.fontMap);",
        "}"
    ]

    with open(file_path, "r") as f:
        lines = f.readlines()

    new_lines = []
    inserted = False

    for line in lines:
        stripped = line.strip()
        if not inserted and stripped.startswith("font_setup(arg0)"):
            # Insert block before font_setup
            for insert_line in insert_block:
                new_lines.append(insert_line + "\n")
            inserted = True
        new_lines.append(line)

    with open(file_path, "w") as f:
        f.writelines(new_lines)

    if not inserted:
        print(f"Could not find insertion point in {filename}, skipping.")


def replace_font_add_to_map(gml_dir):
    """Replace the font_add_to_font_map() function entirely"""
    filename = "gml_GlobalScript_localization_functions.gml"
    file_path = os.path.join(gml_dir, filename)

    if not os.path.isfile(file_path):
        print(f"Warning: {filename} not found, skipping.")
        return

    new_function = [
        "function font_add_to_font_map(arg0, arg1)",
        "{",
        "    if (ds_map_exists(global.fontMap, arg0))",
        "    {",
        "        var oldFont = ds_map_find_value(global.fontMap, arg0);",
        "        if (!is_undefined(oldFont) && font_exists(oldFont))",
        "            font_delete(oldFont);",
        "        ds_map_replace(global.fontMap, arg0, arg1);",
        "    }",
        "    else",
        "    {",
        "        ds_map_add(global.fontMap, arg0, arg1);",
        "    }",
        "}"
    ]

    with open(file_path, "r") as f:
        lines = f.readlines()

    new_lines = []
    in_function = False
    brace_count = 0

    for line in lines:
        stripped = line.strip()
        if stripped.startswith("function font_add_to_font_map"):
            in_function = True
            brace_count = 0
            new_lines.extend([l + "\n" for l in new_function])
            continue

        if in_function:
            brace_count += line.count("{") - line.count("}")
            if brace_count <= 0:
                in_function = False
            continue

        new_lines.append(line)

    with open(file_path, "w") as f:
        f.writelines(new_lines)


def main(gml_dir):
    modify_code_game_init(gml_dir)
    modify_god_gem_draw(gml_dir)
    insert_font_cleanup(gml_dir)
    replace_font_add_to_map(gml_dir)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: mod.py <gml_directory>")
        sys.exit(1)
    main(sys.argv[1])
