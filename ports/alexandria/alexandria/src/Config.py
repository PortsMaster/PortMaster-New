import os.path
from xdg import BaseDirectory

STARTLEVEL = ('training', 'level1')
#STARTLEVEL = ('healbeam', 'station-broken')

DATA_DEFAULTS = {'solved': {},
                 'unlocked': { 'training': ['level1'] },
                 'nextlevel': STARTLEVEL,
                 }

CONFIG_DEFAULTS = {'resolution': (800, 600),
                   'version':1,
                   'layout': 'qwerty',
                   'bindings': {},
                   'musicvolume': 1.0, 'fxvolume': 1.0,
                   'accel_indicator': True, 'velo_indicator': True,
                   'showfps': False}

# In case STARTLEVEL isn't training/level1, unlock it.
#DATA_DEFAULTS['unlocked'].setdefault(STARTLEVEL[0], []).append(STARTLEVEL[1])

class ConfigManager(object):
    def __init__(self):
        super(ConfigManager, self).__init__()
        self.load_config()
        self.manager = None #But will get set from outside!

    def load_config(self):
        self.load(BaseDirectory.load_config_paths('6fl', 'alexandria'),
                  'config', CONFIG_DEFAULTS)
        self.load(BaseDirectory.load_data_paths('6fl', 'alexandria'),
                  'levels', DATA_DEFAULTS)
        if self.nextlevel == ('training', 'thatsall'):
            self.nextlevel = ('training', 'level1')
        
    def load(self, dirs, filename, defaults):
        g = {'__builtins__':{}, 'True':True, 'False':False}
        g.update(defaults)
        for dir in dirs:
            f = os.path.join(dir, filename)
            try:
                execfile(f, g)
                break
            except IOError:
                pass #Who cares

        for attr in defaults:
            setattr(self, attr, g[attr])

        #print g

    def save_config(self):
        self.save(BaseDirectory.save_config_path('6fl', 'alexandria'),
                  'config', CONFIG_DEFAULTS)
        self.save(BaseDirectory.save_data_path('6fl', 'alexandria'),
                  'levels', DATA_DEFAULTS)
                  
    def save(self, dir, filename, dict):
        f = file(os.path.join(dir, filename), 'w')
        for attr in dict:
            str = '%s = %s\n' %(attr, repr(getattr(self, attr)))
            f.write(str)
        #print self.solved, self.resolution

Config = ConfigManager()
