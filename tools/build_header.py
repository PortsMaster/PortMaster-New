#!/usr/bin/env python3

import collections
import contextlib
import datetime
import functools
import hashlib
import json
import os
import pathlib
import re
import shutil
import subprocess
import sys
import zipfile

from difflib import Differ
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent / 'libs'))

from util import *

#############################################################################
ROOT_DIR = Path('.')

CACHE_FILE    = ROOT_DIR / '.hash_cache'
MANIFEST_FILE = ROOT_DIR / 'manifest.json'
STATUS_FILE   = ROOT_DIR / 'ports_status.json'
PORTS_DIR     = ROOT_DIR / 'ports'
RUNTIMES_DIR  = ROOT_DIR / 'runtimes'
HEADER_MAP    = ROOT_DIR / 'tools' / 'header_map.txt'

GITHUB_RUN    = (ROOT_DIR / '.github_check').is_file()

#############################################################################

HEADER_OLD  = "---------- OLD HEADER ----------"
HEADER_NEW  = "---------- NEW HEADER ----------"


def load_headers(header_file):
    with open(header_file, 'r') as fh:
        header_data = fh.read()

    header_map = {}

    for block in header_data.split(HEADER_OLD):
        if block.strip() == '':
            continue

        if HEADER_NEW not in block:
            header_map[block] = '\n'
            continue

        header_data, footer_data = block.split(HEADER_NEW, 1)
        header_map[header_data.strip()] = footer_data.strip()

    print(json.dumps(header_map, indent=4))

    return header_map


def save_headers(header_file, header_map):
    with open(header_file, 'w') as fh:
        for header_data, footer_data in header_map.items():
            print(HEADER_OLD, file=fh)
            print(header_data, file=fh)
            print("", file=fh)
            print(HEADER_NEW, file=fh)
            print(footer_data, file=fh)
            print("", file=fh)


def main(argv):
    hash_cache = None

    if not GITHUB_RUN:
        hash_cache = HashCache(CACHE_FILE)

    if HEADER_MAP.is_file():
        header_map = load_headers(HEADER_MAP)
    else:
        header_map = {}

    seen_headers = {}
    script_data = {}

    for port_dir in sorted(PORTS_DIR.iterdir(), key=lambda x: str(x).casefold()):
        if not port_dir.is_dir():
            continue

        for script_file in port_dir.glob('*.sh'):
            script_text = script_file.read_text()

            if '$controlfolder/control.txt' not in script_text:
                print(f"check {script_file}\n")
                continue

            header_text, body_text = script_text.split('$controlfolder/control.txt', 1)
            header_text = header_text.rsplit('\n', 1)[0]
            body_text = body_text.split('\n', 1)[1]

            body_text = "source $controlfolder/control.txt\n" + body_text

            header_text = re.sub(r'\n#\s+PORTMASTER:[^\n]*\n', '\n', header_text, re.I|re.MULTILINE)

            seen_headers.setdefault(header_text, [])
            header_map.setdefault(header_text.strip(), '')
            script_data[script_file] = [header_text.rstrip(), body_text.lstrip()]
            seen_headers[header_text].append(script_file)

    if '--run-replace' in argv:
        for script_file in script_data:
            port_name = f"{script_file.parent.name}.zip"
            header_text, body_text = script_data[script_file]

            new_header = header_map.get(header_text.strip(), '')

            if new_header.strip() == '':
                error(port_name, f"Unable to find replacement header for {script_file}, modify header_map.txt to fix it.")
                continue

            with open(script_file, 'w') as fh:
                print(new_header, file=fh)
                print("", file=fh)
                print(body_text, file=fh)

    save_headers(HEADER_MAP, header_map)

    errors = 0
    warnings = 0
    for port_name, messages in MESSAGES.items():
        if port_name in updated_ports:
            continue

        print(f"Bad port {port_name}")
        if len(messages['warnings']) > 0:
            print("- Warnings:")
            print("  " + "\n  ".join(messages['warnings']) + "\n")
            warnings += 1

        if len(messages['errors']) > 0:
            print("- Errors:")
            print("  " + "\n  ".join(messages['errors']) + "\n")
            errors += 1

    if hash_cache is not None:
        hash_cache.save_cache()

    if '--do-check' in argv:
        if errors > 0:
            return 255

        if warnings > 0:
            return 127

    return 0


if __name__ == '__main__':
    exit(main(sys.argv))


