#!/usr/bin/env python3

import datetime
import functools
import hashlib
import json
import os
import pathlib
import re
import shutil
import sys
import zipfile

from difflib import Differ
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent / 'libs'))

from util import *

"""

Runtimes are one of the core features of PortMaster, ideally the devices are able to connect to the internet
and download runtimes when ports are installed.

However a popular device class without wifi has become prevalent, and thus we are having issues with runtimes
not being present on the device when they manually install ports.

The purpose of this latest addition is to create runtimes.zips of various flavours.

We create a runtimes.full.ARCH.zip for each architecture (currently aarch64 and x86_64), if the size of the
`runtimes.full.ARCH.zip` gets over `POPULAR_THRESHOLD` we create a `runtimes.popular.ARCH.zip` that is at maximum
`POPULAR_SIZE`, which is a bit more palatable.

Once the `runtimes.full.ARCH.zip` is larger than `MAXIMUM_THRESHOLD` it will split the archive into
`MAXIMUM_SPLIT_SIZE` pieces, the file is then named `runtimes.full.001.ARCH.zip`.

This file generatees a runtimes_zips.json, it will also updates its info in `manifest.json` and `ports_status.json`.

"""


#############################################################################
## Variables
ROOT_DIR = Path('.')

CACHE_FILE    = ROOT_DIR / '.hash_cache'
RELEASE_DIR   = ROOT_DIR / 'releases'
RUNTIMES_DIR  = ROOT_DIR / 'runtimes'
MANIFEST_FILE = RELEASE_DIR / 'manifest.json'
STATUS_FILE   = RELEASE_DIR / 'ports_status.json'
GITHUB_RUN    = (ROOT_DIR / '.github_check').is_file()

POPULAR_THRESHOLD  = (1024 * 1024 * 1024) # If it reaches this size, we create a Popular zip.
POPULAR_SIZE       = (1024 * 1024 *  600) # Aim for this amount.
MAXIMUM_THRESHOLD  = (1024 * 1024 * 2000) # This is a maximum amount for a github release attachment.
MAXIMUM_SPLIT_SIZE = (1024 * 1024 * 1100) # Once the maximum threshold is hit, we instead split it into zips this size.

ALL_ARCH          = {'aarch64': '', 'x86_64': ' (x86_64)'}

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

TODAY = str(datetime.datetime.today().date())

if len(sys.argv) > 1:
    CURRENT_RELEASE_ID = sys.argv[1]
else:
    CURRENT_RELEASE_ID = "latest"


#############################################################################
def nice_size(size):
    """
    Make nicer data sizes.
    """

    suffixes = ('B', 'KB', 'MB', 'GB', 'TB')
    for suffix in suffixes:
        if size < 768:
            break

        size /= 1024

    if suffix == 'B':
        return f"{size:.0f} {suffix}"

    return f"{size:.02f} {suffix}"


def current_release_url(release_id):
    if release_id == 'latest':
        return f"https://github.com/{REPO_CONFIG['RELEASE_ORG']}/{REPO_CONFIG['RELEASE_REPO']}/releases/latest/download/"

    return f"https://github.com/{REPO_CONFIG['RELEASE_ORG']}/{REPO_CONFIG['RELEASE_REPO']}/releases/download/{release_id}/"


def json_load(file_name):
    with open(file_name, 'r') as fh:
        return json.load(fh)


def calculate_popularity(runtimes, PORT_STATS_DATA, ALL_PORTS_DATA):
    """
    This calculates a predictable runtime popularity score.

    We calculate popularity as: (PORT_USAGE ^ 2) * PORT_DOWNLOADS

    This is used to create the: runtimes.popular.ARCH.zip

    The higher the score, the more popular the runtime.
    """

    runtime_scores = {}

    for runtime_name in runtimes:
        runtime_scores[runtime_name] = [0, 0]

    for port_name, port_info in ALL_PORTS_DATA['ports'].items():
        if len(port_info['attr']['runtime']) == 0:
            continue

        bad_port = 0
        for runtime_name in port_info['attr']['runtime']:
            if runtime_name not in runtime_scores:
                continue

            runtime_scores[runtime_name][0] += 1
            runtime_scores[runtime_name][1] += PORT_STATS_DATA['ports'].get(port_name, 1)

    for runtime_name in list(runtime_scores.keys()):
        runtime_score = runtime_scores[runtime_name]
        runtime_scores[runtime_name] = (runtime_score[0] ** 2) * runtime_score[1]

    # print(json.dumps(runtime_scores, indent=4))

    return runtime_scores


