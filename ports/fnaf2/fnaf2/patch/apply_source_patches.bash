#!/bin/bash

set -e

unset PYTHONHOME
unset PYTHONPATH

BUILD="$1"
if [ -z "$BUILD" ]; then
    echo "Usage: $0 /path/to/build" >&2
    exit 1
fi

echo "=== Applying Five Nights at Freddy's 2 patches ==="

echo "=== Step 1/9: Left/Right light (I / J) ==="

python3 -c "
path = '$BUILD/events_3.cpp'
content = open(path).read()
old = 'if (!(((Active*)get_instance(leftlight_109_instances))->mouse_over())) goto event_187_3_end;'
new = 'if (!((((Active*)get_instance(leftlight_109_instances))->mouse_over()) || is_key_pressed(SDLK_i))) goto event_187_3_end;'
assert content.count(old) == 1, str(content.count(old))
content = content.replace(old, new, 1)
old2 = '        if (!(is_mouse_pressed(SDL_BUTTON_LEFT))) goto event_187_3_end;'
new2 = '        if (!(is_mouse_pressed(SDL_BUTTON_LEFT) || is_key_pressed(SDLK_i))) goto event_187_3_end;'
assert content.count(old2) == 1, str(content.count(old2))
content = content.replace(old2, new2, 1)
open(path, 'w').write(content)
print('OK: I left light, both gates freed')
"

python3 -c "
path = '$BUILD/events_3.cpp'
content = open(path).read()
old = 'if (!(((Active*)get_instance(rightlight_110_instances))->mouse_over())) goto event_189_3_end;'
new = 'if (!((((Active*)get_instance(rightlight_110_instances))->mouse_over()) || is_key_pressed(SDLK_j))) goto event_189_3_end;'
assert content.count(old) == 1, str(content.count(old))
content = content.replace(old, new, 1)
old2 = '        if (!(is_mouse_pressed(SDL_BUTTON_LEFT))) goto event_189_3_end;'
new2 = '        if (!(is_mouse_pressed(SDL_BUTTON_LEFT) || is_key_pressed(SDLK_j))) goto event_189_3_end;'
assert content.count(old2) == 1, str(content.count(old2))
content = content.replace(old2, new2, 1)
open(path, 'w').write(content)
print('OK: J right light, both gates freed')
"
echo "=== Step 2/9: Music box (E) ==="

python3 -c "
path = '$BUILD/events_6.cpp'
content = open(path).read()
old1 = '''every_491_3 -= 0.5;
        if (!(((Active*)get_instance(musicbutton_167_instances))->mouse_over())) goto event_491_3_end;'''
new1 = '''every_491_3 -= 0.5;
        if (!((((Active*)get_instance(musicbutton_167_instances))->mouse_over()) || is_key_pressed(SDLK_e))) goto event_491_3_end;'''
assert content.count(old1) == 1, 'e491: ' + str(content.count(old1))
content = content.replace(old1, new1, 1)
old1b = '        if (!(is_mouse_pressed(SDL_BUTTON_LEFT))) goto event_491_3_end;'
new1b = '        if (!(is_mouse_pressed(SDL_BUTTON_LEFT) || is_key_pressed(SDLK_e))) goto event_491_3_end;'
assert content.count(old1b) == 1, 'e491 mousepress: ' + str(content.count(old1b))
content = content.replace(old1b, new1b, 1)
old2 = '''// event 492_3
    {
        if (!(((Active*)get_instance(musicbutton_167_instances))->mouse_over())) goto event_492_3_end;'''
new2 = '''// event 492_3
    {
        if (!((((Active*)get_instance(musicbutton_167_instances))->mouse_over()) || is_key_pressed(SDLK_e))) goto event_492_3_end;'''
assert content.count(old2) == 1, 'e492: ' + str(content.count(old2))
content = content.replace(old2, new2, 1)
old2b = '        if (!(is_mouse_pressed(SDL_BUTTON_LEFT))) goto event_492_3_end;'
new2b = '        if (!(is_mouse_pressed(SDL_BUTTON_LEFT) || is_key_pressed(SDLK_e))) goto event_492_3_end;'
assert content.count(old2b) == 1, 'e492 mousepress: ' + str(content.count(old2b))
content = content.replace(old2b, new2b, 1)
open(path, 'w').write(content)
print('OK: E music box gates (491, 492), both gates freed')
"

