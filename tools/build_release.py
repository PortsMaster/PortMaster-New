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
## Constants
README_FILE, SCREENSHOT_FILE, COVER_FILE, GAMEINFO_XML, PORT_JSON, PORT_SCRIPT, PORT_DIR, GITIGNORE_FILE, UNKNOWN_FILE = range(9)
REQUIRED_FILES = (
    (1<<README_FILE)     |
    (1<<SCREENSHOT_FILE) |
    (1<<GAMEINFO_XML)    |
    (1<<PORT_JSON)       |
    (1<<PORT_SCRIPT)     |
    (1<<PORT_DIR)        )

FILE_TYPE_DESC = {
    README_FILE:     "README.md",
    SCREENSHOT_FILE: "screenshot.{png|jpg}",
    COVER_FILE:      "cover.{png|jpg}",
    GAMEINFO_XML:    "gameinfo.xml",
    PORT_JSON:       "port.json",
    PORT_SCRIPT:     "Port Script",
    PORT_DIR:        "Port Directory",
    GITIGNORE_FILE:  ".gitginore",
    UNKNOWN_FILE:    "Unknown file",
    }

FILE_TYPE_RE = {
    r"^\.gitignore$": GITIGNORE_FILE,
    r"^readme\.md$": README_FILE,
    r"^screenshot\.(png|jpg)$": SCREENSHOT_FILE,
    r"^cover\.(?:[a-z0-9]+\.)?(png|jpg)$": COVER_FILE,
    r"^port\.json$": PORT_JSON,
    r"^gameinfo\.xml$": GAMEINFO_XML,
    }

TODAY = str(datetime.datetime.today().date())

ROOT_DIR = Path('.')

CACHE_FILE         = ROOT_DIR / '.hash_cache'
RELEASE_DIR        = ROOT_DIR / 'releases'
RUNTIMES_DIR       = ROOT_DIR / 'runtimes'
MANIFEST_FILE      = RELEASE_DIR / 'manifest.json'
STATUS_FILE        = RELEASE_DIR / 'ports_status.json'
PORTS_DIR          = ROOT_DIR / 'ports'
PORT_STAT_RAW_FILE = RELEASE_DIR / 'port_stats_raw.json'

SPLIT_IMAGES  = False

GITHUB_RUN    = (ROOT_DIR / '.github_check').is_file()

LARGEST_FILE  = (1024 * 1024 * 90)

#############################################################################
"""
We have ports like:

ports/banana.duck/
├── Banana Duck.sh
├── README.md
├── bananaduck
│   ├── LICENSE.bananaduck.txt
│   ├── LICENSE.love2d.txt
│   ├── README
│   ├── bananaduck.gptk
│   ├── game
│   │   └── LOTS OF FILES
│   ├── log.txt
│   └── love
├── cover.png
├── gameinfo.xml
├── port.json
└── screenshot.png

when i create the gameinfo.zip i am storing the gameinfo data as:
- banana.duck/gameinfo.xml
- banana.duck/cover.png
- banana.duck/screenshot.png

but i need to store it as:
- bananaduck/gameinfo.xml
- bananaduck/cover.png
- bananaduck/screenshot.png

THIS_IS_ANNOYING maps "banana.duck/gameinfo.xml" to "bananaduck/gameinfo.xml"

"""
THIS_IS_ANNOYING = {}


