#!/bin/bash

set -e

unset PYTHONHOME
unset PYTHONPATH

BUILD="$1"
if [ -z "$BUILD" ]; then
    echo "Usage: $0 /path/to/build" >&2
    exit 1
fi

python3 - "$BUILD" <<'PY'
import os, re, sys

B = sys.argv[1]
files = {}
messages = []

def fail(msg):
    sys.stderr.write("ERROR: %s\nNo files were modified (already patched, or a different build?).\n" % msg)
    sys.exit(1)

def load(f):
    if f not in files:
        path = os.path.join(B, f)
        if not os.path.isfile(path):
            fail("missing %s" % path)
        with open(path) as fh:
            files[f] = fh.read()
    return files[f]

def read_text(f):
    with open(os.path.join(B, f)) as fh:
        return fh.read()

def rid(name):
    """Exact object identifier (name_N) from lists.h."""
    m = set(re.findall(r'#define (%s_\d+)_instances' % re.escape(name), read_text('lists.h')))
    if len(m) != 1:
        fail("object '%s' resolved to %d identifiers in lists.h" % (name, len(m)))
    return m.pop()

def rstr(name):
    """String constant str_<name>_N from intern.h."""
    m = set(re.findall(r'\b(str_%s_\d+)\b' % re.escape(name), read_text('intern.h')))
    if len(m) != 1:
        fail("string constant 'str_%s' resolved to %d names in intern.h" % (name, len(m)))
    return m.pop()

EVENT_FILES = sorted(f for f in os.listdir(B) if re.match(r'events_\d+\.cpp$', f))

def resolve(f, ev):
    """File that really holds event ev. Which events_N.cpp an event lands in depends on where the
    converter splits the files (the Halloween Edition splits at different points), so if it is not
    in the expected file, look through all of them."""
    tag = '// event %s\n' % ev
    if os.path.isfile(os.path.join(B, f)) and load(f).count(tag) == 1:
        return f
    hits = [g for g in EVENT_FILES if read_text(g).count(tag) == 1]
    if len(hits) != 1:
        fail("event %s not found in %s or any other events file (%d candidates)" % (ev, f, len(hits)))
    return hits[0]

def block(f, ev):
    txt = load(f)
    start_tag = '// event %s\n' % ev
    if txt.count(start_tag) != 1:
        fail("%s: event %s not found exactly once" % (f, ev))
    s = txt.index(start_tag)
    end_tag = 'event_%s_end: ;' % ev
    e = txt.find(end_tag, s)
    if e < 0:
        fail("%s: end label of event %s not found" % (f, ev))
    return s, e + len(end_tag)

def ev_rep(f, ev, old, new):
    f = resolve(f, ev)
    s, e = block(f, ev)
    txt = files[f]
    seg = txt[s:e]
    if seg.count(old) != 1:
        fail("%s event %s: expected 1 match, found %d for:\n  %s" % (f, ev, seg.count(old), old))
    files[f] = txt[:s] + seg.replace(old, new, 1) + txt[e:]

def ev_after(f, ev, old, extra):
    ev_rep(f, ev, old, old + '\n        ' + extra)

def ev_del(f, ev, substr):
    f = resolve(f, ev)
    s, e = block(f, ev)
    txt = files[f]
    lines = txt[s:e].split('\n')
    keep = [l for l in lines if substr not in l]
    if len(lines) - len(keep) != 1:
        fail("%s event %s: expected to delete 1 line containing '%s', found %d" % (f, ev, substr, len(lines) - len(keep)))
    files[f] = txt[:s] + '\n'.join(keep) + txt[e:]

def done(name):
    messages.append("== %s: OK ==" % name)

# ---- identifiers -----------------------------------------------------------------------
ini, sel, obj6, beat5 = rid('ini'), rid('selection'), rid('obj6thnight'), rid('beat5')
beat6, beat7 = rid('beat6'), rid('beat7')
cheats, mfb, jmp = rid('cheats'), rid('makingfredbear'), rid('jumpscares')
left, right = rid('left'), rid('right')
s_night, s_beat5, s_beat8 = rstr('night'), rstr('beat5'), rstr('beat8')

L = '(is_key_pressed(SDLK_a) || is_key_pressed(SDLK_LEFT))'
R = '(is_key_pressed(SDLK_d) || is_key_pressed(SDLK_RIGHT))'
F = '(is_key_pressed_once(SDLK_w) || is_key_pressed_once(SDLK_UP))'
SP = '(is_key_pressed_once(SDLK_SPACE))'
BK = '(is_key_pressed_once(SDLK_s) || is_key_pressed_once(SDLK_DOWN))'
R5 = '((INI*)get_instance(%s_instances))->get_value_int(%s) == 1' % (ini, s_beat5)

def hover(f, ev, key):
    ev_rep(f, ev, 'mouse_over())) goto event_%s_end;' % ev,
                  'mouse_over() || %s)) goto event_%s_end;' % (key, ev))

def click(f, ev, key):
    ev_rep(f, ev, 'SDL_BUTTON_LEFT))) goto event_%s_end;' % ev,
                  'SDL_BUTTON_LEFT) || %s)) goto event_%s_end;' % (key, ev))

