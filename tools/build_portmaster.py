#!/usr/bin/env python3

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
## Change these to point to your PortMaster repo
PORTMASTER_DIR = Path("../PortMaster")

#############################################################################

HM_GENRES = [
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
    'image': {},
    'arch': [],
    'rtr': False,
    'exp': False,
    'runtime': None,
    'reqs': [],
    }


PORT_INFO_OPTIONAL_ROOT_ATTRS = [
    'status',
    'files',
    'source',
    ]


def port_info_load(raw_info, source_name=None, do_default=False):
    if isinstance(raw_info, pathlib.PurePath):
        source_name = str(raw_info)

        with raw_info.open('r') as fh:
            info = json_safe_load(fh)
            if info is None or not isinstance(info, dict):
                if do_default:
                    info = {}
                else:
                    return None

    elif isinstance(raw_info, str):
        if raw_info.strip().startswith('{') and raw_info.strip().endswith('}'):
            if source_name is None:
                source_name = "<str>"

            info = json_safe_loads(info)
            if info is None or not isinstance(info, dict):
                if do_default:
                    info = {}
                else:
                    return None

        elif Path(raw_info).is_file():
            source_name = raw_info

            with open(raw_info, 'r') as fh:
                info = json_safe_load(fh)
                if info is None or not isinstance(info, dict):
                    if do_default:
                        info = {}
                    else:
                        return None

        else:
            if source_name is None:
                source_name = "<str>"

            print(f'Unable to load port_info from {source_name!r}: {raw_info!r}')
            if do_default:
                info = {}
            else:
                return None

    elif isinstance(raw_info, dict):
        if source_name is None:
            source_name = "<dict>"

        info = raw_info

    else:
        print(f'Unable to load port_info from {source_name!r}: {raw_info!r}')
        if do_default:
            info = {}
        else:
            return None

    if info.get('version', None) == 1:
        # Update older json version to the newer one.
        info = info.copy()
        if 'source' in info and isinstance(info['source'], str):
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

    for attr in PORT_INFO_OPTIONAL_ROOT_ATTRS:
        if attr in info:
            port_info[attr] = info[attr]

    if isinstance(port_info['items'], list):
        i = 0
        while i < len(port_info['items']):
            item = port_info['items'][i]
            if item.startswith('/'):
                print(f"port_info['items'] contains bad name {item!r}")
                del port_info['items'][i]
                continue

            if item.startswith('../'):
                print(f"port_info['items'] contains bad name {item!r}")
                del port_info['items'][i]
                continue

            if '/../' in item:
                print(f"port_info['items'] contains bad name {item!r}")
                del port_info['items'][i]
                continue

            if item == "":
                print(f"port_info['items'] contains bad name {item!r}")
                del port_info['items'][i]

            i += 1

    if isinstance(port_info['items_opt'], list):
        i = 0
        while i < len(port_info['items_opt']):
            item = port_info['items_opt'][i]
            if item.startswith('/'):
                print(f"port_info['items_opt'] contains bad name {item}")
                del port_info['items_opt'][i]
                continue

            if item.startswith('../'):
                print(f"port_info['items_opt'] contains bad name {item}")
                del port_info['items_opt'][i]
                continue

            if '/../' in item:
                print(f"port_info['items_opt'] contains bad name {item}")
                del port_info['items_opt'][i]
                continue

            if item == "":
                print(f"port_info['items'] contains bad name {item!r}")
                del port_info['items_opt'][i]

            i += 1

        if port_info['items_opt'] == []:
            port_info['items_opt'] = None

    if isinstance(port_info['attr'].get('genres', None), list):
        genres = port_info['attr']['genres']
        port_info['attr']['genres'] = []

        for genre in genres:
            if genre.casefold() in HM_GENRES:
                port_info['attr']['genres'].append(genre.casefold())

    return port_info


def port_info_merge(port_info, other):
    if isinstance(other, (str, pathlib.PurePath)):
        other_info = port_info_load(other)
    elif isinstance(other, dict):
        other_info = other
    else:
        print(f"Unable to merge {other!r}")
        return None

    for attr, attr_default in PORT_INFO_ROOT_ATTRS.items():
        if attr == 'attr':
            continue

        value_a = port_info[attr]
        value_b = other_info[attr]

        if value_a is None or value_a == "" or value_a == []:
            port_info[attr] = value_b
            continue

        if value_b in (True, False) and value_a in (True, False, None):
            port_info[attr] = value_b
            continue

        if isinstance(value_b, str) and value_a in ("", None):
            port_info[attr] = value_b
            continue

        if isinstance(value_b, list) and value_a in ([], None):
            port_info[attr] = value_b[:]
            continue

        if isinstance(value_b, dict) and value_a in ({}, None):
            port_info[attr] = value_b.copy()
            continue

    for attr in PORT_INFO_OPTIONAL_ROOT_ATTRS:
        if attr not in other_info:
            continue

        value_a = port_info.get(attr)
        value_b = other_info[attr]

        if isinstance(value_b, str) and value_a in ("", None):
            port_info[attr] = value_b
            continue

        if isinstance(value_b, list) and value_a in ([], None):
            port_info[attr] = value_b[:]
            continue

        if isinstance(value_b, dict) and value_a in ({}, None):
            port_info[attr] = value_b.copy()
            continue

    for key_b, value_b in other_info['attr'].items():
        if key_b not in port_info['attr']:
            continue

        if value_b in (True, False) and port_info['attr'][key_b] in (True, False, None):
            port_info['attr'][key_b] = value_b
            continue

        if isinstance(value_b, str) and port_info['attr'][key_b] in ("", None):
            port_info['attr'][key_b] = value_b
            continue

        if isinstance(value_b, list) and port_info['attr'][key_b] in ([], None):
            port_info['attr'][key_b] = value_b[:]
            continue

        if isinstance(value_b, dict) and port_info['attr'][key_b] in ({}, None):
            port_info['attr'][key_b] = value_b.copy()
            continue

    return port_info