#############################################################################
## Read CONFIG file.
REPO_CONFIG = {
    'RELEASE_ORG': None,
    'RELEASE_REPO': None,
    'REPO_NAME': None,
    'REPO_PREFIX': None,
    'SPLIT_IMAGES': "N",
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
## Stuff.

if len(sys.argv) > 1 and sys.argv[1] != '--do-check':
    CURRENT_RELEASE_ID = sys.argv[1]
else:
    CURRENT_RELEASE_ID = "latest"

#############################################################################


PORT_STAT_RAW_DATA = None
def get_historial_added_date(port_name, default=None):
    """
    Uses port_stats_raw.json to get a historial release date if it is not found.

    This is used to keep info sane when moving ports between github repos.
    """
    global PORT_STAT_RAW_DATA

    if PORT_STAT_RAW_DATA is None:
        if not PORT_STAT_RAW_FILE.is_file():
            return default

        try:
            with PORT_STAT_RAW_FILE.open('r') as fh:
                PORT_STAT_RAW_DATA = json.load(fh)

            if not isinstance(PORT_STAT_RAW_DATA, dict):
                return default

        except json.decoder.JSONDecodeError as err:
            printf(f"Unable to load {str(PORT_STAT_RAW_FILE)}: {err}")
            PORT_STAT_RAW_DATA = None
            return default

    if port_name not in PORT_STAT_RAW_DATA.get('ports', {}):
        print(f"- {port_name} --> {default} (DEFAULT)")
        return default

    for release_id in sorted(PORT_STAT_RAW_DATA.get('releases', [])):
        if port_name in PORT_STAT_RAW_DATA.get('release_data', {}).get(release_id, []):
            added_date = release_id.split('_', 1)[0]
            print(f"- {port_name} --> {added_date}")
            return added_date

    print(f"- {port_name} --> {default} (DEFAULT)")
    return default


def current_release_url(release_id):
    if release_id == 'latest':
        return f"https://github.com/{REPO_CONFIG['RELEASE_ORG']}/{REPO_CONFIG['RELEASE_REPO']}/releases/latest/download/"

    return f"https://github.com/{REPO_CONFIG['RELEASE_ORG']}/{REPO_CONFIG['RELEASE_REPO']}/releases/download/{release_id}/"


def file_type(port_file):
    if port_file.is_dir():
        return PORT_DIR

    for file_pattern, file_type in FILE_TYPE_RE.items():
        if re.match(file_pattern, port_file.name, re.I):
            return file_type

    if port_file.name.lower().endswith('.sh'):
        return PORT_SCRIPT

    return UNKNOWN_FILE


def load_port(port_dir, manifest, registered, port_status, quick_build=False, hash_cache=None):
    if hash_cache is not None:
        hash_func = hash_cache.get_file_hash

    else:
        hash_func = hash_file

    port_data = {
        'name': None,
        'port_json': None,
        'port_json_file': None,

        'files': {},

        'items': [],
        'dirs': [],
        'scripts': [],

        'zip_files': [],
        'image_files': {
            "screenshot": None,
            "covers": [],
            "thumbnail": None,
            "video": None,
            },
        }

    if port_dir.name != name_cleaner(port_dir.name):
        error(port_dir.name, f"Bad port directory name, recommended name: {name_cleaner(port_dir.name)}, please rename to continue.")
        return None

    port_check_bf = 0

    for port_file in port_dir.iterdir():
        if port_file.name in ('.', '..', '.git', '.DS_Store'):
            continue

        port_file_type = file_type(port_file)

        port_check_bf |= (1 << port_file_type)

        if port_file_type == UNKNOWN_FILE:
            warning(port_dir.name, f"Unknown file: {port_file.name}")
            continue

        elif port_file_type == COVER_FILE:
            port_data['image_files']['covers'].append(str(port_file.name))

        elif port_file_type == SCREENSHOT_FILE:
            port_data['image_files']['screenshot'] = str(port_file.name)

        elif port_file_type == PORT_SCRIPT:
            if registered['scripts'].setdefault(port_file.name, port_dir.name) != port_dir.name:
                error(port_file.name, f"Port has the script {port_file.name} which belongs to {registered['scripts'][port_file.name]}")
                return None

            port_data['scripts'].append(port_file.name)
            port_data['items'].append(port_file.name)

        elif port_file_type == PORT_DIR:
            if registered['dirs'].setdefault(port_file.name, port_dir.name) != port_dir.name:
                error(port_file.name, f"Port uses the directory {port_file.name} which belongs to {registered['dirs'][port_file.name]}")
                return None

            port_data['items'].append(port_file.name + '/')
            port_data['dirs'].append(port_file.name + '/')

        elif port_file_type == PORT_JSON:
            port_data['port_json'] = port_info_load(port_file, port_dir.name)
            if port_data['port_json'] is None:
                return None

            port_data['port_json_file'] = port_file
            port_data['name'] = name_cleaner(port_data['port_json']['name'])

            if not port_data['name'].endswith('.zip'):
                warning(port_dir.name, f"bad 'name' in port.json: {port_data['name']}")
                port_data['name'] += '.zip'

        port_data['files'][port_file.name] = port_file_type

    if port_data['name'] not in port_status:
        port_date = get_historial_added_date(port_data['name'], TODAY)
    else:
        port_date = port_status[port_data['name']]['date_added']

    broken = False
    ## Check if the port is an older port, newer ports have stricter name requirements.
    if port_date > '2024-01-26':
        ## Check for weird names.

        port_data['name'] = name_cleaner(port_dir.name) + '.zip'
        if port_data['port_json'] is not None:
            if port_data['name'] != port_data['port_json']['name']:
                error(port_dir.name, f"Bad port name {port_data['port_json']['name']!r}, recommended name is {port_data['name']!r}")
                broken = True

        if (port_dir.name + '/') not in port_data['dirs']:
            error(port_dir.name, f"No port directory named {port_dir.name}. Main port directory needs to be named {port_dir.name}")
            broken = True

        for dir_name in port_data['dirs']:
            if name_cleaner(dir_name[:-1]) != dir_name[:-1]:
                error(port_dir.name, f"Bad port directory {dir_name[:-1]!r}, recommended name is {name_cleaner(dir_name[:-1])!r}")
                broken = True

    else:
        # Another bug :D
        port_data['port_json']['name'] = name_cleaner(port_data['port_json']['name'])

    # This is an abomination. :D
    if (port_check_bf & (1<<PORT_JSON)) == 0:
        port_json_files = list(port_dir.glob('**/*.port.json'))
        if len(port_json_files) > 0:
            error(port_dir.name, f"No {port_dir}/port.json file found, found {port_json_files[0]} as a possible candidate.")
            port_check_bf |= (1<<PORT_JSON)
            broken = True

    if (port_check_bf & (1<<README_FILE)) == 0:
        best_match = None
        match_score = 0
        for readme_file in port_dir.glob('**/*.md'):
            if name_cleaner(port_dir.name) in name_cleaner(readme_file.name):
                if match_score < 100:
                    best_match = readme_file
                    match_score = 100

            if readme_file.name.lower() == 'readme.md':
                if match_score < 50:
                    best_match = readme_file
                    match_score = 50

        if best_match is not None:
            error(port_dir.name, f"No {port_dir}/README.md file found, found {best_match} as a possible candidate.")
            port_check_bf |= (1<<README_FILE)

    if (port_check_bf & (1<<SCREENSHOT_FILE)) == 0:
        screenshot_files = list(port_dir.glob('**/*.screenshot.png')) + list(port_dir.glob('**/*.screenshot.jpg'))
        if len(screenshot_files) > 0:
            error(port_dir.name, f"No {port_dir}/screnshot.{{png|jpg}} file found, found {screenshot_files[0]} as a possible candidate.")
            port_check_bf |= (1<<SCREENSHOT_FILE)

    port_check_bf &= REQUIRED_FILES
    if port_check_bf != REQUIRED_FILES:
        for i in range(UNKNOWN_FILE):
            CHECKER = (1 << i)
            if (CHECKER & REQUIRED_FILES) == 0:
                continue

            if (port_check_bf & CHECKER) == 0:
                error(port_dir.name, f"Missing {FILE_TYPE_DESC[i]}.")

                if i in (PORT_JSON, PORT_DIR, PORT_SCRIPT):
                    broken = True

    if broken:
        return None

    # LETS MAKE IT WORSE.
    THIS_IS_ANNOYING['/'.join((port_dir.name, 'gameinfo.xml'))] = \
        port_data['dirs'][0] + 'gameinfo.xml'

    THIS_IS_ANNOYING['/'.join((port_dir.name, port_data['image_files']['screenshot']))] = \
        port_data['dirs'][0] + port_data['image_files']['screenshot']

    for cover_image in port_data['image_files']['covers']:
        THIS_IS_ANNOYING['/'.join((port_dir.name, cover_image))] = \
            port_data['dirs'][0] + cover_image

    # Create the manifest (an md5sum of all the files in the port, and an md5sum of those md5sums).
    temp = []
    paths = collections.deque([port_dir])
    port_manifest = []
    large_files = {}

    while len(paths) > 0:
        path = paths.popleft()

        for file_name in path.iterdir():
            if file_name.name in ('.', '..', '.git', '.DS_Store', '.gitignore'):
                continue

            if file_name.name.startswith('._'):
                continue

            if file_name.is_dir():
                paths.append(file_name)
                continue

            if not file_name.is_file():
                warning(port_dir.name, f"Unknown file: {file_name}")
                continue

            if file_name.name[-9:-3] == '.part.' and file_name.name[-3:].isdigit():
                large_files.setdefault(str(file_name)[:-9], False)
                continue

            port_file_name = '/'.join(file_name.parts[1:])

            large_files[str(file_name)] = True

            if not quick_build:
                file_hash = hash_func(file_name)

                manifest[port_file_name] = file_hash
                port_manifest.append((port_file_name, file_hash))

    for large_file, large_file_status in large_files.items():
        if not large_file_status:
            error(port_dir.name, f"Missinge large_file: {large_file}, run python data/build_data.py first.")
            return None

    if not quick_build:
        port_manifest.sort(key=lambda x: x[0].casefold())

    manifest[port_dir.name] = hash_items(port_manifest)

    return port_data


@contextlib.contextmanager
def change_dir(new_path):
    old_cwd = os.getcwd()
    try:
        os.chdir(new_path)

        yield

    finally:
        os.chdir(old_cwd)


def build_port_zip(root_dir, port_dir, port_data, new_manifest, port_status):
    port_name = port_data['name'].rsplit('.', 1)[0]
    zip_name = root_dir / port_data['name']

    paths = collections.deque([port_dir])
    zip_files = []

    while len(paths) > 0:
        path = paths.popleft()

        for file_name in path.iterdir():
            if file_name.name in ('.', '..', '.git', '.DS_Store', '.gitignore'):
                continue

            if file_name.name.startswith('._'):
                continue

            if file_name.is_dir():
                paths.append(file_name)
                continue

            if not file_name.is_file():
                continue

            new_name = '/'.join(file_name.parts[2:])

            if '/' not in new_name:
                file_name_type = file_type(file_name)

                if file_name_type in (SCREENSHOT_FILE, COVER_FILE):
                    new_name = port_data['dirs'][0] + f"{new_name}"

                elif file_name_type == README_FILE:
                    new_name = port_data['dirs'][0] + f"{port_name}.md"

                elif file_name_type == PORT_JSON:
                    new_name = port_data['dirs'][0] + "port.json"

                elif file_name_type == GAMEINFO_XML:
                    new_name = port_data['dirs'][0] + "gameinfo.xml"

                elif file_name_type == UNKNOWN_FILE:
                    continue

            else:
                if new_name.lower().endswith('.sh'):
                    warning(port_dir.name, f"Script {new_name} found in port directories, this can cause issues.")

            if file_name.name[-9:-3] == '.part.' and file_name.name[-3:].isdigit():
                continue

            if file_name == port_data['port_json_file']:
                zip_files.append((file_name, new_name, json.dumps(port_data['port_json'], indent=4)))

            else:
                zip_files.append((file_name, new_name, None))

    zip_files.sort(key=lambda x: x[1].lower())

    # from pprint import pprint
    # pprint(zip_files)

    with zipfile.ZipFile(zip_name, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as zf:
        for file_triplet in zip_files:
            if file_triplet[2] == None:
                zf.write(file_triplet[0], file_triplet[1])

            else:
                zf.writestr(file_triplet[1], file_triplet[2])

    # port_name = port_data['name']
    # port_hash = hash_file(zip_name)

    # if port_name in port_status:
    #     port_status[port_name]['date_updated'] = TODAY
    #     port_status[port_name]['md5'] = port_hash
    #     port_status[port_name]
    # else:
    #     port_status[port_name] = {
    #         'date_added': TODAY,
    #         'date_updated': TODAY,
    #         'release_id': CURRENT_RELEASE_ID,
    #         'md5': port_hash,
    #         }


def build_gameinfo_zip(old_manifest, new_manifest):
    new_files = [
        f"{file}:{digest}"
        for file, digest in new_manifest.items()
        if file.count('/') == 1 and (
            file_type(Path(file)) in (COVER_FILE, SCREENSHOT_FILE, GAMEINFO_XML))]

    old_files = [
        f"{file}:{digest}"
        for file, digest in old_manifest.items()
        if file.count('/') == 1 and (
            file_type(Path(file)) in (COVER_FILE, SCREENSHOT_FILE, GAMEINFO_XML))]

    new_files.sort()
    old_files.sort()

    new_manifest['gameinfo.zip'] = hash_items(new_files)
    if old_manifest.get('gameinfo.zip') == new_manifest['gameinfo.zip']:
        return

    changes = {}
    differ = Differ()

    print(f"Building gameinfo.zip")
    for line in differ.compare(old_files, new_files):
        # line = "  <FILENAME>:<md5SUM>"
        mode = line[:2]
        name = line[2:].split(":", 1)[0]
        if mode == '- ':
            # File is removed.
            changes[name] = 'Removed'
        elif mode == '+ ':
            if name in changes:
                # If the file was already seen, its been removed, and readded, which means modified.
                changes[name] = 'Modified'
            else:
                # File is just added.
                changes[name] = 'Added'

    zip_files = [
        ((PORTS_DIR / file), THIS_IS_ANNOYING[str(file)])
        for file, digest in new_manifest.items()
        if file.count('/') == 1 and (
            file_type(Path(file)) in (COVER_FILE, SCREENSHOT_FILE, GAMEINFO_XML))]

    with zipfile.ZipFile(RELEASE_DIR / 'gameinfo.zip', 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as zf:
        for file_pair in zip_files:
            zf.write(file_pair[0], file_pair[1])


def port_info_id(port_status, max_info_count=100):
    """
    This sorts the ports by their date_added & name lower case.

    We iterate through the ports keeping track of the total ports under an `info_id`.

    Once we reach `max_info_count` ports in a single info_id, we increment the number.

    To make it predictable we make sure that all ports with the same 'date_added'
    stay in the same `info_id`, so we keep track of the last_date.
    """
    info_id = 0
    port_info_ids = {
        info_id: 0,
        }

    port_info_id_map = {}
    last_date = ''

    for port_zip in sorted(port_status.keys(), key=lambda port_zip: (port_status[port_zip]['date_added'], port_zip.casefold())):
        if not port_zip.lower().endswith('.zip'):
            continue

        if port_zip.lower().startswith('images.'):
            continue

        if port_zip.lower() in ('images.zip', 'gameinfo.zip'):
            continue

        current_date = port_status[port_zip]['date_added']

        if (port_info_ids[info_id] >= max_info_count) and (last_date != current_date):
            info_id += 1
            port_info_ids[info_id] = 0

        port_info_ids[info_id] += 1

        port_zip = port_zip.rsplit('.', 1)[0]

        port_info_id_map[port_zip] = info_id

        last_date = current_date

    # print(json.dumps(port_info_id_map, indent=2, sort_keys=True))

    return port_info_id_map


def build_new_images_zip(old_manifest, new_manifest, port_status):
    port_info_id_map = port_info_id(port_status)

    max_info_id = max(port_info_id_map.values()) + 1

    for info_id in range(max_info_id):
        new_files = [
            f"{file.replace('/', '.')}:{digest}"
            for file, digest in new_manifest.items()
            if file.count('/') == 1 and port_info_id_map[file.split('/', 1)[0]] == info_id and file_type(Path(file)) == SCREENSHOT_FILE]

        old_files = [
            f"{file.replace('/', '.')}:{digest}"
            for file, digest in old_manifest.items()
            if file.count('/') == 1 and port_info_id_map[file.split('/', 1)[0]] == info_id and file_type(Path(file)) == SCREENSHOT_FILE]

        new_files.sort()
        old_files.sort()

        zip_name = f'images.{info_id:03d}.zip'

        new_manifest[zip_name] = hash_items(new_files)
        if old_manifest.get(zip_name) == new_manifest[zip_name]:
            continue

        changes = {}
        differ = Differ()

        for line in differ.compare(old_files, new_files):
            # line = "  <FILENAME>:<md5SUM>"
            mode = line[:2]
            name = line[2:].split(":", 1)[0]
            if mode == '- ':
                # File is removed.
                changes[name] = 'Removed'

            elif mode == '+ ':
                if name in changes:
                    # If the file was already seen, its been removed, and readded, which means modified.
                    changes[name] = 'Modified'

                else:
                    # File is just added.
                    changes[name] = 'Added'

        if zip_name in old_manifest:
            print(f"Adding {zip_name}")

        else:
            print(f"Updating {zip_name}")

        for name, mode in changes.items():
            print(f" - {mode} {name}")

        zip_files = [
            ((PORTS_DIR / file), f"{file.replace('/', '.')}")
            for file, digest in new_manifest.items()
            if file.count('/') == 1 and port_info_id_map[file.split('/', 1)[0]] == info_id and file_type(PORTS_DIR / file) == SCREENSHOT_FILE]

        with zipfile.ZipFile(RELEASE_DIR / zip_name, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as zf:
            for file_pair in zip_files:
                zf.write(file_pair[0], file_pair[1])


def build_images_zip(old_manifest, new_manifest):
    new_files = [
        f"{file.replace('/', '.')}:{digest}"
        for file, digest in new_manifest.items()
        if file.count('/') == 1 and file_type(Path(file)) == SCREENSHOT_FILE]

    old_files = [
        f"{file.replace('/', '.')}:{digest}"
        for file, digest in old_manifest.items()
        if file.count('/') == 1 and file_type(Path(file)) == SCREENSHOT_FILE]

    new_files.sort()
    old_files.sort()

    new_manifest['images.zip'] = hash_items(new_files)
    if old_manifest.get('images.zip') == new_manifest['images.zip']:
        return

    changes = {}
    differ = Differ()

    for line in differ.compare(old_files, new_files):
        # line = "  <FILENAME>:<md5SUM>"
        mode = line[:2]
        name = line[2:].split(":", 1)[0]
        if mode == '- ':
            # File is removed.
            changes[name] = 'Removed'

        elif mode == '+ ':
            if name in changes:
                # If the file was already seen, its been removed, and readded, which means modified.
                changes[name] = 'Modified'

            else:
                # File is just added.
                changes[name] = 'Added'

    if 'images.zip' in old_manifest:
        print("Adding images.zip")

    else:
        print("Updating images.zip")

    for name, mode in changes.items():
        print(f" - {mode} {name}")

    zip_files = [
        ((PORTS_DIR / file), f"{file.replace('/', '.')}")
        for file, digest in new_manifest.items()
        if file.count('/') == 1 and file_type(PORTS_DIR / file) == SCREENSHOT_FILE]

    with zipfile.ZipFile(RELEASE_DIR / 'images.zip', 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as zf:
        for file_pair in zip_files:
            zf.write(file_pair[0], file_pair[1])


def build_markdown_zip(old_manifest, new_manifest):
    new_files = [
        f"{file.split('/', 1)[0]}.md:{digest}"
        for file, digest in new_manifest.items()
        if file.count('/') == 1 and file_type(Path(file)) == README_FILE]

    old_files = [
        f"{file.split('/', 1)[0]}.md:{digest}"
        for file, digest in old_manifest.items()
        if file.count('/') == 1 and file_type(Path(file)) == README_FILE]

    new_files.sort()
    old_files.sort()

    new_manifest['markdown.zip'] = hash_items(new_files)
    if old_manifest.get('markdown.zip') == new_manifest['markdown.zip']:
        return

    changes = {}
    differ = Differ()

    for line in differ.compare(old_files, new_files):
        # line = "  <FILENAME>:<md5SUM>"
        mode = line[:2]
        name = line[2:].split(":", 1)[0]
        if mode == '- ':
            # File is removed.
            changes[name] = 'Removed'
        elif mode == '+ ':
            if name in changes:
                # If the file was already seen, its been removed, and readded, which means modified.
                changes[name] = 'Modified'
            else:
                # File is just added.
                changes[name] = 'Added'

    if 'markdown.zip' in old_manifest:
        print("Adding markdown.zip")
    else:
        print("Updating markdown.zip")

    for name, mode in changes.items():
        print(f" - {mode} {name}")

    zip_files = [
        (Path(file), f"{file.split('/', 1)[0]}.md")
        for file, digest in new_manifest.items()
        if file.count('/') == 1 and file_type(Path(file)) == README_FILE]

    with zipfile.ZipFile('markdown.zip', 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as zf:
        for file_pair in zip_files:
            zf.write(file_pair[0], file_pair[1])


def port_info(file_name, ports_json, ports_status):
    clean_name = name_cleaner(file_name.name)

    if file_name.is_file():
        file_md5 = hash_file(file_name)
        file_size = file_name.stat().st_size
    else:
        if clean_name not in ports_status:
            # HRMMmmmmm o_o;;;;
            return

        file_md5  = ports_status[clean_name]['md5']
        file_size = ports_status[clean_name]['size']

    default_status = {
        'date_added': TODAY,
        'date_updated': TODAY,
        'md5': file_md5,
        'size': file_size,
        'release_id': CURRENT_RELEASE_ID,
        }

    if clean_name not in ports_status:
        default_status['date_added'] = get_historial_added_date(clean_name, TODAY)
        ports_status[clean_name] = default_status

    elif ports_status[clean_name]['md5'] != file_md5:
        ports_status[clean_name]['md5'] = file_md5
        ports_status[clean_name]['size'] = file_size
        ports_status[clean_name]['release_id'] = CURRENT_RELEASE_ID
        ports_status[clean_name]['date_updated'] = TODAY

    if clean_name in ports_json:
        ports_json[clean_name]['source'] = ports_status[clean_name].copy()
        ports_json[clean_name]['source']['url'] = current_release_url(ports_status[clean_name]['release_id']) + (file_name.name.replace(" ", ".").replace("..", "."))


def util_info(file_name, util_json, ports_status, runtimes_map):
    clean_name = name_cleaner(file_name.name)

    if file_name.name.lower().endswith('.squashfs'):
        clean_name = name_cleaner(runtimes_map[file_name.name]['export_name'])
        export_name = runtimes_map[file_name.name]['export_name']

        file_md5 = hash_file(file_name)
        file_size = file_name.stat().st_size

        nice_name = runtimes_map[file_name.name]['nice_name']
        runtime_name = runtimes_map[file_name.name]['runtime_name']
        runtime_arch = runtimes_map[file_name.name]['runtime_arch']

        default_status = {
            'date_added': TODAY,
            'date_updated': TODAY,
            'md5': file_md5,
            'size': file_size,
            'release_id': CURRENT_RELEASE_ID,
            }

        if clean_name not in ports_status:
            ports_status[clean_name] = default_status

            shutil.copy(file_name, RELEASE_DIR / export_name)

        elif ports_status[clean_name]['md5'] != file_md5:
            ports_status[clean_name]['md5'] = file_md5
            ports_status[clean_name]['size'] = file_size
            ports_status[clean_name]['release_id'] = CURRENT_RELEASE_ID
            ports_status[clean_name]['date_updated'] = TODAY

            shutil.copy(file_name, RELEASE_DIR / export_name)

        url = current_release_url(ports_status[clean_name]['release_id']) + (export_name.replace(" ", ".").replace("..", "."))

        util_json[clean_name] = {
            'name': nice_name,
            'runtime_name': runtime_name,
            'runtime_arch': runtime_arch,
            'md5': file_md5,
            'size': file_size,
            'url': url,
            }

    else:
        if file_name.is_file():
            file_md5 = hash_file(file_name)
            file_size = file_name.stat().st_size

        else:
            if clean_name not in ports_status:
                # HRMMmmmmm o_o;;;;
                return

            file_md5 = ports_status[clean_name]['md5']
            file_size = ports_status[clean_name]['size']

        default_status = {
            'date_added': TODAY,
            'date_updated': TODAY,
            'md5': file_md5,
            'size': file_size,
            'release_id': CURRENT_RELEASE_ID,
            }

        if clean_name not in ports_status:
            ports_status[clean_name] = default_status

        elif ports_status[clean_name]['md5'] != file_md5:
            ports_status[clean_name]['md5'] = file_md5
            ports_status[clean_name]['size'] = file_size
            ports_status[clean_name]['release_id'] = CURRENT_RELEASE_ID
            ports_status[clean_name]['date_updated'] = TODAY

        name = file_name.name
        url = current_release_url(ports_status[clean_name]['release_id']) + (file_name.name.replace(" ", ".").replace("..", "."))

        util_json[clean_name] = {
            "name": name,
            'md5': file_md5,
            'size': file_size,
            'url': url,
            }


def port_diff(port_name, old_manifest, new_manifest):
    """
    Print file changes
    TODO: detect file renames
    """
    changes = {}
    differ = Differ()

    new_files = {
        file.split('/', 1)[-1]: digest
        for file, digest in new_manifest.items()
        if file.startswith(port_name + '/')}

    old_files = {
        file.split('/', 1)[-1]: digest
        for file, digest in old_manifest.items()
        if file.startswith(port_name + '/')}

    removed_files = set(old_files) - set(new_files) 
    same_files = set(old_files) & set(new_files)
    added_files = set(new_files) - set(old_files)

    renamed_files = []
    for removed_file in list(removed_files):
        for added_file in added_files:
            if new_files[added_file] == old_files[removed_file]:
                renamed_files.append((removed_file, added_file))
                removed_files.remove(removed_file)
                added_files.remove(added_file)
                break

    for file_name in same_files:
        if new_files[file_name] != old_files[file_name]:
            print(f" - Modified {file_name}")

    for before_name, after_name in renamed_files:
        print(f" - Renamed {before_name} to {after_name}")

    for file_name in removed_files:
        print(f" - Removed {file_name}")

    for file_name in added_files:
        print(f" - Added {file_name}")


def generate_ports_json(all_ports, port_status, old_manifest, new_manifest):
    ports_json_output = {
        "ports": {},
        "utils": {},
        }

    for port_dir, port_data in sorted(all_ports.items(), key=lambda k: (k[1]['port_json']['attr']['title'].casefold())):
        if port_data['port_json']['version'] <= PORT_INFO_ROOT_ATTRS['version']:
            # Only add port.json files which are within the version specs.
            ports_json_output['ports'][port_data['name']] = port_data['port_json']
        else:
            print(f"- Skipping [{port_dir}] `port.json` version too new.")

        port_data['port_json']['attr']['image'] = port_data['image_files']

        port_info(
            RELEASE_DIR / port_data['name'],
            ports_json_output['ports'],
            port_status
            )

    ## Jank :|
    if REPO_CONFIG.get('SPLIT_IMAGES', "N") == "Y":
        print("- Building new images.xxx.zip")
        build_new_images_zip(old_manifest, new_manifest, port_status)

    utils = []

    if (RELEASE_DIR / 'PortMaster.zip').is_file():
        utils.append(RELEASE_DIR / 'PortMaster.zip')

    utils.append(RELEASE_DIR / 'gameinfo.zip')
    utils.append(RELEASE_DIR / 'images.zip')

    if REPO_CONFIG.get('SPLIT_IMAGES', "N") == "Y":
        for img_id in range(1000):
            image_xxx_zip = f"images.{img_id:03d}.zip"

            if image_xxx_zip not in new_manifest:
                break

            utils.append(RELEASE_DIR / image_xxx_zip)

    runtimes_map = {}

    if RUNTIMES_DIR.is_dir():
        if (RUNTIMES_DIR / 'runtimes.json').is_file():
            # print(f"Loading runtimes.json")

            with open((RUNTIMES_DIR / 'runtimes.json'), 'r') as fh:
                runtimes_json = json.load(fh)

            # print(json.dumps(runtimes_json, indent=4))

            for runtime_name, runtime_data in runtimes_json.items():
                runtime_nice_name = runtime_data['name']

                for runtime_arch, runtime_file_name in runtime_data['arch'].items():
                    if not (RUNTIMES_DIR / runtime_file_name).is_file():
                        error(runtime_file_name, f"Unknown runtime {runtime_file_name}")
                        continue

                    if runtime_arch == runtime_data['default']:
                        runtime_export_name = runtime_name
                    else:
                        runtime_export_name = runtime_file_name

                    runtimes_map[runtime_file_name] = {
                        'nice_name': runtime_nice_name,
                        'export_name': runtime_export_name,
                        'runtime_name': runtime_name,
                        'runtime_arch': runtime_arch,
                        }

                    utils.append(RUNTIMES_DIR / runtime_file_name)

            # print(json.dumps(runtimes_map, indent=4))

    for file_name in sorted(utils, key=lambda x: str(x).casefold()):
        util_info(
            file_name,
            ports_json_output['utils'],
            port_status,
            runtimes_map
            )

    with open(RELEASE_DIR / 'ports.json', 'w') as fh:
        json.dump(ports_json_output, fh, indent=4)


def load_manifest(manifest_file, registered=None):
    with open(manifest_file, 'r') as fh:
        manifest = json.load(fh)

    if registered is None:
        registered = {
            'dirs': {},
            'scripts': {},
            }

    for port_file in manifest:
        if '/' not in port_file:
            continue

        port_parts = port_file.split('/')

        if port_parts[1].lower().endswith('.sh'):
            if registered['scripts'].get(port_parts[1], None) not in (None, port_parts[0]):
                print(f"- ERROR: Port script {port_parts[1]} in multiple ports {port_parts[0]} and {registered['scripts'][port_parts[1]]}")
                continue

            registered['scripts'][port_parts[1]] = port_parts[0]

        if len(port_parts) > 2:
            if registered['dirs'].get(port_parts[1], None) not in (None, port_parts[0]):
                print(f"- ERROR: Port directory {port_parts[1]} in multiple ports {port_parts[0]} and {registered['dirs'][port_parts[1]]}")
                continue

            registered['dirs'][port_parts[1]] = port_parts[0]

    # print(json.dumps(registered, indent=4))

    return manifest


def main(argv):
    all_ports = {}
    updated_ports = []
    bad_ports = []

    new_manifest = {}
    old_manifest = {}

    port_status = {}
    file_cache = None

    if not GITHUB_RUN or CACHE_FILE.is_file():
        file_cache = HashCache(CACHE_FILE)

    registered = {
        'dirs': {},
        'scripts': {},
        }

    status = {
        "new": 0,
        "unchanged": 0,
        "updated": 0,
        "broken": 0,
        "total": 0,
        }

    if len(argv) > 1 and argv[1] == '--help':
        print(f"Usage:")
        print(f"   {argv[0]}                  builds any updated ports zip files, a full release cycle.   (SLOW)")
        print(f"   {argv[0]} --do-check       checks updated ports for errors.                            (SLOW)")
        print(f"   {argv[0]} --quick-build [portnames]   builds a port zip files without any extra stuff. (FAST)")
        return 255

    # Load global manifest
    if MANIFEST_FILE.is_file():
        old_manifest = load_manifest(MANIFEST_FILE, registered)

    if STATUS_FILE.is_file():
        with open(STATUS_FILE, 'r') as fh:
            port_status = json.load(fh)

    if len(argv) > 1 and argv[1] == '--quick-build':
        if len(argv) == 2:
            print(f"Usage {argv[0]} --quick-build [portname] [... portnames]")

        for name in argv[2:]:
            name = name_cleaner(name)
            if name.endswith('.zip'):
                name = name[:-4]

            port_dir = PORTS_DIR / name

            if not port_dir.is_dir():
                print(f"Unknown port {name!r}.zip")
                continue

            port_data = load_port(port_dir, new_manifest, registered, port_status, quick_build=True)
            if port_data is None:
                continue

            print(f"Building {name}.zip")
            build_port_zip(RELEASE_DIR, port_dir, port_data, new_manifest, port_status)

        for port_name, messages in MESSAGES.items():
            print(f"Bad port {port_name}")
            if len(messages['warnings']) > 0:
                print("- Warnings:")
                print("  " + "\n  ".join(messages['warnings']) + "\n")

            if len(messages['errors']) > 0:
                print("- Errors:")
                print("  " + "\n  ".join(messages['errors']) + "\n")

        return 0

    CHECK_FOR_SHIT = ('gameinfo.zip', )
    for check_for in CHECK_FOR_SHIT:
        if check_for in old_manifest and check_for not in port_status:
            del old_manifest[check_for]

    for port_dir in sorted(PORTS_DIR.iterdir(), key=lambda x: str(x).casefold()):
        if not port_dir.is_dir():
            continue

        port_data = load_port(port_dir, new_manifest, registered, port_status, hash_cache=file_cache)

        if port_data is None:
            status['broken'] += 1
            status['total'] += 1
            bad_ports.append(port_dir)
            continue

        if old_manifest.get(port_dir.name) != new_manifest[port_dir.name]:
            if old_manifest.get(port_dir.name) is None:
                status['new'] += 1
            else:
                status['updated'] += 1

            print(f"{port_dir.name}: {old_manifest.get(port_dir.name)} vs {new_manifest[port_dir.name]}")
            updated_ports.append(port_dir)
        else:
            status['unchanged'] += 1

        status['total'] += 1
        all_ports[port_dir.name] = port_data

    # with open('annoying.json', 'w') as fh:
    #     json.dump(THIS_IS_ANNOYING, fh, indent=4)

    for port_dir in updated_ports:
        port_data = all_ports[port_dir.name]

        print("-" * 40)
        print(f"- Creating {port_data['name']}")
        port_diff(port_dir.name, old_manifest, new_manifest)
        print("")

        if '--do-check' not in argv:
            build_port_zip(RELEASE_DIR, port_dir, port_data, new_manifest, port_status)

    if '--do-check' not in argv:
        build_images_zip(old_manifest, new_manifest)

        build_gameinfo_zip(old_manifest, new_manifest)

        generate_ports_json(all_ports, port_status, old_manifest, new_manifest)

    errors = 0
    warnings = 0

    for port_name, messages in MESSAGES.items():
        if '--do-check' in argv and (
                (PORTS_DIR / port_name) not in updated_ports and
                (PORTS_DIR / port_name) not in bad_ports):
            continue

        if GITHUB_RUN:
            for warning in messages['warnings']:
                print(f"::warning file=ports/{port_name}::{warning}")
                warnings += 1

            for error in messages['errors']:
                print(f"::error file=ports/{port_name}::{error}")
                errors += 1

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

    print(f"Changes:")
    print(f"  New:       {status['new']}")
    print(f"  Broken:    {status['broken']}")
    print(f"  Updated:   {status['updated']}")
    print(f"  Unchanged: {status['unchanged']}")
    print("")
    print(f"Total Ports: {status['total']}")

    if file_cache is not None:
        file_cache.save_cache()

    if '--do-check' in argv:
        if errors > 0:
            return 255

        if warnings > 0:
            return 127

    if '--do-check' not in argv:
        CHECK_FOR_SHIT = ('images.zip', )
        for check_for in CHECK_FOR_SHIT:
            if check_for in port_status:
                del port_status[check_for]

        with open(STATUS_FILE, 'w') as fh:
            json.dump(port_status, fh, sort_keys=True, indent=2)

        with open(MANIFEST_FILE, 'w') as fh:
            json.dump(new_manifest, fh, sort_keys=True, indent=2)

    if '--do-check' not in argv and len(argv) > 0:
        if status['unchanged'] == status['total']:
            if Path('.github_check').is_file():
                print("::error file=tools/build_release.py::No new ports, aborting.")
                return 255

    return 0


if __name__ == '__main__':
    exit(main(sys.argv))
