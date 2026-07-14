#!/usr/bin/env python3
import os
import re
import sys
import zipfile
from pathlib import Path

CODE = "6Ev2GlK1sWoCa5MfQ0pj43DH8Rzi9UnX"
REV = {c: i for i, c in enumerate(CODE)}
ENTRY = "bully/MenuSettings.xml"
KEY = "Bully"


def hkey(key):
    h = 5381
    for b in key.encode("ascii"):
        h = ((h * 33) + b) & 0xFFFFFFFF
    return h


def step(h):
    hi = ((h * 0x724287F5) >> 32) & 0xFFFFFFFF
    q = (hi + (((h - hi) & 0xFFFFFFFF) >> 1)) >> 7
    r = (h - (q * 177)) & 0xFFFFFFFF
    return ((r * 171) - (q * 2)) & 0xFFFFFFFF


def decode5(s):
    out = bytearray()
    acc = 0
    bits = 0
    for ch in s:
        if ch not in REV:
            continue
        acc = (acc << 5) | REV[ch]
        bits += 5
        while bits >= 8:
            bits -= 8
            out.append((acc >> bits) & 0xFF)
            acc &= (1 << bits) - 1 if bits else 0
    return bytes(out)


def encode5(data):
    out = []
    acc = 0
    bits = 0
    for b in data:
        acc = (acc << 8) | b
        bits += 8
        while bits >= 5:
            bits -= 5
            out.append(CODE[(acc >> bits) & 31])
            acc &= (1 << bits) - 1 if bits else 0
    if bits:
        out.append(CODE[(acc << (5 - bits)) & 31])
    return "".join(out).encode("ascii")


def decode(encoded):
    if encoded[:2] != b"Wx":
        raise SystemExit("unexpected MenuSettings.xml prefix")
    raw = decode5(encoded[2:].decode("ascii"))
    h = hkey(KEY)
    plain = bytearray()
    for i, b in enumerate(raw):
        h = step(h)
        plain.append(((b ^ ((i * 6 + 18) & 0xFF)) + h) & 0xFF)
    return plain.decode("utf-8")


def encode(text):
    h = hkey(KEY)
    raw = bytearray()
    for i, b in enumerate(text.encode("utf-8")):
        h = step(h)
        raw.append(((b - h) & 0xFF) ^ ((i * 6 + 18) & 0xFF))
    return b"Wx" + encode5(raw)


def menu_profile(profile):
    profile = (profile or "medium").strip().lower()
    if profile in ("low", "256", "verylow", "emergency", "extreme"):
        return "0", "Low"
    if profile in ("high", "full", "native", "original", "off", "none", "1024"):
        return "2", "High"
    return "1", "Medium"


def light_profile(profile):
    profile = (profile or "off").strip().lower()
    if profile in ("low", "spec", "specular", "s"):
        return "1", "Low"
    if profile in ("medium", "med", "normal", "n"):
        return "2", "Medium"
    if profile in ("high", "full", "both", "on", "1", "true", "yes"):
        return "3", "High"
    return "0", "Off"


def update_existing_profile_row(xml, name, value, text):
    def replace(match):
        row = match.group(1)
        row = re.sub(r'^<SettingRowOption\b', "<SettingRowTextureOption", row)
        row = re.sub(r'\sstring\(value\)="[^"]*"', "", row)
        row = re.sub(r'\sstring\(textvalue\)="[^"]*"', "", row)
        return '%s string(textvalue)="%s"/>' % (row, text)

    return re.sub(
        r'(<SettingRow(?:Texture)?Option name="%s"[^>]*)/>' % re.escape(name),
        replace,
        xml,
        count=1,
    )


def ensure_texture_template(xml, value, text):
    template_re = re.compile(
        r'(<SettingRow template="SettingRowTextureOption"[^>]*>.*?</SettingRow>\r?\n\r?\n)',
        re.S,
    )
    xml = template_re.sub("", xml)
    option_re = re.compile(
        r'(<SettingRow template="SettingRowOption" command="rotate" '
        r'string\(value\)="0" string\(textvalue\)="Test">.*?</SettingRow>\r?\n\r?\n)',
        re.S,
    )
    match = option_re.search(xml)
    if not match:
        raise SystemExit("SettingRowOption template pattern not found")
    texture_template = match.group(1)
    texture_template = texture_template.replace(
        'template="SettingRowOption"',
        'template="SettingRowTextureOption"',
        1,
    )
    texture_template = re.sub(
        r'string\(value\)="[^"]*"',
        'string(value)=""',
        texture_template,
        count=1,
    )
    texture_template = re.sub(
        r'string\(textvalue\)="[^"]*"',
        'string(textvalue)="%s"' % text,
        texture_template,
        count=1,
    )
    return xml[:match.end()] + texture_template + xml[match.end():]


