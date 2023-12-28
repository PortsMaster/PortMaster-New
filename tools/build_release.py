#!/usr/bin/env python3

import collections
import functools
import hashlib
import json
import os
import pathlib
import re
import shutil
import sys
import zipfile

from pathlib import Path

#############################################################################
## Constants
README_FILE, SCREENSHOT_FILE, COVER_FILE, SPEC_FILE, PORT_JSON, PORT_SCRIPT, PORT_DIR, UNKNOWN_FILE = range(8)

FILE_TYPE_RE = {
    r"^readme\.md$": README_FILE,
    r"^screenshot\.(png|jpg)$": SCREENSHOT_FILE,
    r"^cover\.(png|jpg)$": COVER_FILE,
    r"^port\.json$": PORT_JSON,
    r"^port\.spec$": SPEC_FILE,
    }

#############################################################################


################################################################################
## Port Information

PORT_INFO_ROOT_ATTRS = {
    'version': 2,
    'name': None,
    'items': None,
    'items_opt': None,
    'attr': {},
    }

PORT_INFO_ATTR_ATTRS = {
    'title': "",
    'desc': "",
    'inst': "",
    'genres': [],
    'porter': [],
    'image': None,
    'rtr': False,
    'exp': False,
    'runtime': None,
    'reqs': [],
    }


PORT_INFO_GENRES = [
    "action",
    "adventure",
    "arcade",
    "casino/card",
    "fps",
    "platformer",
    "puzzle",
    "racing",
    "rhythm",
    "rpg",
    "simulation",
    "sports",
    "strategy",
    "visual novel",
    "other",
    ]