def get_runtime_added(runtime_name, cur_arch, PORTS_STATUS_DATA, RUNTIMES_DATA):
    if cur_arch not in RUNTIMES_DATA[runtime_name]['arch']:
        return '2038-01-19' # IYKYK

    runtime_release_name = runtime_name
    if cur_arch != RUNTIMES_DATA[runtime_name]['default']:
        runtime_release_name = RUNTIMES_DATA[runtime_name]['arch'][cur_arch]

    if runtime_release_name not in PORTS_STATUS_DATA:
        return '2038-01-19'

    return PORTS_STATUS_DATA[runtime_release_name]["date_added"]


def calculate_manifest(zip_info):
    manifest_data = []
    for runtime_name in zip_info['runtimes']:
        file_name, file_hash = zip_info['runtimes'][runtime_name]
        manifest_data.append(':'.join((file_name.replace('/', '.'), file_hash)))
    manifest_data.sort()

    # print('\n'.join(manifest_data))

    return hashlib.md5('\n'.join(manifest_data).encode('utf-8')).hexdigest()


def add_runtime_info(file_name, nice_name, included_files, runtimes_json, PORTS_STATUS_DATA):
    clean_name = file_name.name

    if file_name.is_file():
        file_md5  = hash_file(file_name)
        file_size = file_name.stat().st_size
    else:
        if clean_name not in PORTS_STATUS_DATA:
            # HRMMmmmmm o_o;;;;
            return

        file_md5  = PORTS_STATUS_DATA[clean_name]['md5']
        file_size = PORTS_STATUS_DATA[clean_name]['size']

    default_status = {
        'date_added':   TODAY,
        'date_updated': TODAY,
        'md5':          file_md5,
        'size':         file_size,
        'release_id':   CURRENT_RELEASE_ID,
        }

    if clean_name not in PORTS_STATUS_DATA:
        PORTS_STATUS_DATA[clean_name] = default_status

    elif PORTS_STATUS_DATA[clean_name]['md5'] != file_md5:
        PORTS_STATUS_DATA[clean_name]['md5']          = file_md5
        PORTS_STATUS_DATA[clean_name]['size']         = file_size
        PORTS_STATUS_DATA[clean_name]['release_id']   = CURRENT_RELEASE_ID
        PORTS_STATUS_DATA[clean_name]['date_updated'] = TODAY

    runtimes_json.append({
        'nice_name':    nice_name,
        'file_name':    clean_name,
        'url':          current_release_url(PORTS_STATUS_DATA[clean_name]['release_id']) + clean_name,
        'date_updated': PORTS_STATUS_DATA[clean_name]['date_updated'],
        'md5':          PORTS_STATUS_DATA[clean_name]['md5'],
        'size':         PORTS_STATUS_DATA[clean_name]['size'],
        'included_files': included_files,
        })


