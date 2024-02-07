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

if len(sys.argv) > 1 and sys.argv[1] != '--do-check':
    CURRENT_RELEASE_ID = sys.argv[1]
else:
    CURRENT_RELEASE_ID = "latest"

#############################################################################


def current_release_url(release_id):
    if release_id == 'latest':
        return f"https://github.com/{REPO_CONFIG['RELEASE_ORG']}/{REPO_CONFIG['RELEASE_REPO']}/releases/latest/download/"

    return f"https://github.com/{REPO_CONFIG['RELEASE_ORG']}/{REPO_CONFIG['RELEASE_REPO']}/releases/download/{release_id}/"


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


def load_port(port_dir, manifest, registered, port_status, quick_build=False):
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
            "cover": None,
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
            port_data['image_files']['cover'] = '.'.join((port_dir.name, port_file.name))

        elif port_file_type == SCREENSHOT_FILE:
            port_data['image_files']['screenshot'] = '.'.join((port_dir.name, port_file.name))

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
            if port_data['port_json'] is None:
                return None

            port_data['port_json_file'] = port_file
            port_data['name'] = name_cleaner(port_data['port_json']['name'])

            if not port_data['name'].endswith('.zip'):
                warning(port_dir.name, f"bad 'name' in port.json: {port_data['name']}")
                port_data['name'] += '.zip'

        port_data['files'][port_file.name] = port_file_type

    if port_data['name'] not in port_status:
        port_date = TODAY
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

            if not quick_build:
                temp = hash_file(file_name)
                manifest[port_file_name] = temp
                port_manifest.append((port_file_name, temp))

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

    if clean_name in ports_json:
        ports_json[clean_name]['source'] = ports_status[clean_name].copy()
        ports_json[clean_name]['source']['url'] = current_release_url(ports_status[clean_name]['release_id']) + (file_name.name.replace(" ", ".").replace("..", "."))


def util_info(file_name, util_json):
    clean_name = name_cleaner(file_name.name)

    file_md5 = hash_file(file_name)

    if file_name.name.lower().endswith('.squashfs'):
        name = runtime_nicename(file_name.name)
        url = "https://github.com/PortsMaster/PortMaster-Runtime/releases/download/runtimes/" + (file_name.name.replace(" ", ".").replace("..", "."))

    else:
        name = file_name.name
        url = current_release_url(CURRENT_RELEASE_ID) + (file_name.name.replace(" ", ".").replace("..", "."))

    util_json[clean_name] = {
        "name": name,
        'md5': file_md5,
        'size': file_name.stat().st_size,
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


def generate_ports_json(all_ports, port_status):
    ports_json_output = {
        "ports": {},
        "utils": {},
        }

    for port_dir, port_data in sorted(all_ports.items(), key=lambda k: (k[1]['port_json']['attr']['title'].casefold())):
        ports_json_output['ports'][port_data['name']] = port_data['port_json']

        port_data['port_json']['attr']['image'] = port_data['image_files']

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
    bad_ports = []

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


    for port_dir in sorted(PORTS_DIR.iterdir(), key=lambda x: str(x).casefold()):
        if not port_dir.is_dir():
            continue

        port_data = load_port(port_dir, new_manifest, registered, port_status)

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
        if '--do-check' in argv and (
                (PORTS_DIR / port_name) not in updated_ports and
                (PORTS_DIR / port_name) not in bad_ports):
            continue

        if Path('.github_check').is_file():
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
            if Path('.github_check').is_file():
                print("::error file=tools/build_release.py::No new ports, aborting.")
                return 255

    return 0


if __name__ == '__main__':
    exit(main(sys.argv))