def profile_row(name, caption, value, text, y1, y2):
    return (
        '    <SettingRowTextureOption name="%s" caption="%s" '
        'string(textvalue)="%s" '
        'y1="%.2f" y2="%.2f" opacity="1"/>\r\n'
        % (name, caption, text, y1, y2)
    )


def ensure_opacity_line(xml, name, anchor):
    line = "        \\main.content.%s.opacity.set(1)\r\n" % name
    if line in xml:
        return xml
    anchor_line = "        \\main.content.%s.opacity.set(1)\r\n" % anchor
    if anchor_line in xml:
        return xml.replace(anchor_line, anchor_line + line, 1)
    return xml


def ensure_profile_row(xml, name, caption, value, text, y1, y2, anchor_name):
    if '<SettingRowOption name="%s"' in xml or '<SettingRowTextureOption name="%s"' in xml:
        return update_existing_profile_row(xml, name, value, text)

    row = profile_row(name, caption, value, text, y1, y2)
    anchor_re = re.compile(
        r'(    <SettingRow(?:Texture)?Option name="%s" [^\r\n]*/>\r\n)'
        % re.escape(anchor_name)
    )
    match = anchor_re.search(xml)
    if not match:
        raise SystemExit("%s row pattern not found" % anchor_name)
    return xml[:match.end()] + row + xml[match.end():]


def patch_xml(xml, texture, light):
    tex_value, tex_text = menu_profile(texture)
    light_value, light_text = light_profile(light)
    xml = ensure_texture_template(xml, tex_value, tex_text)

    xml = ensure_opacity_line(xml, "textures", "shadow")
    xml = ensure_opacity_line(xml, "light", "textures")

    if '<SettingRowOption name="textures"' in xml:
        xml = update_existing_profile_row(xml, "textures", tex_value, tex_text)
    if '<SettingRowTextureOption name="textures"' in xml:
        xml = update_existing_profile_row(xml, "textures", tex_value, tex_text)
    else:
        shadow_row = (
            '    <SettingRowOption name="shadow" caption="FEDS_SHADOWS" '
            'y1="0.46" y2="0.54" opacity="1"/>\r\n'
        )
        textures_row = profile_row(
            "textures", "Textures", tex_value, tex_text, 0.55, 0.63
        )
        if shadow_row not in xml:
            raise SystemExit("shadow row pattern not found")
        xml = xml.replace(shadow_row, shadow_row + textures_row, 1)

    xml = ensure_profile_row(
        xml, "light", "Light", light_value, light_text, 0.64, 0.72, "textures"
    )
    return xml


def main():
    if len(sys.argv) not in (3, 4, 5):
        raise SystemExit("usage: patch-bully-menu.py /path/to/data_4.zip /path/to/bully2_patch.zip [low|medium|high] [off|low|medium|high]")

    data_zip = Path(sys.argv[1])
    patch_zip = Path(sys.argv[2])
    profile = sys.argv[3] if len(sys.argv) >= 4 else "medium"
    light = sys.argv[4] if len(sys.argv) == 5 else "off"
    with zipfile.ZipFile(data_zip, "r") as zf:
        original = zf.read(ENTRY)

    xml = decode(original)
    patched = patch_xml(xml, profile, light)
    encoded = encode(patched)

    patch_zip.parent.mkdir(parents=True, exist_ok=True)
    tmp = patch_zip.with_suffix(patch_zip.suffix + ".tmp")
    with zipfile.ZipFile(tmp, "w", compression=zipfile.ZIP_STORED) as zf:
        list_info = zipfile.ZipInfo("resource_files.list")
        list_info.date_time = (1980, 1, 1, 0, 0, 0)
        list_info.compress_type = zipfile.ZIP_STORED
        zf.writestr(list_info, (ENTRY + "\n").encode("utf-8"))

        info = zipfile.ZipInfo(ENTRY)
        info.date_time = (1980, 1, 1, 0, 0, 0)
        info.compress_type = zipfile.ZIP_STORED
        zf.writestr(info, encoded)
    os.replace(tmp, patch_zip)
    print(
        "wrote %s (%d bytes, textures=%s light=%s)"
        % (
            patch_zip,
            patch_zip.stat().st_size,
            menu_profile(profile)[1],
            light_profile(light)[1],
        )
    )


if __name__ == "__main__":
    main()