python3 -c "
path = '$BUILD/events_7.cpp'
content = open(path).read()
old = 'if (!(((Active*)get_instance(musicbutton_167_instances))->mouse_over())) goto event_506_3_end;'
new = 'if (!((((Active*)get_instance(musicbutton_167_instances))->mouse_over()) || is_key_pressed(SDLK_e))) goto event_506_3_end;'
assert content.count(old) == 1, str(content.count(old))
content = content.replace(old, new, 1)
old2 = '        if (!(is_mouse_pressed(SDL_BUTTON_LEFT))) goto event_506_3_end;'
new2 = '        if (!(is_mouse_pressed(SDL_BUTTON_LEFT) || is_key_pressed(SDLK_e))) goto event_506_3_end;'
assert content.count(old2) == 1, str(content.count(old2))
content = content.replace(old2, new2, 1)
open(path, 'w').write(content)
print('OK: E music box cap gate (506), both gates freed')
"
echo "=== Step 3/9: Office pan - real Office frame (A / D) ==="

python3 -c "
path = '$BUILD/events_3.cpp'
content = open(path).read()

targets = [
    ('scrollleft_88',  'event_140_3_end', 'SDLK_a'),
    ('scrollleft2_92',  'event_141_3_end', 'SDLK_a'),
    ('scrollleft3_93',  'event_142_3_end', 'SDLK_a'),
    ('scrollright_89',  'event_143_3_end', 'SDLK_d'),
    ('scrollright2_90', 'event_144_3_end', 'SDLK_d'),
    ('scrollright3_91', 'event_145_3_end', 'SDLK_d'),
]

for obj, end, key in targets:
    old = f'if (!(((Active*)get_instance({obj}_instances))->mouse_over())) goto {end};'
    new = f'if (!((((Active*)get_instance({obj}_instances))->mouse_over()) || is_key_pressed({key}))) goto {end};'
    c = content.count(old)
    assert c == 1, f'{obj}: {c}'
    content = content.replace(old, new, 1)

open(path, 'w').write(content)
print('OK: real office pan patched (140_3-145_3)')
"
echo "=== Step 4/9: Office pan - Dream sequence (A / D) ==="

PANLEFT="panleft_304"
PANRIGHT="panright_305"

sed -i "s/if (!(((Active\*)get_instance(${PANLEFT}_instances))->mouse_over())) goto event_3_13_end;/if (!((((Active*)get_instance(${PANLEFT}_instances))->mouse_over()) || is_key_pressed(SDLK_a))) goto event_3_13_end;/" "$BUILD/events_11.cpp"

sed -i "s/if (!(((Active\*)get_instance(${PANLEFT}_instances))->mouse_over())) goto event_4_13_end;/if (!((((Active*)get_instance(${PANLEFT}_instances))->mouse_over()) || is_key_pressed(SDLK_a))) goto event_4_13_end;/" "$BUILD/events_11.cpp"

sed -i "s/if (!(((Active\*)get_instance(${PANRIGHT}_instances))->mouse_over())) goto event_5_13_end;/if (!((((Active*)get_instance(${PANRIGHT}_instances))->mouse_over()) || is_key_pressed(SDLK_d))) goto event_5_13_end;/" "$BUILD/events_11.cpp"

sed -i "s/if (!(((Active\*)get_instance(${PANRIGHT}_instances))->mouse_over())) goto event_6_13_end;/if (!((((Active*)get_instance(${PANRIGHT}_instances))->mouse_over()) || is_key_pressed(SDLK_d))) goto event_6_13_end;/" "$BUILD/events_11.cpp"

python3 -c "
path = '$BUILD/events_11.cpp'
content = open(path).read()
old = '''        if (((Active*)get_instance(panright_305_instances))->mouse_over()) goto event_7_13_end;
        if (((Active*)get_instance(panleft_304_instances))->mouse_over()) goto event_7_13_end;'''