# ---- gameplay controls ------------------------------------------------------------------
hover('events_2.cpp', '5_3', L)      # scroll left
hover('events_2.cpp', '7_3', R)      # scroll right
click('events_2.cpp', '17_3', SP)    # enter left door
click('events_2.cpp', '18_3', SP)    # enter right door
click('events_2.cpp', '87_3', SP)    # closet
hover('events_2.cpp', '38_3', BK)    # left door -> back
hover('events_2.cpp', '67_3', BK)    # right door -> back
hover('events_3.cpp', '102_3', BK)   # closet -> back
for n in ('209_3', '210_3', '211_3'):
    hover('events_4.cpp', n, BK)     # bedroom / walls -> bed view
hover('events_4.cpp', '214_3', F)    # bed view -> room
ev_rep('events_4.cpp', '219_3', 'mouse_over())) goto event_219_3_end;',
       'mouse_over() || is_key_released_once(SDLK_s) || is_key_released_once(SDLK_DOWN) '
       '|| is_key_released_once(SDLK_w) || is_key_released_once(SDLK_UP))) goto event_219_3_end;')
def find_honk():
    """The honk click in the gameplay frame (_3). It is event 457_3 in the standard build and 458_3 in the
    Halloween Edition, so find it by what it does (click on the honk object)."""
    pat = re.compile(r'get_instance\(honk_\d+_instances\)\)->mouse_over\(\) && is_mouse_pressed_once\(SDL_BUTTON_LEFT\)\)\) goto event_(\d+_3)_end;')
    hits = set()
    for g in EVENT_FILES:
        for m in pat.finditer(read_text(g)):
            hits.add((g, m.group(1)))
    return hits

hk = find_honk()
hf, hev = hk.pop() if len(hk) == 1 else ('events_6.cpp', '457_3')   # fall back to the standard event
click(hf, hev, F)    # honk
done('applying gameplay controls')

# ---- cheat keys -------------------------------------------------------------------------
for ev, k in (('114_10', 't'), ('115_10', 'y'), ('116_10', 'u')):
    click('events_9.cpp', ev, 'is_key_pressed_once(SDLK_%s)' % k)
done('applying cheat keys')

# ---- extras unlocks ---------------------------------------------------------------------
# Extras menu opens: beat5 forced after the save loads.
ev_after('events_1.cpp', '31_1',
         '->set(((INI*)get_instance(%s_instances))->get_value_int(%s));' % (ini, s_beat8),
         '((Counter*)get_instance(%s_instances))->set(1);' % beat5)
# Cheats section no longer needs beat7.
ev_del('events_8.cpp', '65_10', '%s_instances' % beat7)
for ev in ('107_10', '114_10', '115_10', '116_10'):
    ev_del('events_9.cpp', ev, '%s_instances' % beat7)
ev_del('events_9.cpp', '149_10', '%s_instances' % cheats)
ev_del('events_9.cpp', '150_10', '%s_instances' % beat7)
# Making Fredbear (section 2) and Jumpscares (section 3): drop beat6 guards.
for ev in ('29', '32', '34', '35', '36', '37', '38', '39', '40',
           '43', '44', '45', '46', '47', '48', '49', '62', '63'):
    ev_del('events_8.cpp', ev + '_10', '%s_instances' % beat6)
for ev in ('84_10', '85_10'):
    ev_del('events_9.cpp', ev, 'get_instance(%s_instances)' % left)
    ev_del('events_9.cpp', ev, 'get_instance(%s_instances)' % right)
for o in (mfb, jmp):
    ev_rep('events_9.cpp', '82_10',
           'get_instance(%s_instances))->blend_color.set_alpha_coefficient(200);' % o,
           'get_instance(%s_instances))->blend_color.set_alpha_coefficient(0);' % o)
done('applying extras unlocks')

# ---- title menu -------------------------------------------------------------------------
ev_after('events_1.cpp', '36_1', 'is_key_pressed_once(SDLK_RETURN))) goto event_36_1_end;',
         'if (!(%s)) goto event_36_1_end;' % R5)                     # 6th Night needs the real save
ev_after('events_1.cpp', '45_1', '%s_instances))->value) == (1))) goto event_45_1_end;' % beat5,
         'if (!(%s)) goto event_45_1_end;' % R5)
ev_rep('events_1.cpp', '47_1', '((Active*)get_instance(%s_instances))->set_visible(true);' % obj6,
       '((Active*)get_instance(%s_instances))->set_visible(%s);' % (obj6, R5))
ev_after('events_1.cpp', '19_1', '%s_instances))->add(1);' % sel,
         'if ((((Counter*)get_instance(%s_instances))->value) == (2) && !(%s)) '
         '((Counter*)get_instance(%s_instances))->add(1);' % (sel, R5, sel))
ev_after('events_1.cpp', '20_1', '%s_instances))->subtract(1);' % sel,
         'if ((((Counter*)get_instance(%s_instances))->value) == (2) && !(%s)) '
         '((Counter*)get_instance(%s_instances))->subtract(1);' % (sel, R5, sel))
ev_after('events_1.cpp', '51_1', '%s_instances))->value) == (1))) goto event_51_1_end;' % beat5,
         'if (!(%s)) goto event_51_1_end;' % R5)                     # title star follows the real save
ev_rep('events_1.cpp', '37_1',
       '((INI*)get_instance(%s_instances))->set_value_int(%s, 6);' % (ini, s_night),
       'if (%s) ((INI*)get_instance(%s_instances))->set_value_int(%s, 6);' % (R5, ini, s_night))
done('applying title menu fixes')

# ---- write everything only if every edit matched -----------------------------------------
for f, txt in files.items():
    with open(os.path.join(B, f), 'w') as fh:
        fh.write(txt)
print('\n'.join(messages))
PY

