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


import xml.etree.ElementTree as ET


from difflib import Differ
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent / 'libs'))

from util import *


#############################################################################
## Read CONFIG file.
ROOT_DIR = Path('.')

CACHE_FILE = ROOT_DIR / '.hash_cache'
RELEASE_DIR = ROOT_DIR / 'releases'
MANIFEST_FILE = RELEASE_DIR / 'manifest.json'
STATUS_FILE = RELEASE_DIR / 'ports_status.json'
PORTS_DIR = ROOT_DIR / 'ports'

GAMEINFO_STATUS = RELEASE_DIR / 'gameinfo_status.json'

GITHUB_RUN = (ROOT_DIR / '.github_check').is_file()

#############################################################################
## Read CONFIG file.
REPO_CONFIG = {
    'RELEASE_ORG': None,
    'RELEASE_REPO': None,
    'REPO_NAME': None,
    'REPO_PREFIX': None,
    }

with open('SOURCE_SETUP.txt', 'r') as fh:
    for line in fh:
        line = line.strip()
        if line.startswith('#'):
            continue

        if '=' in line and '"' in line:
            CFG_NAME, CFG_DATA = line.split('=', 1)
            if CFG_NAME in REPO_CONFIG:
                REPO_CONFIG[CFG_NAME] = CFG_DATA.split('"')[1].strip()

failed = False
for CFG_NAME, CFG_DATA in REPO_CONFIG.items():
    if CFG_DATA is None or CFG_DATA == "":
        print(f"::error file=SOURCE_SETUP.txt::{CFG_NAME} is not set.")
        failed = True

if failed is True:
    exit(255)

#############################################################################

def parse_gameinfo(gameinfo_file, gameinfo_status):
    REQUIRED_XML_TAGS = (
        'path',
        'name',
        'image',
        )

    WANTED_XML_TAGS = REQUIRED_XML_TAGS + (
        'desc',
        )

    ALLOWED_XML_TAGS = WANTED_XML_TAGS + (
        'releasedate',
        'developer',
        'publisher',
        'genre',
        'players',
        )

    port_dir = gameinfo_file.parent
    port_name = port_dir.name

    port_scripts = [
        file.resolve()
        for file in port_dir.glob('*.sh')]

    # print(gameinfo_file)
    gamelist_tree = ET.parse(gameinfo_file)
    gamelist_root = gamelist_tree.getroot()

    gameinfo_data = []

    if gamelist_root.tag != 'gameList':
        if gamelist_root.tag.lower() == 'gamelist':
            warning(port_name, f"{gameinfo_file}: bad root level tag, got {gamelist_root.tag!r} expected 'gameList'")
        else:
            error(port_name, f"{gameinfo_file}: bad root level tag, got {gamelist_root.tag!r} expected 'gameList'")

    for gamelist_game in gamelist_root:
        if gamelist_game.tag != 'game':
            error(port_name, f"{gameinfo_file}: Unknown tag {gamelist_game.tag!r} found.")
            continue

        gameinfo_item = {}
        for gamelist_item in gamelist_game:
            if gamelist_item.tag not in ALLOWED_XML_TAGS:
                error(port_name, f"{gameinfo_file}: Unknown tag {gamelist_item.tag!r} found.")
                continue

            if gamelist_item.text is None:
                if gamelist_item.tag in REQUIRED_XML_TAGS:
                    error(port_name, f"{gameinfo_file}: Tag {gamelist_item.tag!r} is None")

                continue

            gameinfo_item[gamelist_item.tag] = re.sub(r'^\s*(.*?)\s*$', r'\1', gamelist_item.text, re.MULTILINE)

        for tag in REQUIRED_XML_TAGS:
            if tag not in gameinfo_item:
                error(port_name, f"{gameinfo_file}: missing {tag!r} attribute.")

        if 'path' not in gameinfo_item:
            continue

        gameinfo_data.append(gameinfo_item)

        script_file = port_dir / gameinfo_item['path']
        script_file = script_file.resolve()

        if not gameinfo_item['path'].startswith('./'):
            error(port_name, f"{gameinfo_file}: bad value for 'path': {gameinfo_item['path']!r}")

        elif not script_file.is_file():
            warning(port_name, f"{gameinfo_file}: unknown script file {str(script_file.name)!r}")

        else:
            port_scripts.remove(script_file)

        if 'image' not in gameinfo_item:
            # gameinfo_status[str(gameinfo_file)]['temp'] = 1
            error(port_name, f"{gameinfo_file}: missing 'image' entry.")
            continue

        if not gameinfo_item['image'].startswith('./'):
            # gameinfo_status[str(gameinfo_file)]['temp'] = 1
            error(port_name, f"{gameinfo_file}: bad value for 'image': {gameinfo_item['image']!r}")
            continue

        if '/' not in gameinfo_item['image']:
            error(port_name, f"{gameinfo_file}: bad value for 'image': {gameinfo_item['image']!r}")
            continue

        directory, filename = gameinfo_item['image'].rsplit('/', 1)

        filename_fix = filename

        if filename.rsplit('.', 1)[-1] in ('png', 'jpg'):
            fixes = {'jpg': '.png', 'png': '.jpg'}

            filename_fix = filename.rsplit('.', 1)[0] + fixes[filename.rsplit('.', 1)[-1]]

        directory_base   = (port_dir / directory).resolve()
        filename_base    = (port_dir / filename).resolve()
        filename_portdir = (port_dir / directory / filename).resolve()

        filename_base_fix    = (port_dir / filename_fix).resolve()
        filename_portdir_fix = (port_dir / directory / filename_fix).resolve()

        if not directory_base.is_dir():
            error(port_name, f"{gameinfo_file}: bad value for 'image', unknown directory: {directory_base.name!r}")
            continue

        if not filename_base.is_file() and not filename_portdir.is_file():
            if filename_base_fix.is_file() or filename_portdir_fix.is_file():
                error(port_name, f"{gameinfo_file}: bad value for 'image', unknown file: {directory + '/' + filename!r} (found: {directory + '/' + filename_fix!r})")
            else:
                error(port_name, f"{gameinfo_file}: bad value for 'image', unknown file: {directory + '/' + filename!r}")
            continue

    if len(port_scripts) > 0:
        for port_script in port_scripts:
            error(port_name, f"{gameinfo_file}: missing gameinfo entry for {str(port_script.name)!r}")

    # print("-" * 80)
    # print(f"- {gameinfo_file}")
    # print(json.dumps(gameinfo_data, indent=4))