new = old + '\n        if (is_key_pressed(SDLK_a) || is_key_pressed(SDLK_d)) goto event_7_13_end;'
assert content.count(old) == 1, str(content.count(old))
open(path, 'w').write(content.replace(old, new, 1))
print('OK: A/D dream pan reset gate (event 7_13)')
"

echo "=== Step 5/9: Mask kill gate - inverted logic fix (423-426_3) ==="

python3 -c "
path = '$BUILD/events_6.cpp'
content = open(path).read()

targets = ['event_423_3_end', 'event_424_3_end', 'event_425_3_end', 'event_426_3_end']
for end in targets:
    old = f'if (!((((Active*)get_instance(mask_104_instances))->alterables->values.get(0)) == (2))) goto {end};'
    new = f'if (!((((Active*)get_instance(mask_104_instances))->alterables->values.get(0)) != (2))) goto {end};'
    c = content.count(old)
    assert c == 1, f'{end}: {c}'
    content = content.replace(old, new, 1)

open(path, 'w').write(content)
print('OK: flipped mask gate on withered-animatronic kill roll (423-426_3)')
"

echo "=== Step 6/9: Real Office - arrow-key camera navigation ==="

python3 -c "
path_h = '$BUILD/events.h'
h = open(path_h).read()
old_decl = '    void handle_frame_4_pre_events();'
new_decl = '    void handle_frame_4_pre_events();\n    void handle_office_cam_nav_keys();'
assert h.count(old_decl) == 1, str(h.count(old_decl))
h = h.replace(old_decl, new_decl, 1)
open(path_h, 'w').write(h)
print('OK: declared handle_office_cam_nav_keys() in events.h')
"

python3 -c "
cam_obj = {
    1: 'cam01_49', 2: 'cam2_51', 3: 'cam3_52', 4: 'cam4_53',
    5: 'cam5_54', 6: 'cam6_58', 7: 'cam7_61', 8: 'cam8_62',
    9: 'cam9_65', 10: 'cam10_66', 11: 'cam11_67', 12: 'cam12_69',
}
edges = [
    (1,'SDLK_UP',3), (1,'SDLK_DOWN',5), (1,'SDLK_RIGHT',2),
    (2,'SDLK_UP',4), (2,'SDLK_DOWN',6), (2,'SDLK_LEFT',1),
    (3,'SDLK_UP',8), (3,'SDLK_DOWN',1), (3,'SDLK_RIGHT',4),
    (4,'SDLK_UP',7), (4,'SDLK_DOWN',2), (4,'SDLK_RIGHT',10), (4,'SDLK_LEFT',3),
    (5,'SDLK_UP',1), (5,'SDLK_RIGHT',6),
    (6,'SDLK_UP',2), (6,'SDLK_LEFT',5),
    (7,'SDLK_DOWN',4), (7,'SDLK_RIGHT',9), (7,'SDLK_LEFT',8),
    (8,'SDLK_DOWN',3), (8,'SDLK_RIGHT',7),
    (9,'SDLK_DOWN',11), (9,'SDLK_LEFT',7),
    (10,'SDLK_RIGHT',11), (10,'SDLK_LEFT',4),
    (11,'SDLK_UP',9), (11,'SDLK_DOWN',12), (11,'SDLK_LEFT',10),
    (12,'SDLK_UP',11),
]
lines = []
lines.append('void Frames::handle_office_cam_nav_keys()')
lines.append('{')
lines.append('    if (!((((Counter*)get_instance(viewing_48_instances))->value) > (0))) return;')
for frm, key, to in edges:
    to_obj = cam_obj[to]
    lines.append(f'    if ((((Counter*)get_instance(viewing_48_instances))->value) == ({frm}) && is_key_pressed_once({key})) {{')
    lines.append(f'        ((Counter*)get_instance(viewing_48_instances))->set({to});')
    lines.append(f'        ((Active*)get_instance(cam01_49_instances))->alterables->values.set(0, 1);')
    lines.append(f'        ((Counter*)get_instance(blip_79_instances))->set(1);')
    lines.append(f'        {{')
    lines.append(f'            FrameObject * parent = ((Active*)get_instance({to_obj}_instances));')
    lines.append(f'            if (parent != NULL) ((Active*)get_instance(yourview_141_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0);')
    lines.append(f'        }}')
    lines.append(f'        return;')
    lines.append('    }')
