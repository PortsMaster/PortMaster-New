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
README_FILE, SCREENSHOT_FILE, COVER_FILE, SPEC_FILE, PORT_JSON, PORT_SCRIPT, PORT_DIR, GITIGNORE_FILE, UNKNOWN_FILE = range(9)
REQUIRED_FILES = (
    (1<<README_FILE)     |
    (1<<SCREENSHOT_FILE) |
    (1<<PORT_JSON)       |
    (1<<PORT_SCRIPT)     |
    (1<<PORT_DIR)        )

FILE_TYPE_DESC = {
    README_FILE: "README.md",
    SCREENSHOT_FILE: "screenshot.{png|jpg}",
    COVER_FILE:  "cover.{png|jpg}",
    SPEC_FILE:   "port.spec",
    PORT_JSON:   "port.json",
    PORT_SCRIPT: "Port Script",
    PORT_DIR:    "Port Directory",
    GITIGNORE_FILE: ".gitginore",
    UNKNOWN_FILE: "Unknown file",
    }

FILE_TYPE_RE = {
    r"^\.gitignore$": GITIGNORE_FILE,
    r"^readme\.md$": README_FILE,
    r"^screenshot\.(png|jpg)$": SCREENSHOT_FILE,
    r"^cover\.(png|jpg)$": COVER_FILE,
    r"^port\.json$": PORT_JSON,
    # r"^port\.spec$": SPEC_FILE,
    }

TODAY = str(datetime.datetime.today().date())

ROOT_DIR = Path('.')

RELEASE_DIR = ROOT_DIR / 'releases'
MANIFEST_FILE = RELEASE_DIR / 'manifest.json'
STATUS_FILE = RELEASE_DIR / 'ports_status.json'
PORTS_DIR = ROOT_DIR / 'ports'

LARGEST_FILE = (1024 * 1024 * 90)

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
## Stuff.
BASE_RELEASE_URL = f"https://github.com/{REPO_CONFIG['RELEASE_ORG']}/{REPO_CONFIG['RELEASE_REPO']}/releases/latest/download/"

if len(sys.argv) > 1 and sys.argv[1] != '--do-check':
    CURRENT_RELEASE_URL = f"https://github.com/{REPO_CONFIG['RELEASE_ORG']}/{REPO_CONFIG['RELEASE_REPO']}/releases/download/{sys.argv[1]}/"

else:
    CURRENT_RELEASE_URL = BASE_RELEASE_URL

#############################################################################


def runtime_nicename(runtime):
    if runtime.startswith("frt"):
        return ("Godot/FRT {version}").format(version=runtime.split('_', 1)[1].rsplit('.', 1)[0])

    if runtime.startswith("mono"):
        return ("Mono {version}").format(version=runtime.split('-', 1)[1].rsplit('-', 1)[0])

    if "jdk" in runtime and runtime.startswith("zulu11"):
        return ("JDK {version}").format(version=runtime.split('-')[2][3:])

    return runtime


def file_type(port_file):
    if port_file.is_dir():
        return PORT_DIR

    for file_pattern, file_type in FILE_TYPE_RE.items():
        if re.match(file_pattern, port_file.name, re.I):
            return file_type

    if port_file.name.lower().endswith('.sh'):
        return PORT_SCRIPT

    return UNKNOWN_FILE


