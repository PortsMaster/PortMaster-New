"""Conversion step `settings`: player settings in globalgamemanagers (cfg['settings']).

  graphics_apis       BuildSettings.m_GraphicsAPIs, e.g. [11] (GLES3) or [11, 17] (GLES3, then
                      GLCore for desktop-GL drivers); None = keep
  mouse_events        False: BuildSettings.usesOnMouseEvents off. With it on, Unity raycasts (2D and
                      3D) from every camera at the mouse position every frame for OnMouse* handlers;
                      turn it off only for a game with no OnMouse* method (check its assemblies)
  trim_joystick_axes  True: drop InputManager axes named Joy<j>Axis<a> (Rewired's installer adds
                      them for its Unity-input source; Unity updates every axis every frame). The
                      Android data step adds back the ones Rewired's Android input needs.
  audio_sample_rate   AudioManager output rate (0 = keep); real_voices: AudioManager real voices
"""
import re

from .unity_io import Loaded

DEFAULTS = {'graphics_apis': None, 'mouse_events': True, 'trim_joystick_axes': False,
            'audio_sample_rate': 0, 'real_voices': 0}


def run(job):
    rel = 'globalgamemanagers'
    if job.is_done('settings', rel):
        return
    c = dict(DEFAULTS, **job.cfg.get('settings', {}))
    lf = Loaded(job.path_in(rel))
    done = []
    for _, o in lf.objects():
        n = o.type.name
        if n == 'BuildSettings':
            t = o.read_typetree()
            if c['graphics_apis'] is not None:
                t['m_GraphicsAPIs'] = list(c['graphics_apis'])
                done.append(f'graphics APIs {c["graphics_apis"]}')
            if not c['mouse_events'] and t.get('usesOnMouseEvents'):
                t['usesOnMouseEvents'] = False
                done.append('mouse events off')
            o.save_typetree(t)
        elif n == 'InputManager' and c['trim_joystick_axes']:
            t = o.read_typetree()
            kept = [a for a in t['m_Axes'] if not re.match(r'Joy\d+Axis\d+$', a['m_Name'])]
            if len(kept) != len(t['m_Axes']):
                done.append(f'input axes {len(t["m_Axes"])} -> {len(kept)}')
                t['m_Axes'] = kept
                o.save_typetree(t)
        elif n == 'AudioManager' and c['audio_sample_rate']:
            t = o.read_typetree()
            t['m_SampleRate'] = c['audio_sample_rate']
            if c['real_voices']:
                t['m_RealVoiceCount'] = c['real_voices']
            o.save_typetree(t)
            done.append(f'audio {c["audio_sample_rate"]} Hz')
    job.write(rel, lf.save())
    lf.close()
    job.mark_done('settings', rel)
    job.log('settings: ' + (', '.join(done) or 'nothing to change'))