lines.append('}')
lines.append('')
func_text = '\n'.join(lines)

path = '$BUILD/events_9.cpp'
content = open(path).read()
marker = 'void Frames::handle_frame_4_pre_events()\n{\n'
assert content.count(marker) == 1, str(content.count(marker))
content = content.replace(marker, func_text + '\n' + marker, 1)
old_call = 'void Frames::handle_frame_4_pre_events()\n{\n    event_func_282();'
new_call = 'void Frames::handle_frame_4_pre_events()\n{\n    handle_office_cam_nav_keys();\n    event_func_282();'
assert content.count(old_call) == 1, str(content.count(old_call))
content = content.replace(old_call, new_call, 1)
open(path, 'w').write(content)
print('OK: cam nav function defined + hooked into handle_frame_4_pre_events (final adjacency: cam10<->11, not cam10<->12)')
"

echo "=== Step 7/9: Custom Night - slider nav (arrows) + mode cycle (Z / C) ==="

python3 -c "
path_h = '$BUILD/events.h'
h = open(path_h).read()
old_decl = '    void handle_frame_13_pre_events();'
new_decl = '    void handle_frame_13_pre_events();\n    void handle_customnight_nav_keys();\n    void handle_customnight_mode_keys();'
assert h.count(old_decl) == 1, str(h.count(old_decl))
h = h.replace(old_decl, new_decl, 1)
open(path_h, 'w').write(h)
print('OK: declared both Custom Night functions in events.h')
"

python3 -c "
anims = [
    ('freddyai_181', 0), ('bonieai_182', 1), ('chicaai_183', 2), ('foxyai_184', 3),
    ('bbai_185', 4), ('toyfreddyai_186', 5), ('toybonnieai_187', 6),
    ('toychicaai_188', 7), ('mangleai_189', 8), ('goldenfreddyai_190', 9),
]
nav = []
nav.append('void Frames::handle_customnight_nav_keys()')
nav.append('{')
nav.append('    static int cn_selected = 0;')
nav.append('    if (is_key_pressed_once(SDLK_DOWN)) cn_selected = (cn_selected + 1) % 10;')
nav.append('    if (is_key_pressed_once(SDLK_UP)) cn_selected = (cn_selected + 9) % 10;')
for ai, i in anims:
    nav.append(f'    if (cn_selected == {i}) {{')
    nav.append(f'        if (is_key_pressed_once(SDLK_RIGHT) && ((Counter*)get_instance({ai}_instances))->value < 20) {{')
    nav.append(f'            ((Counter*)get_instance({ai}_instances))->add(1);')
    nav.append(f'            media.play_id(SOUND_COIN_43, 1-1);')
    nav.append(f'            ((Counter*)get_instance(doingcustom_223_instances))->set(0);')
    nav.append(f'        }}')
    nav.append(f'        if (is_key_pressed_once(SDLK_LEFT) && ((Counter*)get_instance({ai}_instances))->value > 0) {{')
    nav.append(f'            ((Counter*)get_instance({ai}_instances))->subtract(1);')
    nav.append(f'            media.play_id(SOUND_COIN_43, 1-1);')
    nav.append(f'            ((Counter*)get_instance(doingcustom_223_instances))->set(0);')
    nav.append(f'        }}')
    nav.append(f'    }}')
nav.append('}')
nav_text = '\n'.join(nav)

open('/tmp/_nav.txt', 'w').write(nav_text)
print('generated nav function')
"

python3 -c "
mode = []
mode.append('void Frames::handle_customnight_mode_keys()')
mode.append('{')
mode.append('    if (is_key_pressed_once(SDLK_c)) {')
mode.append('        ((Counter*)get_instance(custommode_284_instances))->add(1);')
for ai in ['freddyai_181','bonieai_182','chicaai_183','foxyai_184','bbai_185','toyfreddyai_186','toybonnieai_187','toychicaai_188','mangleai_189','goldenfreddyai_190']:
    mode.append(f'        ((Counter*)get_instance({ai}_instances))->set(0);')
