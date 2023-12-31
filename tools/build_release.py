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

TODAY = str(datetime.datetime.today().date())
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


MESSAGES = {}
def error(port_name, string):
    MESSAGES.setdefault(port_name, {'errors': [], 'warnings': []})
    MESSAGES[port_name]['errors'].append(message)


def warning(port_name, message):
    MESSAGES.setdefault(port_name, {'errors': [], 'warnings': []})
    MESSAGES[port_name]['warnings'].append(message)


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
        # print(f">{item}")
        md5.update(f"{item}\n".encode('utf-8'))

    # print(f"<{md5.hexdigest()}")
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

    for port_file in port_dir.iterdir():
        port_file_type = file_type(port_file)

        if port_file_type == UNKNOWN_FILE:
            print(f"{port_dir.name}: Unknown file: {port_file.name}")
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


def build_port_zip(root_dir, port_dir, port_data, new_manifest):
    port_name = port_data['name'].rsplit('.', 1)[0]
    zip_name = root_dir / port_data['name']

    spec_file = port_dir / 'port.spec'

    # If a port.spec file exists, we run it.
    if spec_file.is_file():
        with change_dir(port_dir):
            os.chmod('port.spec', 0o755)
            subprocess.call("./port.spec", shell=True)

    paths = collections.deque([port_dir])
    zip_files = []

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

            new_name = '/'.join(file_name.parts[1:])

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

            zip_files.append((file_name, new_name))

    zip_files.sort(key=lambda x: x[1].casefold())

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
        (Path(file), f"{file.replace('/', '.')}")
        for file, digest in new_manifest.items()
        if file.count('/') == 1 and file_type(Path(file)) == SCREENSHOT_FILE]

    with zipfile.ZipFile('images.zip', 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as zf:
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


def load_manifest(manifest_file):
    with open(manifest_file, 'r') as fh:
        manifest = json.load(fh)

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

    return manifest, registered


def main(argv):
    RESTORE_DIR = Path().cwd()
    ROOT_DIR = Path('.')

    MANIFEST_FILE = ROOT_DIR / 'manifest.json'
    STATUS_FILE = ROOT_DIR / 'ports_status.json'

    all_ports = {}
    updated_ports = []

    new_manifest = {}
    old_manifest = {}

    port_status = {}

    registered = {
        'dirs': {},
        'scripts': {},
        }

    if MANIFEST_FILE.is_file():
        old_manifest, registered = load_manifest(MANIFEST_FILE)

    if STATUS_FILE.is_file():
        with open(STATUS_FILE, 'r') as fh:
            port_status = json.load(fh)

    for port_dir in sorted(ROOT_DIR.iterdir(), key=lambda x: str(x).casefold()):
        if not port_dir.is_dir():
            continue

        if port_dir.name.lower() in ('.git', 'tools'):
            continue

        port_data = load_port(port_dir, new_manifest, registered)

        if port_data is None:
            continue

        # print(f"{port_dir.name}: {old_manifest.get(port_dir.name)} vs {new_manifest[port_dir.name]}")
        if old_manifest.get(port_dir.name) != new_manifest[port_dir.name]:
            updated_ports.append(port_dir)

        all_ports[port_dir] = port_data

    for port_dir in updated_ports:
        port_data = all_ports[port_dir]

        print("-" * 40)
        print(f"- Creating {port_data['name']}")
        port_diff(port_dir.name, old_manifest, new_manifest)
        print("")

        if '--do-check' not in argv:
            build_port_zip(ROOT_DIR, port_dir, port_data, new_manifest, port_status)

    if '--do-check' not in argv:
        build_images_zip(old_manifest, new_manifest)

        build_markdown_zip(old_manifest, new_manifest)

        generate_ports_json(ports)

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

    return 0


if __name__ == '__main__':
    exit(main(sys.argv))