def main(argv):
    file_cache = None

    if not GITHUB_RUN:
        file_cache = HashCache(CACHE_FILE)

    gameinfo_status = {}

    for port_dir in sorted(PORTS_DIR.iterdir(), key=lambda x: str(x).casefold()):
        if not port_dir.is_dir():
            continue

        gameinfo_file = port_dir / 'gameinfo.xml'

        if not gameinfo_file.is_file():
            error(port_dir.name, "gameinfo.xml: missing.")
            gameinfo_status[str(gameinfo_file)] = {}

            continue

        parse_gameinfo(gameinfo_file, gameinfo_status)

    errors = 0
    warnings = 0

    for port_name, messages in MESSAGES.items():
        if GITHUB_RUN:
            for warning_msg in messages['warnings']:
                print(f"::warning file=ports/{port_name}::{warning_msg}")
                warnings += 1

            for error_msg in messages['errors']:
                print(f"::error file=ports/{port_name}::{error_msg}")
                errors += 1

            continue

        print(f"Bad port {port_name!r}")
        if len(messages['warnings']) > 0:
            print("- Warnings:")
            print("  " + "\n  ".join(messages['warnings']) + "\n")
            warnings += 1

        if len(messages['errors']) > 0:
            print("- Errors:")
            print("  " + "\n  ".join(messages['errors']) + "\n")
            errors += 1

    # with open(GAMEINFO_STATUS, 'w') as fh:
    #     json.dump(gameinfo_status, fh, indent=4, sort_keys=True)

    if file_cache is not None:
        file_cache.save_cache()

    if GITHUB_RUN:
        if errors > 0:
            return 255

        if warnings > 0:
            return 127

    return 0


if __name__ == '__main__':
    exit(main(sys.argv))
