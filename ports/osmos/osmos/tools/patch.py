import sys

def find_close_matches(data, pattern1, pattern2, window_size=64):
    # Find all positions of each pattern
    positions1 = [(i, pattern1) for i in range(len(data) - len(pattern1) + 1) if data[i:i+len(pattern1)] == pattern1]
    positions2 = [(i, pattern2) for i in range(len(data) - len(pattern2) + 1) if data[i:i+len(pattern2)] == pattern2]

    # Try to find two of each pattern within the window
    for i1 in range(len(positions1)):
        for i2 in range(i1 + 1, len(positions1)):
            for j1 in range(len(positions2)):
                for j2 in range(j1 + 1, len(positions2)):
                    match_set = [positions1[i1], positions1[i2], positions2[j1], positions2[j2]]
                    offsets = [offset for offset, _ in match_set]
                    if max(offsets) - min(offsets) <= window_size:
                        return sorted(match_set)

    return None

def patch_data(data, matches, replacements):
    patched = bytearray(data)
    for offset, original_bytes in matches:
        if original_bytes in replacements:
            new_bytes = replacements[original_bytes]
            patched[offset:offset+len(original_bytes)] = new_bytes
    return patched

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <input_file> <output_file>")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    print("Applying resolution hack on", input_file)

    try:
        with open(input_file, 'rb') as f:
            data = f.read()
    except FileNotFoundError:
        print(f"Error: File '{input_file}' not found.")
        sys.exit(1)
    result = find_close_matches(data, b'\x20\x03', b'\x58\x02')

    if result:
        print("Match found at:")
        for offset, bytes_matched in result:
            hex_str = ' '.join(f"{b:02X}" for b in bytes_matched)
            print(f"  Offset 0x{offset:08X}: {hex_str}")

        # Define what to replace
        replacements = {
            b'\x20\x03': b'\xE0\x01',  # 0x320 → 0x1E0
            b'\x58\x02': b'\x40\x01'   # 0x258 → 0x140
        }

        patched_data = patch_data(data, result, replacements)

        with open(output_file, 'wb') as f:
            f.write(patched_data)

        print(f"\nPatched binary written to '{output_file}'")

    else:
        print("No matching sequence found. Nothing patched.")

