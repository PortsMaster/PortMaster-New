import datetime
import hashlib
import json
import pathlib
import re
import urllib
import urllib.request

from pathlib import Path


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
    'arch': [],
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
def error(port_name, message):
    MESSAGES.setdefault(port_name, {'errors': [], 'warnings': []})
    MESSAGES[port_name]['errors'].append(message)


def warning(port_name, message):
    MESSAGES.setdefault(port_name, {'errors': [], 'warnings': []})
    MESSAGES[port_name]['warnings'].append(message)


def port_info_load(raw_info, source_name=None, do_default=False):
    if isinstance(raw_info, pathlib.PurePath):
        if source_name is None:
            source_name = str(raw_info)

        with raw_info.open('r') as fh:
            try:
                info = json.load(fh)

                if not isinstance(info, dict):
                    error(source_name, f"Unable to load {str(raw_info)}: bad json file")
                    info = None

            except json.decoder.JSONDecodeError as err:
                error(source_name, f"Unable to load {str(raw_info)}: {err}")
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

                if not isinstance(info, dict):
                    error(source_name, f"Unable to load port.json: bad json file")
                    info = None

            except json.decoder.JSONDecodeError as err:
                error(source_name, f"Unable to load port.json: {err}")
                info = None

            if info is None:
                if do_default:
                    info = {}

                else:
                    return None

        elif Path(raw_info).is_file():
            if source_name is None:
                source_name = raw_info

            with open(raw_info, 'r') as fh:
                try:
                    info = json.load(fh)

                    if not isinstance(info, dict):
                        error(source_name, f"Unable to load {raw_info}: bad json file")
                        info = None

                except json.decoder.JSONDecodeError as err:
                    error(source_name, f"Unable to load {raw_info}: {err}")
                    info = None

                if info is None:
                    if do_default:
                        info = {}

                    else:
                        return None

        else:
            if source_name is None:
                source_name = "<str>"

            if do_default:
                info = {}

            else:
                error(source_name, f'Unable to load port_info: {raw_info!r}')
                return None

    elif isinstance(raw_info, dict):
        if source_name is None:
            source_name = "<dict>"

        info = raw_info

    else:
        if do_default:
            info = {}

        else:
            error(source_name, f'Unable to load port_info: {raw_info!r}')
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
                warning(source_name, f"port_info['items'] contains bad name {item!r}")
                del port_info['items'][i]
                continue

            if item.startswith('../'):
                warning(source_name, f"port_info['items'] contains bad name {item!r}")
                del port_info['items'][i]
                continue

            if '/../' in item:
                warning(source_name, f"port_info['items'] contains bad name {item!r}")
                del port_info['items'][i]
                continue

            if item == "":
                warning(source_name, f"port_info['items'] contains bad name {item!r}")
                del port_info['items'][i]

            i += 1

    if isinstance(port_info['items_opt'], list):
        i = 0
        while i < len(port_info['items_opt']):
            item = port_info['items_opt'][i]
            if item.startswith('/'):
                warning(source_name, f"port_info['items_opt'] contains bad name {item}")
                del port_info['items_opt'][i]
                continue

            if item.startswith('../'):
                warning(source_name, f"port_info['items_opt'] contains bad name {item}")
                del port_info['items_opt'][i]
                continue

            if '/../' in item:
                warning(source_name, f"port_info['items_opt'] contains bad name {item}")
                del port_info['items_opt'][i]
                continue

            if item == "":
                warning(source_name, f"port_info['items'] contains bad name {item!r}")
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

            else:
                warning(source_name, f"port_info['attr']['genres'] contains bad genre {genre}")

    if port_info['attr']['image'] == None:
        port_info['attr']['image'] = {}

    if port_info['attr']['runtime'] == "blank":
        port_info['attr']['runtime'] = None

    if port_info['attr']['rtr'] is not False and port_info['attr']['inst'] in ("", None):
        port_info['attr']['inst'] = "Ready to run."

    return port_info