def port_info_load(raw_info, source_name=None, do_default=False, port_log=None):
    if port_log is None:
        port_log = []

    if isinstance(raw_info, pathlib.PurePath):
        source_name = str(raw_info)

        with raw_info.open('r') as fh:
            try:
                info = json.load(fh)

            except json.decoder.JSONDecodeError as err:
                port_log.append(f"- Unable to load {source_name}: {err}")
                info = None

            if info is None or not isinstance(info, dict):
                if do_default:
                    info = {}
                else:
                    return None

    elif isinstance(raw_info, str):
        if raw_info.strip().startswith('{') and raw_info.strip().endswith('}'):
            if source_name is None:
                source_name = "<str>"

            try:
                info = json.loads(raw_info)

            except json.decoder.JSONDecodeError as err:
                port_log.append(f"- Unable to load {source_name}: {err}")
                info = None

            if info is None or not isinstance(info, dict):
                if do_default:
                    info = {}
                else:
                    return None

        elif Path(raw_info).is_file():
            source_name = raw_info

            with open(raw_info, 'r') as fh:
                try:
                    info = json.load(fh)

                except json.decoder.JSONDecodeError as err:
                    port_log.append(f"- Unable to load {source_name}: {err}")
                    info = None

                if info is None or not isinstance(info, dict):
                    if do_default:
                        info = {}
                    else:
                        return None

        else:
            if source_name is None:
                source_name = "<str>"

            port_log.append(f'- Unable to load port_info from {source_name!r}: {raw_info!r}')
            if do_default:
                info = {}
            else:
                return None

    elif isinstance(raw_info, dict):
        if source_name is None:
            source_name = "<dict>"

        info = raw_info

    else:
        port_log.append(f'- Unable to load port_info from {source_name!r}: {raw_info!r}')
        if do_default:
            info = {}
        else:
            return None

    if info.get('version', None) == 1 or 'source' in info:
        # Update older json version to the newer one.
        info = info.copy()
        info['name'] = info['source'].rsplit('/', 1)[-1]
        del info['source']
        info['version'] = 2

        if info.get('md5', None) is not None:
            info['status'] = {
                'source': "Unknown",
                'md5': info['md5'],
                'status': "Unknown",
                }
            del info['md5']

        # WHOOPS! :O
        if info.get('attr', {}).get('runtime', None) == "blank":
            info['attr']['runtime'] = None

    if isinstance(info.get('attr', {}).get('porter'), str):
        info['attr']['porter'] = [info['attr']['porter']]

    if isinstance(info.get('attr', {}).get('reqs', None), dict):
        info['attr']['reqs'] = [
            key
            for key in info['attr']['reqs']]

    if isinstance(info.get("version", None), str):
        info["version"] = int(info["version"])

    # This strips out extra stuff
    port_info = {}

    for attr, attr_default in PORT_INFO_ROOT_ATTRS.items():
        if isinstance(attr_default, (dict, list)):
            attr_default = attr_default.copy()

        port_info[attr] = info.get(attr, attr_default)

    for attr, attr_default in PORT_INFO_ATTR_ATTRS.items():
        if isinstance(attr_default, (dict, list)):
            attr_default = attr_default.copy()

        port_info['attr'][attr] = info.get('attr', {}).get(attr, attr_default)

    if port_info['attr']['image'] == None:
        port_info['attr']['image'] = {}

    if isinstance(port_info['items'], list):
        i = 0
        while i < len(port_info['items']):
            item = port_info['items'][i]
            if item.startswith('/'):
                port_log.append(f"- port_info['items'] contains bad name {item!r}")
                del port_info['items'][i]
                continue

            if item.startswith('../'):
                port_log.append(f"- port_info['items'] contains bad name {item!r}")
                del port_info['items'][i]
                continue

            if '/../' in item:
                port_log.append(f"- port_info['items'] contains bad name {item!r}")
                del port_info['items'][i]
                continue

            if item == "":
                port_log.append(f"- port_info['items'] contains bad name {item!r}")
                del port_info['items'][i]

            i += 1

    if isinstance(port_info['items_opt'], list):
        i = 0
        while i < len(port_info['items_opt']):
            item = port_info['items_opt'][i]
            if item.startswith('/'):
                port_log.append(f"- port_info['items_opt'] contains bad name {item}")
                del port_info['items_opt'][i]
                continue

            if item.startswith('../'):
                port_log.append(f"- port_info['items_opt'] contains bad name {item}")
                del port_info['items_opt'][i]
                continue

            if '/../' in item:
                port_log.append(f"- port_info['items_opt'] contains bad name {item}")
                del port_info['items_opt'][i]
                continue

            if item == "":
                port_log.append(f"- port_info['items'] contains bad name {item!r}")
                del port_info['items_opt'][i]

            i += 1

        if port_info['items_opt'] == []:
            port_info['items_opt'] = None

    if isinstance(port_info['attr'].get('genres', None), list):
        genres = port_info['attr']['genres']
        port_info['attr']['genres'] = []

        for genre in genres:
            if genre.casefold() in PORT_INFO_GENRES:
                port_info['attr']['genres'].append(genre.casefold())

    if port_info['attr']['image'] == None:
        port_info['attr']['image'] = {}

    if port_info['attr']['runtime'] == "blank":
        port_info['attr']['runtime'] = None

    if port_info['attr']['rtr'] is not False and port_info['attr']['inst'] in ("", None):
        port_info['attr']['inst'] = "Ready to run."

    return port_info


def runtime_nicename(runtime):
    if runtime.startswith("frt"):
        return ("Godot/FRT {version}").format(version=runtime.split('_', 1)[1].rsplit('.', 1)[0])

    if runtime.startswith("mono"):
        return ("Mono {version}").format(version=runtime.split('-', 1)[1].rsplit('-', 1)[0])

    if "jdk" in runtime and runtime.startswith("zulu11"):
        return ("JDK {version}").format(version=runtime.split('-')[2][3:])

    return runtime


def name_cleaner(text):
    temp = re.sub(r'[^a-zA-Z0-9 _\-\.]+', '', text.strip().lower())
    return re.sub(r'[ \.]+', '.', temp)


def hash_items(items):
    md5 = hashlib.md5()

    for item in items:
        print(f">{item}")
        md5.update(f"{item}\n".encode('utf-8'))

    print(f"<{md5.hexdigest()}")
    return md5.hexdigest()