def load_port(port_dir, manifest, registered):
    port_data = {
        'name': None,
        'port_json': None,

        'files': {},

        'items': [],
        'dirs': [],
        'scripts': [],

        'zip_files': [],
        'image_files': [],
        }

    if port_dir.name != name_cleaner(port_dir.name):
        error(port_dir.name, "Bad port directory name")
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
            port_data['port_json'] = port_info_load(port_file)
            port_data['name'] = name_cleaner(port_data['port_json']['name'])

            if not port_data['name'].endswith('.zip'):
                warning(port_dir.name, f"bad 'name' in port.json: {port_data['name']}")
                port_data['name'] += '.zip'

        port_data['files'][port_file.name] = port_file_type

    if len(port_data['dirs']) == 0:
        error(port_file.name, "Port has no directories")
        return None

    if len(port_data['scripts']) == 0:
        error(port_file.name, "Port has no scripts")
        return None

    if port_data['port_json'] == None:
        error(port_file.name, "Port has no port.json")
        return None

    port_check_bf &= REQUIRED_FILES
    if port_check_bf != REQUIRED_FILES:
        for i in range(UNKNOWN_FILE):
            CHECKER = (1 << i)
            if (CHECKER & REQUIRED_FILES) == 0:
                continue

            if (port_check_bf & CHECKER) == 0:
                error(port_dir.name, f"Missing {FILE_TYPE_DESC[i]}.")

    # Create the manifest (an md5sum of all the files in the port, and an md5sum of those md5sums).
    temp = []
    paths = collections.deque([port_dir])
    port_manifest = []
    large_files = {}

    while len(paths) > 0:
        path = paths.popleft()

        for file_name in path.iterdir():
            if file_name.name in ('.', '..', '.git', '.DS_Store', '.gitignore', '.gitkeep'):
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

            temp = hash_file(file_name)
            manifest[port_file_name] = temp
            port_manifest.append((port_file_name, temp))

    for large_file, large_file_status in large_files.items():
        if not large_file_status:
            error(port_dir.name, f"Missinge large_file: {large_file}, run python data/build_data.py first.")
            return None

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
                    new_name = port_data['dirs'][0] + f"{port_name}.{new_name}"

                elif file_name_type == README_FILE:
                    new_name = port_data['dirs'][0] + f"{port_name}.md"

                elif file_name_type == PORT_JSON:
                    new_name = port_data['dirs'][0] + f"{port_name}.port.json"

                elif file_name_type in (SPEC_FILE, UNKNOWN_FILE):
                    continue

            else:
                if new_name.lower().endswith('.sh'):
                    warning(port_dir.name, f"Script {new_name} found in port directories, this can cause issues.")

            if file_name.name[-9:-3] == '.part.' and file_name.name[-3:].isdigit():
                continue

            zip_files.append((file_name, new_name))

    zip_files.sort(key=lambda x: x[1].casefold())

    # from pprint import pprint
    # pprint(zip_files)

    with zipfile.ZipFile(zip_name, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as zf:
        for file_pair in zip_files:
            zf.write(file_pair[0], file_pair[1])

    port_name = port_data['name']
    port_hash = hash_file(zip_name)

    if port_name in port_status:
        port_status[port_name]['date_updated'] = TODAY
        port_status[port_name]['md5'] = port_hash

    else:
        port_status[port_name] = {
            'date_added': TODAY,
            'date_updated': TODAY,
            'md5': port_hash,
            }


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

    file_md5 = hash_file(file_name)

    default_status = {
        'md5': file_md5,
        'date_added': TODAY,
        'date_updated': TODAY,
        }

    if clean_name not in ports_status:
        ports_status[clean_name] = default_status

    elif ports_status[clean_name]['md5'] is None:
        ports_status[clean_name]['md5'] = file_md5

    elif ports_status[clean_name]['md5'] != file_md5:
        ports_status[clean_name]['md5'] = file_md5
        ports_status[clean_name]['date_updated'] = TODAY

    if clean_name in ports_json:
        ports_json[clean_name]['source'] = ports_status[clean_name].copy()

        ports_json[clean_name]['source']['size'] = file_name.stat().st_size
        ports_json[clean_name]['source']['url'] = CURRENT_RELEASE_URL + (file_name.name.replace(" ", ".").replace("..", "."))


def util_info(file_name, util_json):
    clean_name = name_cleaner(file_name.name)

    file_md5 = hash_file(file_name)

    if file_name.name.lower().endswith('.squashfs'):
        name = runtime_nicename(file_name.name)

    else:
        name = file_name.name

    util_json[clean_name] = {
        "name": name,
        'md5': file_md5,
        'size': file_name.stat().st_size,
        'url': CURRENT_RELEASE_URL + (file_name.name.replace(" ", ".").replace("..", ".")),
        }


def port_diff(port_name, old_manifest, new_manifest):
    """
    Print file changes
    TODO: detect file renames
    """
    changes = {}
    differ = Differ()

    new_files = [
        f"{file.split('/', 1)[-1]}:{digest}"
        for file, digest in new_manifest.items()
        if file.startswith(port_name + '/')]

    old_files = [
        f"{file.split('/', 1)[-1]}:{digest}"
        for file, digest in old_manifest.items()
        if file.startswith(port_name + '/')]

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

    for name, mode in changes.items():
        print(f" - {mode} {name}")


def generate_ports_json(all_ports, port_status):
    ports_json_output = {
        "ports": {},
        "utils": {},
        }

    for port_dir, port_data in sorted(all_ports.items(), key=lambda k: (k[1]['port_json']['attr']['title'].casefold())):
        ports_json_output['ports'][port_data['name']] = port_data['port_json']
        port_info(
            RELEASE_DIR / port_data['name'],
            ports_json_output['ports'],
            port_status
            )

    utils = []

    if (RELEASE_DIR / 'PortMaster.zip').is_file():
        utils.append(RELEASE_DIR / 'PortMaster.zip')

    utils.append(RELEASE_DIR / 'images.zip')
    utils.extend(RELEASE_DIR.glob('*.squashfs'))

    for file_name in sorted(utils, key=lambda x: str(x).casefold()):
        util_info(
            file_name,
            ports_json_output['utils']
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

    new_manifest = {}
    old_manifest = {}

    port_status = {}

    registered = {
        'dirs': {},
        'scripts': {},
        }

    status = {
        "new": 0,
        "unchanged": 0,
        "updated": 0,
        "total": 0,
        }

    # Load global manifest
    if MANIFEST_FILE.is_file():
        old_manifest = load_manifest(MANIFEST_FILE, registered)

    if STATUS_FILE.is_file():
        with open(STATUS_FILE, 'r') as fh:
            port_status = json.load(fh)

    for port_dir in sorted(PORTS_DIR.iterdir(), key=lambda x: str(x).casefold()):
        if not port_dir.is_dir():
            continue

        port_data = load_port(port_dir, new_manifest, registered)

        if port_data is None:
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

        # build_markdown_zip(old_manifest, new_manifest)

        generate_ports_json(all_ports, port_status)

    errors = 0
    warnings = 0
    for port_name, messages in MESSAGES.items():
        if '--do-check' not in argv and port_name not in updated_ports:
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
    print(f"  Updated:   {status['updated']}")
    print(f"  Unchanged: {status['unchanged']}")
    print("")
    print(f"Total Ports: {status['total']}")

    if '--do-check' in argv:
        if errors > 0:
            return 255

        if warnings > 0:
            return 127

    if '--do-check' not in argv:
        with open(STATUS_FILE, 'w') as fh:
            json.dump(port_status, fh, indent=2)

        with open(MANIFEST_FILE, 'w') as fh:
            json.dump(new_manifest, fh, indent=2)

    if '--do-check' not in argv and len(argv) > 0:
        if status['unchanged'] == status['total']:
            print("::error file=tools/build_release.py::No new ports, aborting.")
            return 255

    return 0


if __name__ == '__main__':
    exit(main(sys.argv))