class HashCache():
    CACHE_ATTRS = ('st_size', 'st_mtime')
    DEBUG_CACHE = False

    def __init__(self, file_name):
        self.file_name = file_name
        self._cache = dict()
        self._stats = {
            'hits': 0,
            'misses': 0,
            'loaded': 0,
            'new': 0,
            }

        if file_name.is_file():
            self.load_cache()

    def _stat_file(self, file_name):
        file_name = Path(file_name)
        if not file_name.is_file():
            return None

        stat = Path(file_name).stat()
        return ':'.join([
            str(getattr(stat, attr, None))
            for attr in self.CACHE_ATTRS])

    def load_cache(self):
        self._cache.clear()
        self._stats = {
            'hits': 0,
            'misses': 0,
            'loaded': 0,
            'new': 0,
            }

        with open(self.file_name, 'r') as fh:
            data = json.load(fh)

        invalidated = 0
        cache_items = 0
        total_items = 0

        # This takes a few extra seconds, but can be worth it.
        if self.DEBUG_CACHE:
            print("Loading PM Cache:")

        for file_name, file_data in data.items():
            total_items += 1

            stat = self._stat_file(file_name)
            if stat is None:
                invalidated += 1
                continue

            if stat != file_data[0]:
                invalidated += 1
                continue

            cache_items += 1
            self._cache[file_name] = file_data

        if self.DEBUG_CACHE:
            print(f"- invalidated: {invalidated}")
            print(f"- loaded items: {cache_items}")
            print(f"- total items: {total_items}")
            print("")

    def save_cache(self):
        if self.DEBUG_CACHE:
            print("")
            print("Saving PM Cache:")
            print(f"- cache hits: {self._stats['hits']}")
            print(f"- cache misses: {self._stats['misses']}")
            print(f"- new items: {self._stats['new']}")
            print(f"- total cache size: {len(self._cache)}")
            print("")

        with open(self.file_name, 'w') as fh:
            json.dump(self._cache, fh, indent=2)

    def get_file_hash(self, file_name):
        file_name = str(file_name)
        stat = self._stat_file(file_name)

        if file_name in self._cache:
            if self._cache[file_name][0] == stat:
                self._stats['hits'] += 1
                return self._cache[file_name][1]

            else:
                self._stats['misses'] += 1

        else:
            self._stats['new'] += 1

        file_hash = hash_file(file_name)
        self._cache[file_name] = [stat, file_hash, None]

        return file_hash

    def get_files_hash(self, file_names):
        all_result = None

        for file_name in file_names:
            stat = self._stat_file(file_name)

            if file_name in self._cache:
                if self._cache[file_name][0] == stat:
                    if all_result is None:
                        all_result = self._cache[file_name][2]

                else:
                    self._stats['misses'] += 1
                    break

            else:
                self._stats['new'] += 1
                break

        else:
            if all_result is not None:
                self._stats['hits'] += 1
                return all_result


        all_md5, file_data = hash_files_2(file_names)
        for file_name, file_md5 in file_data:
            stat = self._stat_file(file_name)
            self._cache[file_name] = [stat, file_md5, all_md5]

        return all_md5


def fetch_bytes(url):
    try:
        # Open the URL
        with urllib.request.urlopen(url) as response:
            # Read the content of the file
            return response.read()

    except urllib.error.URLError as err:
        print(f"Unable to download {url}: {err}")
        return None


def fetch_text(url):
    try:
        return fetch_bytes(url).decode('utf-8')

    except UnicodeDecodeError as err:
        return None


def fetch_json(url):
    text = fetch_text(url)
    if text is None:
        return None

    try:
        return json.loads(text)

    except json.decoder.JSONDecodeError as err:
        return None


def fetch_file(url, file_name):
    try:
        # Open the URL
        with urllib.request.urlopen(url) as response:

            print(response)

            with open(file_name, 'wb') as fh:
                # Read the content of the url and write into the file
                size = 0

                while True:
                    data = response.read(4096 * 10)
                    if len(data) == 0:
                        break

                    size += len(data)
                    print(f"\r- {url.rsplit('/', 1)[-1]} {size}")

                    fh.write(data)

        return True

    except urllib.error.URLError as err:
        print(f"Unable to download {url}: {err}")
        return False


def name_cleaner(text):
    temp = re.sub(r'[^a-zA-Z0-9 _\-\.]+', '', text.strip().lower())
    return re.sub(r'[ \.]+', '.', temp)


def hash_text(text):
    md5 = hashlib.md5()

    md5.update(text.encode('utf-8'))

    # print(f"<{md5.hexdigest()}")
    return md5.hexdigest()


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

    with file_name.open('rb') as fh:
        return hash_file_handle(fh)


def hash_files(file_list):
    md5 = hashlib.md5()
    for file_name in file_list:
        with open(file_name, 'rb') as fh:
            while True:
                data = fh.read(4096 * 10)
                if len(data) == 0:
                    break

                md5.update(data)

    return md5.hexdigest()

def hash_files_2(file_list):
    all_md5 = hashlib.md5()
    results = []

    for file_name in file_list:
        file_md5 = hashlib.md5()

        with open(file_name, 'rb') as fh:
            while True:
                data = fh.read(4096 * 10)
                if len(data) == 0:
                    break

                file_md5.update(data)
                all_md5.update(data)

        results.append((file_name, file_md5.hexdigest()))

    return all_md5.hexdigest(), results


def hash_file_handle(fh):
    md5 = hashlib.md5()
    while True:
        data = fh.read(4096 * 10)
        if len(data) == 0:
            break

        md5.update(data)

    return md5.hexdigest()


def datetime_compare(time_a, time_b=None):
    if isinstance(time_a, str):
        time_a = datetime.datetime.fromisoformat(time_a)

    if time_b is None:
        time_b = datetime.datetime.now()
    elif isinstance(time_b, str):
        time_b = datetime.datetime.fromisoformat(time_b)

    return (time_b - time_a).total_seconds()


__all__ = (
    'PORT_INFO_ROOT_ATTRS',
    'PORT_INFO_ATTR_ATTRS',
    'PORT_INFO_GENRES',
    'MESSAGES',
    'HashCache',
    'datetime_compare',
    'error',
    'fetch_bytes',
    'fetch_file',
    'fetch_json',
    'fetch_text',
    'hash_text',
    'hash_file',
    'hash_files',
    'hash_file_handle',
    'hash_items',
    'name_cleaner',
    'port_info_load',
    'warning',
    )