def hash_file(file_name):
    if isinstance(file_name, str):
        file_name = pathlib.Path(file_name)

    elif not isinstance(file_name, pathlib.PurePath):
        raise ValueError(file_name)

    if not file_name.is_file():
        return None

    md5 = hashlib.md5()
    with file_name.open('rb') as fh:
        md5.update(fh.read())

    return md5.hexdigest()


def file_type(port_file):
    if port_file.is_dir():
        return PORT_DIR

    for file_pattern, file_type in FILE_TYPE_RE.items():
        if re.match(file_pattern, port_file.name, re.I):
            return file_type

    if port_file.name.lower().endswith('.sh'):
        return PORT_SCRIPT

    return UNKNOWN_FILE


def port_zip_name(port_data, file_name, port_file_type):
    port_name = port_data['name'].rsplit('.', 1)[0]


def load_port(port_dir, manifest):
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

    for port_file in port_dir.iterdir():
        port_file_type = file_type(port_file)

        if port_file_type == UNKNOWN_FILE:
            print(f"{port_dir.name}: Unknown file: {port_file.name}")
            continue

        if port_file_type == PORT_SCRIPT:
            port_data['scripts'].append(port_file.name)
            port_data['items'].append(port_file.name)

        if port_file_type == PORT_DIR:
            port_data['items'].append(port_file.name + '/')
            port_data['dirs'].append(port_file.name + '/')

        if port_file_type == PORT_JSON:
            port_data['port_json'] = port_info_load(port_file)
            port_data['name'] = name_cleaner(port_data['port_json']['name'])

            if not port_data['name'].endswith('.zip'):
                print(f"- bad 'name' in port.json: {port_data['name']}")
                port_data['port_json'] = None
                continue

        port_data['files'][port_file.name] = port_file_type

    # Create the manifest (an md5sum of all the files in the port, and an md5sum of those md5sums).
    temp = []
    paths = collections.deque([port_dir])
    port_manifest = []

    while len(paths) > 0:
        path = paths.popleft()

        for file_name in path.iterdir():
            if file_name.name in ('.', '..', '.git', '.DS_Store'):
                continue

            if file_name.name.startswith('._'):
                continue

            if file_name.is_dir():
                paths.append(file_name)
                continue

            if file_name.is_file():
                temp = hash_file(file_name)
                manifest[str(file_name)] = temp
                port_manifest.append((str(file_name), temp))

                continue

            print(f"{port_dir.name}: Unknown file: {file_name}")

    port_manifest.sort(key=lambda x: x[0].casefold())

    manifest[str(port_dir)] = hash_items(port_manifest)

    return port_data


def build_port_zip(port_data):
    with zipfile.ZipFile(zip_name, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as zf:
        for file_pair in all_files:
            zf.write(file_pair[1], file_pair[0])


def build_images_zip(ports):
    with zipfile.ZipFile(zip_name, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as zf:
        for file_pair in all_files:
            zf.write(file_pair[1], file_pair[0])


def main(argv):
    RESTORE_DIR = Path().cwd()
    ROOT_DIR = Path('.')

    MANIFEST_FILE = ROOT_DIR / 'manifest.json'

    ports = []
    new_manifest = {}
    old_manifest = {}

    if MANIFEST_FILE.is_file():
        with open(MANIFEST_FILE, 'r') as fh:
            old_manifest = json.load(fh)

    for port_dir in sorted(ROOT_DIR.iterdir(), key=lambda x: str(x).casefold()):
        if not port_dir.is_dir():
            continue

        if port_dir.name.lower() in ('.git', 'tools'):
            continue

        port_data = load_port(port_dir, new_manifest)

        if old_manifest.get(str(port_dir)) == new_manifest[str(port_dir)]:
            # print(f"Loading {port_dir.name}")
            # print(f"- skipped")
            continue

        print(f"Loading {port_dir.name}")
        print(f"- updating")
        ports.append(port_data)

    # for port in ports:
    #     create_zip(port)

    with open('dump.json', 'w') as fh:
        json.dump(ports, fh, indent=4)

    with open(MANIFEST_FILE, 'w') as fh:
        json.dump(new_manifest, fh, indent=1)


if __name__ == '__main__':
    main(sys.argv)