@functools.lru_cache(maxsize=512)
def name_cleaner(text):
    temp = re.sub(r'[^a-zA-Z0-9 _\-\.]+', '', text.strip().lower())
    return re.sub(r'[ \.]+', '.', temp)


class ZipPort():
    def __init__(self, zip_file):
        self.load_port(zip_file)

    def load_port(self, zip_file):
        self.zip_file = zip_file

        self.port_name = name_cleaner(zip_file.stem)

        self.port_dir = Path("ports/") / self.port_name
        self.file_structure = {}

        self.file_structure[self.port_dir] = None

        for image_file in (zip_file.parent / "images").glob(f"{self.port_name}.*"):
            new_name = self.port_dir / '.'.join(image_file.name.rsplit('.', 2)[-2:])
            self.file_structure[new_name] = image_file

        for markdown in (zip_file.parent / "markdown").glob(f"{self.port_name}.*"):
            new_name = self.port_dir / "README.md"
            self.file_structure[new_name] = markdown

        self.items = []
        self.dirs = []
        self.scripts = []
        self.files = []
        self.port_info_file = None

        with zipfile.ZipFile(zip_file, 'r') as zf:
            for file_info in zf.infolist():
                final_name = self.port_dir / file_info.filename

                if file_info.filename.endswith('/'):
                    self.file_structure[final_name] = None
                    continue

                if '/' in file_info.filename:
                    parts = file_info.filename.split('/')

                    if parts[0] not in self.dirs:
                        self.items.append(parts[0] + '/')
                        self.dirs.append(parts[0])

                    if len(parts) == 2:
                        if parts[1].lower().endswith('.port.json'):
                            self.port_info_file = file_info.filename

                else:
                    if file_info.filename.lower().endswith('.sh'):
                        self.scripts.append(file_info.filename)
                        self.items.append(file_info.filename)
                    else:
                        print(f"Port {port_name} contains {file_info.filename} at the top level, but it is not a shell script.")

                self.file_structure[final_name] = file_info.filename

            if self.port_info_file is not None:
                port_info_data = json.loads(zf.read(self.port_info_file).decode('utf-8'))

                if not isinstance(port_info_data, dict):
                    print(f"Unable to load port.json file from {port_info_file}")
                    raise Exception("Bad port.json file")

                self.port_info = port_info_load(port_info_data)

            else:
                port_info_data = None
                self.port_info_file = f"{dirs[0]}/{(name_cleaner(port_name.rsplit('.', 1)[0]) + '.port.json')}"

                print(f"No port info file found, recommended name is {port_info_file}")
                self.port_info = port_info_load({})

        ## These two are always overriden.
        self.port_info['name'] = name_cleaner(self.port_name)
        self.port_info['items'] = self.items

    def extract(self):
        with zipfile.ZipFile(self.zip_file, 'r') as zf:
            for final_name, source_name in self.file_structure.items():
                if source_name is None:
                    final_name.mkdir(parents=True, exist_ok=True)
                    continue

                elif isinstance(source_name, str):
                    zf.extract(source_name, path=self.port_dir)

                elif isinstance(source_name, pathlib.PurePath):
                    shutil.copy(source_name, final_name)

                else:
                    print(f"Unknown file: {source_name}")

        if self.port_info_file is not None:
            (self.port_dir / self.port_info_file).rename(self.port_dir / "port.json")


def load_ports(port_dir):
    ports = []

    for file_name in sorted(port_dir.iterdir(), key=lambda x: x.name.casefold()):
        if not file_name.is_file():
            continue

        if file_name.suffix.lower() != '.zip':
            continue

        ports.append(ZipPort(file_name))

    return ports


def main(argv):
    if '--yes-run-please' not in argv:
        print("Only run this if you know what you're doing.")
        return 255

    ports = load_ports(PORTMASTER_DIR)

    low_argv = list(map(str.lower, argv))

    for port in ports:
        if port.zip_file.name.lower() not in low_argv:
            print(f"- {port.port_name} skipping.")
            continue

        print(f"- {port.port_name}")
        port.extract()

    return 0


if __name__ == '__main__':
    exit(main(sys.argv))
