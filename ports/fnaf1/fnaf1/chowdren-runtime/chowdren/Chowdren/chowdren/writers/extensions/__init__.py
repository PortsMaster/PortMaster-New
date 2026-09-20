from chowdren.writers.objects import ObjectWriter
import os

loaded_extensions = {}

def filter_name(name):
    return name.replace(' ', '').replace('+', 'p').lower()

names = {}

try:
    zipfiles = __loader__._files
    filenames = [zipfiles[f][0] for f in zipfiles.keys()
                 if 'chowdren\\writers\\extensions' in f]
    filenames = [f.split('\\')[-1] for f in filenames]
except (AttributeError, NameError):
    filenames = os.listdir(os.path.dirname(__file__))

for name in filenames:
    name, ext = os.path.splitext(name)
    names[filter_name(name)] = name

# some aliases
names['stringparser'] = 'parser'

def load_extension_module(ext, use_default):
    try:
        return loaded_extensions[ext]
    except KeyError:
        pass
    try:
        mod = names[filter_name(ext)]
        module = __import__('chowdren.writers.extensions', locals(), globals(),
            [mod])
        extension = getattr(module, mod, None)
    except KeyError:
        extension = None
    if use_default and extension is None:
        class NewModule(object):
            @staticmethod
            def get_object():
                return ObjectWriter
        extension = NewModule

    if extension is not None:
        extension.extension_name = ext

    loaded_extensions[ext] = extension
    return extension