#!/usr/bin/env python3
import sys
import os
import re

# --- REGEX DEFINITIONS ---
# Matches a section header like [Video]
SECTION_RE = re.compile(r'^\s*\[(.+?)\]\s*$')
# Matches an active option like 'key = value'
ACTIVE_OPTION_RE = re.compile(r'^\s*([^#;].*?)\s*=\s*(.*)$')
# Matches a commented option like '# key = value' or '; key = value'
COMMENTED_OPTION_RE = re.compile(r'^\s*[#;]+\s*([^=]+?)\s*=\s*(.*)$')


def parse_patch_file(patch_path):
    """
    Parses a source/patch config file into a structured dictionary.
    The structure is: {section: {option: {'value': str, 'is_commented': bool}}}
    """
    if not os.path.exists(patch_path):
        print(f"Error: Patch file '{patch_path}' not found.")
        return None

    patch_data = {}
    current_section = None
    with open(patch_path, 'r', encoding='utf-8') as f:
        for line in f:
            section_match = SECTION_RE.match(line)
            if section_match:
                current_section = section_match.group(1).strip()
                if current_section not in patch_data:
                    patch_data[current_section] = {}
                continue

            if not current_section:
                continue

            # Check for commented options first, as they are more specific
            commented_match = COMMENTED_OPTION_RE.match(line)
            if commented_match:
                key = commented_match.group(1).strip()
                value = commented_match.group(2).strip()
                patch_data[current_section][key] = {'value': value, 'is_commented': True}
                continue
                
            active_match = ACTIVE_OPTION_RE.match(line)
            if active_match:
                key = active_match.group(1).strip()
                value = active_match.group(2).strip()
                patch_data[current_section][key] = {'value': value, 'is_commented': False}

    return patch_data

def apply_patch(target_path, patch_data):
    """
    Applies the parsed patch_data to the target file.
    Returns the modified list of lines.
    """
    if not os.path.exists(target_path):
        print(f"Warning: Target file '{target_path}' not found. Creating a new one.")
        target_lines = []
    else:
        with open(target_path, 'r', encoding='utf-8') as f:
            target_lines = f.readlines()

    applied_options = set()
    current_section = None

    # --- Pass 1: Iterate through target and update/comment existing options ---
    for i, line in enumerate(target_lines):
        section_match = SECTION_RE.match(line)
        if section_match:
            current_section = section_match.group(1).strip()
        
        if not current_section:
            continue
            
        # Check both active and commented lines in the target file
        active_match = ACTIVE_OPTION_RE.match(line)
        commented_match = COMMENTED_OPTION_RE.match(line)
        match = active_match or commented_match
        
        if match:
            key = match.group(1).strip()
            
            if current_section in patch_data and key in patch_data[current_section]:
                patch_info = patch_data[current_section][key]
                indentation = line[:len(line) - len(line.lstrip())]
                
                if patch_info['is_commented']:
                    new_line = f"#{key} = {patch_info['value']}\n"
                    print(f"Commenting out option '{key}' in section '[{current_section}]'.")
                else:
                    new_line = f"{key} = {patch_info['value']}\n"
                    print(f"Updating option '{key}' in section '[{current_section}]'.")
                
                target_lines[i] = indentation + new_line
                applied_options.add((current_section, key))

    # --- Pass 2: Add any new options from the patch that weren't in the target ---
    for section, options in patch_data.items():
        for key, patch_info in options.items():
            if (section, key) in applied_options:
                continue

            # This option needs to be added
            print(f"Adding new option '{key}' to section '[{section}]'.")
            
            if patch_info['is_commented']:
                new_line = f"#{key} = {patch_info['value']}\n"
            else:
                new_line = f"{key} = {patch_info['value']}\n"
            
            # Find where to insert the new line
            section_found_at = -1
            for i, line in enumerate(target_lines):
                section_match = SECTION_RE.match(line)
                if section_match and section_match.group(1).strip() == section:
                    section_found_at = i
                    break
            
            if section_found_at != -1:
                # Section exists, find its end to append the option
                insert_pos = len(target_lines)
                for i in range(section_found_at + 1, len(target_lines)):
                    if SECTION_RE.match(target_lines[i]):
                        insert_pos = i
                        break
                # Backtrack to avoid inserting into blank lines
                while insert_pos > 0 and not target_lines[insert_pos - 1].strip():
                    insert_pos -= 1
                target_lines.insert(insert_pos, new_line)
            else:
                # Section does not exist, add it to the end
                print(f"Creating new section '[{section}]'.")
                if target_lines and target_lines[-1].strip() != "":
                    target_lines.append("\n")
                target_lines.append(f"[{section}]\n")
                target_lines.append(new_line)
                
    return target_lines

def main():
    if len(sys.argv) == 4 and sys.argv[1] == "-merge":
        target_file = sys.argv[2]
        patch_file = sys.argv[3]
        
        print(f"Merging '{patch_file}' into '{target_file}'...")
        patch_data = parse_patch_file(patch_file)
        if patch_data is None:
            sys.exit(1)
            
        modified_lines = apply_patch(target_file, patch_data)
        
    elif len(sys.argv) == 5 and sys.argv[1] == "-delete":
        target_file = sys.argv[2]
        section = sys.argv[3]
        option = sys.argv[4]

        # A "delete" is just a merge with a single, commented-out option.
        # The value doesn't matter, so we use an empty string.
        patch_data = {
            section: {
                option: {'value': '', 'is_commented': True}
            }
        }
        modified_lines = apply_patch(target_file, patch_data)

    elif len(sys.argv) == 5:
        target_file = sys.argv[1]
        section = sys.argv[2]
        option = sys.argv[3]
        value = sys.argv[4]
        
        # An "update" is just a merge with a single, active option.
        patch_data = {
            section: {
                option: {'value': value, 'is_commented': False}
            }
        }
        modified_lines = apply_patch(target_file, patch_data)

    else:
        print("Usage:")
        print("  Merge:   settings_cfg.py -merge <target.cfg> <source.cfg>")
        print("  Delete:  settings_cfg.py -delete <target.cfg> <Section> <Option>")
        print("  Update:  settings_cfg.py <target.cfg> <Section> <Option> <Value>")
        sys.exit(1)

    # Safely write the final result
    temp_path = target_file + ".tmp"
    try:
        with open(temp_path, 'w', encoding='utf-8') as f:
            f.writelines(modified_lines)
        os.replace(temp_path, target_file)
        print("Successfully wrote changes.")
        sys.exit(0)
    except Exception as e:
        print(f"Error writing to file: {e}")
        if os.path.exists(temp_path):
            os.remove(temp_path)
        sys.exit(1)

if __name__ == "__main__":
    main()