def main(argv):
    PORTS_STATUS      = (RELEASE_DIR / "ports_status.json")
    PORTS_STATUS_DATA = None

    MANIFEST          = (RELEASE_DIR / "manifest.json")
    MANIFEST_DATA     = None

    PORT_STATS        = (RELEASE_DIR / "port_stats.json")
    PORT_STATS_URL    = "https://raw.githubusercontent.com/PortsMaster/PortMaster-Info/refs/heads/main/port_stats.json"
    PORT_STATS_DATA   = None

    ALL_PORTS         = (RELEASE_DIR / "all_ports.json")
    ALL_PORTS_URL     = "https://raw.githubusercontent.com/PortsMaster/PortMaster-Info/refs/heads/main/ports.json"
    ALL_PORTS_DATA    = None

    RUNTIMES          = (RUNTIMES_DIR / "runtimes.json")
    RUNTIMES_DATA     = None


    if not GITHUB_RUN or CACHE_FILE.is_file():
        file_cache = HashCache(CACHE_FILE)

    if not PORT_STATS.is_file():
        fetch_file(PORT_STATS_URL, PORT_STATS)

    if not ALL_PORTS.is_file():
        fetch_file(ALL_PORTS_URL, ALL_PORTS)


    PORTS_STATUS_DATA = json_load(PORTS_STATUS)
    PORT_STATS_DATA   = json_load(PORT_STATS)
    ALL_PORTS_DATA    = json_load(ALL_PORTS)
    RUNTIMES_DATA     = json_load(RUNTIMES)
    MANIFEST_DATA     = json_load(MANIFEST)


    hash_file_fn = hash_file
    if file_cache is not None:
        hash_file_fn = file_cache.get_file_hash


    runtime_zips = {}

    for cur_arch in ALL_ARCH:
        arch_runtimes = {}
        arch_hashes = {}

        total_size = 0
        for runtime_name, runtime_info in RUNTIMES_DATA.items():
            if cur_arch not in runtime_info['arch']:
                continue

            runtime_file = RUNTIMES_DIR / runtime_info['arch'][cur_arch]
            arch_runtimes[runtime_name] = runtime_file
            arch_hashes[runtime_name] = hash_file_fn(runtime_file)

            total_size += runtime_file.stat().st_size

        if total_size > MAXIMUM_THRESHOLD:
            # Okay so runtimes.all.ARCH.zip is gonna be larger than the maximum github release can hold.

            # Runtimes are sorted by date added, so in theory as we add more, we only add new runtimes to the later zips.
            runtimes_sorted = list(sorted(arch_runtimes, key=lambda runtime_name: (get_runtime_added(runtime_name, cur_arch, PORTS_STATUS_DATA, RUNTIMES_DATA), runtime_name.casefold())))

            cur_runtime_zips = {}
            current_runtime_zip_id = 1
            current_runtime_size = 0
            current_runtime_zip_name = f"runtimes.all.{current_runtime_zip_id:03d}.{cur_arch}.zip"
            runtime_zips[current_runtime_zip_name] = cur_runtime_zips[current_runtime_zip_name] = {
                'size': 0,
                'arch': cur_arch,
                'runtimes': {},
                'md5': None,
                'manifest': None,
                'nice_name': f'All Runtimes Part {current_runtime_zip_id:d}{ALL_ARCH[cur_arch]}.zip'
                }

            while len(runtimes_sorted) > 0:
                runtime_name = runtimes_sorted.pop(0)
                runtime_size = arch_runtimes[runtime_name].stat().st_size
                current_runtime_size += runtime_size
                cur_runtime_zips[current_runtime_zip_name]['size'] += runtime_size
                cur_runtime_zips[current_runtime_zip_name]['runtimes'][runtime_name] = [str(arch_runtimes[runtime_name]), arch_hashes[runtime_name]]

                if current_runtime_size >= MAXIMUM_SPLIT_SIZE:
                    current_runtime_zip_id += 1
                    current_runtime_size = 0
                    current_runtime_zip_name = f"runtimes.all.{current_runtime_zip_id:03d}.{cur_arch}.zip"
                    runtime_zips[current_runtime_zip_name] = cur_runtime_zips[current_runtime_zip_name] = {
                        'size': 0,
                        'arch': cur_arch,
                        'runtimes': {},
                        'md5': None,
                        'manifest': None,
                        'nice_name': f'All Runtimes Part {current_runtime_zip_id:d}{ALL_ARCH[cur_arch]}.zip'
                        }

        else:
            current_runtime_zip_name = f"runtimes.all.{cur_arch}.zip"
            runtime_zips[current_runtime_zip_name] = cur_runtime_zip = {
                'size': 0,
                'arch': cur_arch,
                'runtimes': {},
                'md5': None,
                'manifest': None,
                'nice_name': f'All Runtimes{ALL_ARCH[cur_arch]}.zip'
                }

            for runtime_name in sorted(arch_runtimes, key=lambda runtime_name: runtime_name.casefold()):
                runtime_size = arch_runtimes[runtime_name].stat().st_size
                cur_runtime_zip['size'] += runtime_size
                cur_runtime_zip['runtimes'][runtime_name] = [str(arch_runtimes[runtime_name]), arch_hashes[runtime_name]]

        if total_size < POPULAR_THRESHOLD:
            # Okay we're only gonna make an runtimes.all.ARCH.zip
            continue

        runtime_scores = calculate_popularity(arch_runtimes, PORT_STATS_DATA, ALL_PORTS_DATA)

        # Lets make a runtimes.popular.ARCH.zip
        popular_runtimes = list(sorted(arch_runtimes, key=lambda runtime_name: runtime_scores[runtime_name], reverse=True))
        total_popular_size = 0

        current_runtime_zip_name = f"runtimes.popular.{cur_arch}.zip"
        runtime_zips[current_runtime_zip_name] = cur_runtime_zip = {
            'size': 0,
            'arch': cur_arch,
            'runtimes': {},
            'md5': None,
            'manifest': None,
            'nice_name': f'Popular Runtimes{ALL_ARCH[cur_arch]}.zip'
            }

        while total_popular_size < POPULAR_SIZE and len(popular_runtimes) > 0:
            runtime_name = popular_runtimes.pop(0)
            runtime_size = arch_runtimes[runtime_name].stat().st_size
            total_popular_size += runtime_size
            cur_runtime_zip['size'] += runtime_size
            cur_runtime_zip['runtimes'][runtime_name] = [str(arch_runtimes[runtime_name]), arch_hashes[runtime_name]]

    # Runtimes info.
    runtimes_info = []

    for zip_name, zip_info in runtime_zips.items():
        zip_info['manifest'] = calculate_manifest(zip_info)
        zip_info['included_files'] = list(zip_info['runtimes'])

        zip_file = RELEASE_DIR / zip_name

        print(f"- {zip_name}: {zip_info['manifest']} == {MANIFEST_DATA.get(zip_name, None)}: ", end="")

        if zip_name in PORTS_STATUS_DATA and zip_info['manifest'] == MANIFEST_DATA.get(zip_name, None):
            print(f" NO CHANGES")
            # Already up to date.
            add_runtime_info(zip_file, zip_info['nice_name'], zip_info['included_files'], runtimes_info, PORTS_STATUS_DATA)
            continue

        print(f" MODIFIED")

        with zipfile.ZipFile(zip_file, 'w', compression=zipfile.ZIP_STORED) as zf:
            # Squashfs files are already compressed, so lets not bother trying. :D

            zf.comment = zip_info['arch'].encode('utf-8') # This should hopefully help.
            for runtime_name in sorted(zip_info['runtimes'], key=lambda runtime_name: runtime_name.casefold()):
                file_name = zip_info['runtimes'][runtime_name][0]
                zf.write(file_name, runtime_name)

        MANIFEST_DATA[zip_name] = zip_info['manifest']

        add_runtime_info(zip_file, zip_info['nice_name'], zip_info['included_files'], runtimes_info, PORTS_STATUS_DATA)

    # print(json.dumps(runtime_zips, indent=4, sort_keys=True))
    if GITHUB_RUN:
        if PORT_STATS.is_file():
            PORT_STATS.unlink()

        if ALL_PORTS.is_file():
            ALL_PORTS.unlink()

    with open(RELEASE_DIR / "runtimes_zips.json", "w") as fh:
        json.dump(runtimes_info, fh, indent=2, sort_keys=True)

    if file_cache is not None:
        file_cache.save_cache()

    with open(PORTS_STATUS, 'w') as fh:
        json.dump(PORTS_STATUS_DATA, fh, sort_keys=True, indent=2)

    with open(MANIFEST, 'w') as fh:
        json.dump(MANIFEST_DATA, fh, sort_keys=True, indent=2)

if __name__ == '__main__':
    exit(main(sys.argv))