mode.append('        ((Counter*)get_instance(allare20_25_instances))->set(0);')
mode.append('        media.play_id(SOUND_COIN_43, 1-1);')
mode.append('        ((Counter*)get_instance(doingcustom_223_instances))->set(((Counter*)get_instance(custommode_284_instances))->value);')
mode.append('    }')
mode.append('    if (is_key_pressed_once(SDLK_z)) {')
mode.append('        ((Counter*)get_instance(custommode_284_instances))->subtract(1);')
mode.append('        ((Counter*)get_instance(allare20_25_instances))->set(0);')
for ai in ['goldenfreddyai_190','mangleai_189','toychicaai_188','toybonnieai_187','toyfreddyai_186','bbai_185','foxyai_184','chicaai_183','bonieai_182','freddyai_181']:
    mode.append(f'        ((Counter*)get_instance({ai}_instances))->set(0);')
mode.append('        media.play_id(SOUND_COIN_43, 1-1);')
mode.append('        ((Counter*)get_instance(doingcustom_223_instances))->set(((Counter*)get_instance(custommode_284_instances))->value);')
mode.append('    }')
mode.append('}')
mode_text = '\n'.join(mode)

open('/tmp/_mode.txt', 'w').write(mode_text)
print('generated mode function')
"

python3 -c "
nav_text = open('/tmp/_nav.txt').read()
mode_text = open('/tmp/_mode.txt').read()

path = '$BUILD/events_11.cpp'
content = open(path).read()
marker = 'void Frames::handle_frame_13_pre_events()\n{\n    event_func_886();'
assert content.count(marker) == 1, str(content.count(marker))
new_start = 'void Frames::handle_frame_13_pre_events()\n{\n    handle_customnight_nav_keys();\n    handle_customnight_mode_keys();\n    event_func_886();'
content = content.replace(marker, nav_text + '\n' + mode_text + '\n' + new_start, 1)
open(path, 'w').write(content)
print('OK: Custom Night nav + mode installed and hooked')
"

rm -f /tmp/_nav.txt /tmp/_mode.txt

echo "=== Step 8/9: Custom Night READY (Enter) ==="

python3 -c "
path = '$BUILD/events_10.cpp'
content = open(path).read()

old = 'if (!(((Active*)get_instance(active2_10_instances))->mouse_over() && is_mouse_pressed_once(SDL_BUTTON_LEFT))) goto event_2_12_end;'
new = 'if (!((((Active*)get_instance(active2_10_instances))->mouse_over() && is_mouse_pressed_once(SDL_BUTTON_LEFT)) || is_key_pressed_once(SDLK_RETURN))) goto event_2_12_end;'

c = content.count(old)
assert c == 1, str(c)
content = content.replace(old, new, 1)
open(path, 'w').write(content)
print('OK: Enter now triggers Custom Night READY')
"

echo "=== Step 9/9: Camera monitor (G) / Mask (H) / Mute call (M) ==="

python3 -c "
path = '$BUILD/events_3.cpp'
content = open(path).read()

old_g = '        if (!(((Active*)get_instance(whitebutton_102_instances))->mouse_over())) goto event_147_3_end;'
new_g = '        if (!((((Active*)get_instance(whitebutton_102_instances))->mouse_over()) || is_key_pressed_once(SDLK_g))) goto event_147_3_end;'
assert content.count(old_g) == 1, 'whitebutton: ' + str(content.count(old_g))
content = content.replace(old_g, new_g, 1)

old_h = '        if (!(((Active*)get_instance(redbutton_103_instances))->mouse_over())) goto event_162_3_end;'
new_h = '        if (!((((Active*)get_instance(redbutton_103_instances))->mouse_over()) || is_key_pressed(SDLK_h))) goto event_162_3_end;'
assert content.count(old_h) == 1, 'redbutton: ' + str(content.count(old_h))
content = content.replace(old_h, new_h, 1)

open(path, 'w').write(content)
print('OK: G monitor open (whitebutton), H mask on (redbutton)')
"

