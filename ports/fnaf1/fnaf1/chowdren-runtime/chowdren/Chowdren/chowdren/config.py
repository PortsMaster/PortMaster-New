import imp
import functools
from configs import default

class ConfigurationFile(object):
    def __init__(self, converter, path=None):
        if path is None:
            module = default
        else:
            module = imp.load_source('config', path)
        for name in dir(default):
            if name.startswith('_'):
                continue
            func = getattr(module, name, None)
            if func is None:
                func = getattr(default, name)
            setattr(self, name, functools.partial(func, converter))
