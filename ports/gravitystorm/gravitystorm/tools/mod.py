#!/usr/bin/env python3
import os
import sys

def modify_scatter_explode(gml_dir):
    """Add lifetime and fade_start variables to particles in scatter_explode function"""
    filename = "gml_GlobalScript_scatter_explode.gml"
    file_path = os.path.join(gml_dir, filename)

    if not os.path.isfile(file_path):
        print(f"Warning: {filename} not found, skipping.")
        return

    with open(file_path, "r") as f:
        lines = f.readlines()

    new_lines = []
    
    for i, line in enumerate(lines):
        new_lines.append(line)
        stripped = line.strip()
        
        # After the first loop's image_index assignment, add lifetime variables
        if "_creation.image_index = arg1 + _times;" in stripped:
            new_lines.append("        _creation.lifetime = 600;  // 5 seconds at 30fps (or 300 for 60fps)\n")
            new_lines.append("        _creation.fade_start = 90;  // Start fading 1 second before destruction\n")
        
        # After the second loop's sprite_index assignment, add lifetime variables
        if "_creation.sprite_index = choose(s_bolt, s_particle_gray);" in stripped:
            new_lines.append("        _creation.lifetime = 600;  // 5 seconds at 30fps (or 300 for 60fps)\n")
            new_lines.append("        _creation.fade_start = 90;  // Start fading 1 second before destruction\n")

    with open(file_path, "w") as f:
        f.writelines(new_lines)



def modify_particle_step(gml_dir):
    """Add lifetime countdown and fade logic to o_particle Step event"""
    filename = "gml_Object_o_particle_Step_0.gml"
    file_path = os.path.join(gml_dir, filename)

    if not os.path.isfile(file_path):
        print(f"Warning: {filename} not found, skipping.")
        return

    with open(file_path, "r") as f:
        lines = f.readlines()

    # Lifetime code to append at the end
    lifetime_code = [
        "\n",
        "// Lifetime countdown with fade\n",
        "if (variable_instance_exists(id, \"lifetime\"))\n",
        "{\n",
        "    lifetime--;\n",
        "    \n",
        "    // Fade out during the last fade_start frames\n",
        "    if (lifetime <= fade_start)\n",
        "    {\n",
        "        image_alpha = lifetime / fade_start;  // Gradually fade from 1 to 0\n",
        "    }\n",
        "    \n",
        "    if (lifetime <= 0)\n",
        "    {\n",
        "        instance_destroy();\n",
        "    }\n",
        "}\n"
    ]

    # Simply append the lifetime code at the end of the file
    new_lines = lines + lifetime_code
    
    with open(file_path, "w") as f:
        f.writelines(new_lines)


def main(gml_dir):
    print("Modifying particle system for lifetime management...")
    modify_scatter_explode(gml_dir)
    modify_particle_step(gml_dir)
    print("Particle lifetime modifications complete!")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: particle_lifetime_mod.py <gml_directory>")
        sys.exit(1)
    main(sys.argv[1])