python3 -c "
path = '$BUILD/events_6.cpp'
content = open(path).read()

old_g = '        if (!(((Active*)get_instance(dropbutton_108_instances))->mouse_over())) goto event_477_3_end;'
new_g = '        if (!((((Active*)get_instance(dropbutton_108_instances))->mouse_over()) || is_key_pressed_once(SDLK_g))) goto event_477_3_end;'
assert content.count(old_g) == 1, 'dropbutton g: ' + str(content.count(old_g))
content = content.replace(old_g, new_g, 1)

old_h = '        if (!(((Active*)get_instance(dropbutton_108_instances))->mouse_over())) goto event_478_3_end;'
new_h = '        if (!((((Active*)get_instance(dropbutton_108_instances))->mouse_over()) || is_key_pressed_once(SDLK_h))) goto event_478_3_end;'
assert content.count(old_h) == 1, 'dropbutton h: ' + str(content.count(old_h))
content = content.replace(old_h, new_h, 1)

open(path, 'w').write(content)
print('OK: G monitor close (dropbutton), H mask off (dropbutton)')
"

python3 -c "
path = '$BUILD/events_8.cpp'
content = open(path).read()

old_m = '        if (!(((Active*)get_instance(mutecall_177_instances))->mouse_over() && is_mouse_pressed_once(SDL_BUTTON_LEFT))) goto event_604_3_end;'
new_m = '        if (!((((Active*)get_instance(mutecall_177_instances))->mouse_over() && is_mouse_pressed_once(SDL_BUTTON_LEFT)) || is_key_pressed_once(SDLK_m))) goto event_604_3_end;'
assert content.count(old_m) == 1, 'mutecall: ' + str(content.count(old_m))
content = content.replace(old_m, new_m, 1)

open(path, 'w').write(content)
print('OK: M mute call')
"

echo "=== Step 10/10: flippanelbutton reset gate (buttonreset_99) - unconditional ==="

python3 -c "
path = '$BUILD/events_3.cpp'
content = open(path).read()

old = '        if (!(((Active*)get_instance(buttonreset_99_instances))->mouse_over())) goto event_154_3_end;'
new = '        // (unconditional - see step 10 comment for why the key-gated version was fragile)'
assert content.count(old) == 1, 'buttonreset: ' + str(content.count(old))
content = content.replace(old, new, 1)

open(path, 'w').write(content)
print('OK: flippanelbutton alterable[1] pinned to 0 unconditionally every frame')
"

echo "=== Step 11/11: Monitor icon visibility only (mask sprite left untouched) ==="

python3 -c "
path = '$BUILD/events_3.cpp'
content = open(path).read()

# --- event 159: panel-transition hide -> always visible ---
old_159 = '''        if (!((((Active*)get_instance(flippanelbutton_96_instances))->alterables->values.get(1)) == (1))) goto event_159_3_end;
        ((Active*)get_instance(flippanelbutton_96_instances))->set_visible(false);'''
new_159 = '''        if (!((((Active*)get_instance(flippanelbutton_96_instances))->alterables->values.get(1)) == (1))) goto event_159_3_end;
        ((Active*)get_instance(flippanelbutton_96_instances))->set_visible(true);'''
c = content.count(old_159)
assert c == 1, 'event 159: ' + str(c)
content = content.replace(old_159, new_159, 1)

# --- event 167: mask-is-on hide -> left as original conditional hide ---
old_167 = '''        if (!((((Active*)get_instance(mask_104_instances))->alterables->values.get(0)) != (0))) goto event_167_3_end;
        ((Active*)get_instance(flippanelbutton_96_instances))->set_visible(false);'''
c = content.count(old_167)
assert c == 1, 'event 167: ' + str(c)
# no replacement - event 167 stays exactly as-is (original hide-while-mask-on kept)

# --- event 160: mask sprite hide -> LEFT UNTOUCHED (reverted mistake) ---
# mask_104's own hide/show (events 160/161) is NOT patched at all anymore.
# No replacement performed here on purpose.

open(path, 'w').write(content)
print('OK: event 159 always-visible, event 167 restored (hide while mask on), mask sprite left fully original')
"

echo "=== Patching complete ==="
