#!/bin/bash
set -e
unset PYTHONHOME
unset PYTHONPATH

BUILD="$1"
if [ -z "$BUILD" ]; then
    echo "Usage: $0 /path/to/build" >&2
    exit 1
fi
cd "$BUILD"

echo "=== [1/9] Vent seal timing fix: selection-frame stamp ==="
python3 -c "
path = 'events_2.cpp'
content = open(path).read()
cams = [(11,161,'59_3'),(12,163,'60_3'),(13,165,'61_3'),(14,166,'62_3'),(15,167,'63_3')]
for n, obj_id, label in cams:
    old = f'((Active*)get_instance(cam{n}_{obj_id}_instances))->alterables->values.set(0, 1);'
    new = old + f'\n        ((Active*)get_instance(cam{n}_{obj_id}_instances))->alterables->values.set(1, loop_count);'
    c = content.count(old)
    assert c == 1, f'cam{n}: {c} matches'
    content = content.replace(old, new, 1)
open(path, 'w').write(content)
print('==OK==')
"

echo "=== [2/9] Vent seal timing fix: ==="
python3 -c "
path = 'events_6.cpp'
content = open(path).read()
cams = [(11,161,'442_3'),(12,163,'443_3'),(13,165,'444_3'),(14,166,'445_3'),(15,167,'446_3')]
for n, obj_id, label in cams:
    old = f'if (!((((Active*)get_instance(cam{n}_{obj_id}_instances))->alterables->values.get(0)) == (1))) goto event_{label}_end;'
    new = old + f'\n        if (!((loop_count) > (((Active*)get_instance(cam{n}_{obj_id}_instances))->alterables->values.get(1)))) goto event_{label}_end;'
    c = content.count(old)
    assert c == 1, f'cam{n}: {c} matches'
    content = content.replace(old, new, 1)
open(path, 'w').write(content)
print('==OK==')
"

echo "=== [3/9] Vent seal timing fix: direct cam-click seal guard (events_7.cpp) + X key ==="
python3 -c "
path = 'events_7.cpp'
content = open(path).read()
cams = [(11,161,'489_3'),(12,163,'490_3'),(13,165,'491_3'),(14,166,'492_3'),(15,167,'493_3')]
for n, obj_id, label in cams:
    old = f'if (!(((Active*)get_instance(cam{n}_{obj_id}_instances))->mouse_over() && is_mouse_pressed_once(SDL_BUTTON_LEFT))) goto event_{label}_end;'
    new = old + f'\n        if (!((((Active*)get_instance(cam{n}_{obj_id}_instances))->alterables->values.get(0)) == (1))) goto event_{label}_end;\n        if (!((loop_count) > (((Active*)get_instance(cam{n}_{obj_id}_instances))->alterables->values.get(1)))) goto event_{label}_end;'
    c = content.count(old)
    assert c == 1, f'cam{n}: {c} matches'
    content = content.replace(old, new, 1)
open(path, 'w').write(content)
print('==OK==')
"

echo "=== [4/9] Vent seal timing fix: ==="
python3 -c "
path = 'events_2.cpp'
content = open(path).read()
cams = [(11,161,'59_3'),(12,163,'60_3'),(13,165,'61_3'),(14,166,'62_3'),(15,167,'63_3')]
for n, obj_id, label in cams:
    old = f'if (!((((Counter*)get_instance(goingtoseal_185_instances))->value) == (0))) goto event_{label}_end;'
    new = old + f'\n        if (!((((Active*)get_instance(cam{n}_{obj_id}_instances))->alterables->values.get(0)) == (0))) goto event_{label}_end;'
    c = content.count(old)
    assert c == 1, f'cam{n}: {c} matches'
    content = content.replace(old, new, 1)
open(path, 'w').write(content)
print('==OK==')
"

echo "=== [5/9] Keybinds: G camera monitor, ==="
python3 -c "
path = 'events_2.cpp'
content = open(path).read()

old1 = 'if (!(((Active*)get_instance(flipitout_69_instances))->mouse_over() && is_mouse_pressed_once(SDL_BUTTON_LEFT))) goto event_21_3_end;'
new1 = 'if (!((((Active*)get_instance(flipitout_69_instances))->mouse_over() && is_mouse_pressed_once(SDL_BUTTON_LEFT)) || is_key_pressed_once(SDLK_g))) goto event_21_3_end;'
assert content.count(old1) == 1; content = content.replace(old1, new1, 1)

old2 = 'if (!(((Active*)get_instance(flipitout_69_instances))->mouse_over() && is_mouse_pressed_once(SDL_BUTTON_LEFT))) goto event_22_3_end;'
new2 = 'if (!((((Active*)get_instance(flipitout_69_instances))->mouse_over() && is_mouse_pressed_once(SDL_BUTTON_LEFT)) || is_key_pressed_once(SDLK_g))) goto event_22_3_end;'
assert content.count(old2) == 1; content = content.replace(old2, new2, 1)

old3 = 'if (!(((Active*)get_instance(screentwoflipper_77_instances))->mouse_over() && is_mouse_pressed_once(SDL_BUTTON_LEFT))) goto event_41_3_end;'
new3 = 'if (!((((Active*)get_instance(screentwoflipper_77_instances))->mouse_over() && is_mouse_pressed_once(SDL_BUTTON_LEFT)) || is_key_pressed_once(SDLK_h))) goto event_41_3_end;'
assert content.count(old3) == 1; content = content.replace(old3, new3, 1)

old4 = 'if (!(((Active*)get_instance(exittext_144_instances))->mouse_over() && is_mouse_pressed_once(SDL_BUTTON_LEFT))) goto event_46_3_end;'
new4 = ('if (!((((Active*)get_instance(exittext_144_instances))->mouse_over() && is_mouse_pressed_once(SDL_BUTTON_LEFT)) '
        '|| (is_key_pressed_once(SDLK_RETURN) && (((Active*)get_instance(cursor_142_instances))->alterables->values.get(0)) == (5)))) goto event_46_3_end;')
assert content.count(old4) == 1; content = content.replace(old4, new4, 1)

open(path, 'w').write(content)
print('==OK==')
"
python3 -c "
path = 'events_5.cpp'
content = open(path).read()
targets = [('audiotext_138','304_3',1),('cameratext_139','305_3',2),('ventilationtext_140','306_3',3),('rebootalltext_141','307_3',4)]
for obj, label, pos in targets:
    old = f'if (!(((Active*)get_instance({obj}_instances))->mouse_over() && is_mouse_pressed_once(SDL_BUTTON_LEFT))) goto event_{label}_end;'
    new = (f'if (!((((Active*)get_instance({obj}_instances))->mouse_over() && is_mouse_pressed_once(SDL_BUTTON_LEFT)) '
           f'|| (is_key_pressed_once(SDLK_RETURN) && (((Active*)get_instance(cursor_142_instances))->alterables->values.get(0)) == ({pos})))) goto event_{label}_end;')
    c = content.count(old); assert c == 1, f'{obj}: {c} matches'
    content = content.replace(old, new, 1)
open(path, 'w').write(content)
print('==OK==')
"

echo "=== [6/9] Keybinds: E audio lure, F main/vent toggle, A/D office pan ==="
python3 -c "
path = 'events_4.cpp'
content = open(path).read()
old = 'if (!(((Active*)get_instance(playbutton_133_instances))->mouse_over() && is_mouse_pressed_once(SDL_BUTTON_LEFT))) goto event_225_3_end;'
new = 'if (!((((Active*)get_instance(playbutton_133_instances))->mouse_over() && is_mouse_pressed_once(SDL_BUTTON_LEFT)) || is_key_pressed_once(SDLK_e))) goto event_225_3_end;'
assert content.count(old) == 1; content = content.replace(old, new, 1)
open(path, 'w').write(content)
print('==OK==')
"
python3 -c "
path = 'events_5.cpp'
content = open(path).read()
old = 'if (!(((Active*)get_instance(togglebutton_159_instances))->mouse_over() && is_mouse_pressed_once(SDL_BUTTON_LEFT))) goto event_384_3_end;'
new = 'if (!((((Active*)get_instance(togglebutton_159_instances))->mouse_over() && is_mouse_pressed_once(SDL_BUTTON_LEFT)) || is_key_pressed_once(SDLK_f))) goto event_384_3_end;'
assert content.count(old) == 1; content = content.replace(old, new, 1)
open(path, 'w').write(content)
print('==OK==')
"
python3 -c "
path = 'events_6.cpp'
content = open(path).read()
old = 'if (!(((Active*)get_instance(togglebutton_159_instances))->mouse_over() && is_mouse_pressed_once(SDL_BUTTON_LEFT))) goto event_386_3_end;'
new = 'if (!((((Active*)get_instance(togglebutton_159_instances))->mouse_over() && is_mouse_pressed_once(SDL_BUTTON_LEFT)) || is_key_pressed_once(SDLK_f))) goto event_386_3_end;'
assert content.count(old) == 1; content = content.replace(old, new, 1)
open(path, 'w').write(content)
print('==OK==')
"
python3 -c "
path = 'events_2.cpp'
content = open(path).read()
left_events = ['8_3','9_3','10_3','11_3','12_3','13_3']
right_events = ['14_3','15_3','16_3','17_3','18_3','19_3']
left_objs = {'8_3':'scrollleft_61','9_3':'scrollleft_61','10_3':'scrollleft_61','11_3':'scrollleft2_62','12_3':'scrollleft2_62','13_3':'scrollleft2_62'}
right_objs = {'14_3':'scrollright_63','15_3':'scrollright_63','16_3':'scrollright_63','17_3':'scrollright2_64','18_3':'scrollright2_64','19_3':'scrollright2_64'}
for label in left_events:
    obj = left_objs[label]
    old = f'if (!(((Active*)get_instance({obj}_instances))->mouse_over())) goto event_{label}_end;'
    new = f'if (!((((Active*)get_instance({obj}_instances))->mouse_over()) || is_key_pressed(SDLK_a))) goto event_{label}_end;'
    c = content.count(old); assert c == 1, f'{label}: {c} matches'
    content = content.replace(old, new, 1)
for label in right_events:
    obj = right_objs[label]
    old = f'if (!(((Active*)get_instance({obj}_instances))->mouse_over())) goto event_{label}_end;'
    new = f'if (!((((Active*)get_instance({obj}_instances))->mouse_over()) || is_key_pressed(SDLK_d))) goto event_{label}_end;'
    c = content.count(old); assert c == 1, f'{label}: {c} matches'
    content = content.replace(old, new, 1)
open(path, 'w').write(content)
print('==OK==')
"

echo "=== [7/9] Keybind: X seals selected vent ==="
python3 -c "
path = 'events_6.cpp'
content = open(path).read()
labels = ['442_3','443_3','444_3','445_3','446_3']
for label in labels:
    old = f'if (!(((Active*)get_instance(sealventbutton_174_instances))->mouse_over() && is_mouse_pressed_once(SDL_BUTTON_LEFT))) goto event_{label}_end;'
    new = f'if (!((((Active*)get_instance(sealventbutton_174_instances))->mouse_over() && is_mouse_pressed_once(SDL_BUTTON_LEFT)) || is_key_pressed_once(SDLK_x))) goto event_{label}_end;'
    c = content.count(old); assert c == 1, f'{label}: {c} matches'
    content = content.replace(old, new, 1)
open(path, 'w').write(content)
print('==OK==')
"

echo "=== [8/9] Main-cam arrow nav (declare + hook + body) ==="
python3 -c "
path = 'events.h'
content = open(path).read()
old = '    void event_func_161();'
new = old + '\n    void handle_cam_arrow_nav();'
assert content.count(old) == 1
content = content.replace(old, new, 1)
open(path, 'w').write(content)
print('==OK== (declared)')
"
python3 -c "
path = 'events_9.cpp'
content = open(path).read()
old = '    event_func_161();'
new = old + '\n    handle_cam_arrow_nav();'
assert content.count(old) == 1
content = content.replace(old, new, 1)
open(path, 'w').write(content)
print('==OK== (hooked)')
"

echo "=== [8b/10] Main-cam arrow nav: ==="
cat >> events_2.cpp << 'CPPEOF_MAINCAM'

void Frames::handle_cam_arrow_nav()
{
    if (!(((Active*)get_instance(obj01_80_instances))->flags & VISIBLE)) return;
    // Arrow-key camera navigation. Relinks the same wires the real
    // click handlers (event_func_151-160) use: alterable select/zero,
    // clicked_104 (always 1, matching every real click handler exactly),
    // youin_187 set to the target cam number (matches the click handler),
    // monin_188 set to the same number (relinks the check_overlap(
    // dhfgh_109, objNN)-driven wire in events_6.cpp 454-463_3, which only
    // fires from mouse-cursor overlap and has no keyboard equivalent -
    // every read of youin_187/monin_188 across events_3/4/5/6 only ever
    // compares them to EACH OTHER, never to a literal, so keeping them
    // in lockstep is the correct behavior, confirmed by reading every
    // read site), and viewing2_121 repositioning (drives audio lure).
    if ((((Active*)get_instance(obj01_80_instances))->alterables->values.get(0)) == (1)) {
        if (is_key_pressed_once(SDLK_UP)) {
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            ((Counter*)get_instance(youin_187_instances))->set(6);
            { FrameObject * parent = ((Active*)get_instance(obj06_89_instances)); if (parent != NULL) { ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
            return;
        }
        if (is_key_pressed_once(SDLK_RIGHT)) {
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            ((Counter*)get_instance(youin_187_instances))->set(2);
            { FrameObject * parent = ((Active*)get_instance(obj02_83_instances)); if (parent != NULL) { ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
            return;
        }
    }
    if ((((Active*)get_instance(obj02_83_instances))->alterables->values.get(0)) == (1)) {
        if (is_key_pressed_once(SDLK_UP)) {
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            ((Counter*)get_instance(youin_187_instances))->set(5);
            { FrameObject * parent = ((Active*)get_instance(obj05_88_instances)); if (parent != NULL) { ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
            return;
        }
        if (is_key_pressed_once(SDLK_LEFT)) {
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            ((Counter*)get_instance(youin_187_instances))->set(1);
            { FrameObject * parent = ((Active*)get_instance(obj01_80_instances)); if (parent != NULL) { ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
            return;
        }
        if (is_key_pressed_once(SDLK_RIGHT)) {
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            ((Counter*)get_instance(youin_187_instances))->set(3);
            { FrameObject * parent = ((Active*)get_instance(obj03_82_instances)); if (parent != NULL) { ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
            return;
        }
    }
    if ((((Active*)get_instance(obj03_82_instances))->alterables->values.get(0)) == (1)) {
        if (is_key_pressed_once(SDLK_UP)) {
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            ((Counter*)get_instance(youin_187_instances))->set(4);
            { FrameObject * parent = ((Active*)get_instance(obj04_86_instances)); if (parent != NULL) { ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
            return;
        }
        if (is_key_pressed_once(SDLK_LEFT)) {
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            ((Counter*)get_instance(youin_187_instances))->set(2);
            { FrameObject * parent = ((Active*)get_instance(obj02_83_instances)); if (parent != NULL) { ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
            return;
        }
    }
    if ((((Active*)get_instance(obj04_86_instances))->alterables->values.get(0)) == (1)) {
        if (is_key_pressed_once(SDLK_LEFT)) {
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            ((Counter*)get_instance(youin_187_instances))->set(5);
            { FrameObject * parent = ((Active*)get_instance(obj05_88_instances)); if (parent != NULL) { ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
            return;
        }
        if (is_key_pressed_once(SDLK_UP)) {
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            ((Counter*)get_instance(youin_187_instances))->set(10);
            { FrameObject * parent = ((Active*)get_instance(obj10_96_instances)); if (parent != NULL) { ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
            return;
        }
        if (is_key_pressed_once(SDLK_DOWN)) {
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            ((Counter*)get_instance(youin_187_instances))->set(3);
            { FrameObject * parent = ((Active*)get_instance(obj03_82_instances)); if (parent != NULL) { ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
            return;
        }
    }
    if ((((Active*)get_instance(obj05_88_instances))->alterables->values.get(0)) == (1)) {
        if (is_key_pressed_once(SDLK_LEFT)) {
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            ((Counter*)get_instance(youin_187_instances))->set(6);
            { FrameObject * parent = ((Active*)get_instance(obj06_89_instances)); if (parent != NULL) { ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
            return;
        }
        if (is_key_pressed_once(SDLK_UP)) {
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            ((Counter*)get_instance(youin_187_instances))->set(8);
            { FrameObject * parent = ((Active*)get_instance(obj08_94_instances)); if (parent != NULL) { ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
            return;
        }
        if (is_key_pressed_once(SDLK_RIGHT)) {
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            ((Counter*)get_instance(youin_187_instances))->set(4);
            { FrameObject * parent = ((Active*)get_instance(obj04_86_instances)); if (parent != NULL) { ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
            return;
        }
        if (is_key_pressed_once(SDLK_DOWN)) {
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            ((Counter*)get_instance(youin_187_instances))->set(2);
            { FrameObject * parent = ((Active*)get_instance(obj02_83_instances)); if (parent != NULL) { ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
            return;
        }
    }
    if ((((Active*)get_instance(obj06_89_instances))->alterables->values.get(0)) == (1)) {
        if (is_key_pressed_once(SDLK_DOWN)) {
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            ((Counter*)get_instance(youin_187_instances))->set(1);
            { FrameObject * parent = ((Active*)get_instance(obj01_80_instances)); if (parent != NULL) { ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
            return;
        }
        if (is_key_pressed_once(SDLK_UP)) {
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            ((Counter*)get_instance(youin_187_instances))->set(7);
            { FrameObject * parent = ((Active*)get_instance(obj07_90_instances)); if (parent != NULL) { ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
            return;
        }
        if (is_key_pressed_once(SDLK_RIGHT)) {
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            ((Counter*)get_instance(youin_187_instances))->set(5);
            { FrameObject * parent = ((Active*)get_instance(obj05_88_instances)); if (parent != NULL) { ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
            return;
        }
    }
    if ((((Active*)get_instance(obj07_90_instances))->alterables->values.get(0)) == (1)) {
        if (is_key_pressed_once(SDLK_DOWN)) {
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            ((Counter*)get_instance(youin_187_instances))->set(6);
            { FrameObject * parent = ((Active*)get_instance(obj06_89_instances)); if (parent != NULL) { ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
            return;
        }
        if (is_key_pressed_once(SDLK_RIGHT)) {
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            ((Counter*)get_instance(youin_187_instances))->set(8);
            { FrameObject * parent = ((Active*)get_instance(obj08_94_instances)); if (parent != NULL) { ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
            return;
        }
    }
    if ((((Active*)get_instance(obj08_94_instances))->alterables->values.get(0)) == (1)) {
        if (is_key_pressed_once(SDLK_DOWN)) {
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            ((Counter*)get_instance(youin_187_instances))->set(5);
            { FrameObject * parent = ((Active*)get_instance(obj05_88_instances)); if (parent != NULL) { ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
            return;
        }
        if (is_key_pressed_once(SDLK_UP)) {
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            ((Counter*)get_instance(youin_187_instances))->set(9);
            { FrameObject * parent = ((Active*)get_instance(obj09_95_instances)); if (parent != NULL) { ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
            return;
        }
        if (is_key_pressed_once(SDLK_LEFT)) {
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            ((Counter*)get_instance(youin_187_instances))->set(7);
            { FrameObject * parent = ((Active*)get_instance(obj07_90_instances)); if (parent != NULL) { ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
            return;
        }
    }
    if ((((Active*)get_instance(obj09_95_instances))->alterables->values.get(0)) == (1)) {
        if (is_key_pressed_once(SDLK_DOWN)) {
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            ((Counter*)get_instance(youin_187_instances))->set(8);
            { FrameObject * parent = ((Active*)get_instance(obj08_94_instances)); if (parent != NULL) { ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
            return;
        }
        if (is_key_pressed_once(SDLK_RIGHT)) {
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            ((Counter*)get_instance(youin_187_instances))->set(10);
            { FrameObject * parent = ((Active*)get_instance(obj10_96_instances)); if (parent != NULL) { ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
            return;
        }
    }
    if ((((Active*)get_instance(obj10_96_instances))->alterables->values.get(0)) == (1)) {
        if (is_key_pressed_once(SDLK_DOWN)) {
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            ((Counter*)get_instance(youin_187_instances))->set(4);
            { FrameObject * parent = ((Active*)get_instance(obj04_86_instances)); if (parent != NULL) { ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
            return;
        }
        if (is_key_pressed_once(SDLK_LEFT)) {
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            ((Counter*)get_instance(youin_187_instances))->set(9);
            { FrameObject * parent = ((Active*)get_instance(obj09_95_instances)); if (parent != NULL) { ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
            return;
        }
    }
}
CPPEOF_MAINCAM
echo "==OK=="

echo "=== [9/10] Vent-cam arrow nav ==="
python3 -c "
path = 'events.h'
content = open(path).read()
old = '    void handle_cam_arrow_nav();'
new = old + '\n    void handle_vent_arrow_nav();'
assert content.count(old) == 1
content = content.replace(old, new, 1)
open(path, 'w').write(content)
print('==OK== (declared)')
"
python3 -c "
path = 'events_9.cpp'
content = open(path).read()
old = '    handle_cam_arrow_nav();'
new = old + '\n    handle_vent_arrow_nav();'
assert content.count(old) == 1
content = content.replace(old, new, 1)
open(path, 'w').write(content)
print('==OK== (hooked)')
"
cat >> events_2.cpp << 'CPPEOF_VENTCAM'

void Frames::handle_vent_arrow_nav()
{
    if (!(((Active*)get_instance(cam11_161_instances))->flags & VISIBLE)) return;
    if (!((((Counter*)get_instance(goingtoseal_185_instances))->value) == (0))) return;
    if ((((Active*)get_instance(cam11_161_instances))->alterables->values.get(0)) == (1)) {
        if (is_key_pressed_once(SDLK_DOWN)) {
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            {
                FrameObject * parent = ((Active*)get_instance(cam12_163_instances));
                if (parent != NULL) {
                    ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0);
                }
            }
            ((Active*)get_instance(cam12_163_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(cam12_163_instances))->alterables->values.set(1, loop_count);
            ((Active*)get_instance(cam11_161_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(cam13_165_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(cam14_166_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(cam15_167_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(youin_187_instances))->set(12);
            return;
        }
    }
    if ((((Active*)get_instance(cam12_163_instances))->alterables->values.get(0)) == (1)) {
        if (is_key_pressed_once(SDLK_UP)) {
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            {
                FrameObject * parent = ((Active*)get_instance(cam11_161_instances));
                if (parent != NULL) {
                    ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0);
                }
            }
            ((Active*)get_instance(cam11_161_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(cam11_161_instances))->alterables->values.set(1, loop_count);
            ((Active*)get_instance(cam12_163_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(cam13_165_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(cam14_166_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(cam15_167_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(youin_187_instances))->set(11);
            return;
        }
        if (is_key_pressed_once(SDLK_DOWN)) {
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            {
                FrameObject * parent = ((Active*)get_instance(cam13_165_instances));
                if (parent != NULL) {
                    ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0);
                }
            }
            ((Active*)get_instance(cam13_165_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(cam13_165_instances))->alterables->values.set(1, loop_count);
            ((Active*)get_instance(cam11_161_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(cam12_163_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(cam14_166_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(cam15_167_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(youin_187_instances))->set(13);
            return;
        }
        if (is_key_pressed_once(SDLK_RIGHT)) {
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            {
                FrameObject * parent = ((Active*)get_instance(cam14_166_instances));
                if (parent != NULL) {
                    ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0);
                }
            }
            ((Active*)get_instance(cam14_166_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(cam14_166_instances))->alterables->values.set(1, loop_count);
            ((Active*)get_instance(cam11_161_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(cam12_163_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(cam13_165_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(cam15_167_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(youin_187_instances))->set(14);
            return;
        }
    }
    if ((((Active*)get_instance(cam13_165_instances))->alterables->values.get(0)) == (1)) {
        if (is_key_pressed_once(SDLK_UP)) {
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            {
                FrameObject * parent = ((Active*)get_instance(cam12_163_instances));
                if (parent != NULL) {
                    ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0);
                }
            }
            ((Active*)get_instance(cam12_163_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(cam12_163_instances))->alterables->values.set(1, loop_count);
            ((Active*)get_instance(cam11_161_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(cam13_165_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(cam14_166_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(cam15_167_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(youin_187_instances))->set(12);
            return;
        }
        if (is_key_pressed_once(SDLK_DOWN)) {
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            {
                FrameObject * parent = ((Active*)get_instance(cam15_167_instances));
                if (parent != NULL) {
                    ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0);
                }
            }
            ((Active*)get_instance(cam15_167_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(cam15_167_instances))->alterables->values.set(1, loop_count);
            ((Active*)get_instance(cam11_161_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(cam12_163_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(cam13_165_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(cam14_166_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(youin_187_instances))->set(15);
            return;
        }
        if (is_key_pressed_once(SDLK_RIGHT)) {
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            {
                FrameObject * parent = ((Active*)get_instance(cam15_167_instances));
                if (parent != NULL) {
                    ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0);
                }
            }
            ((Active*)get_instance(cam15_167_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(cam15_167_instances))->alterables->values.set(1, loop_count);
            ((Active*)get_instance(cam11_161_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(cam12_163_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(cam13_165_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(cam14_166_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(youin_187_instances))->set(15);
            return;
        }
    }
    if ((((Active*)get_instance(cam14_166_instances))->alterables->values.get(0)) == (1)) {
        if (is_key_pressed_once(SDLK_DOWN)) {
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            {
                FrameObject * parent = ((Active*)get_instance(cam15_167_instances));
                if (parent != NULL) {
                    ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0);
                }
            }
            ((Active*)get_instance(cam15_167_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(cam15_167_instances))->alterables->values.set(1, loop_count);
            ((Active*)get_instance(cam11_161_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(cam12_163_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(cam13_165_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(cam14_166_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(youin_187_instances))->set(15);
            return;
        }
        if (is_key_pressed_once(SDLK_LEFT)) {
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            {
                FrameObject * parent = ((Active*)get_instance(cam12_163_instances));
                if (parent != NULL) {
                    ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0);
                }
            }
            ((Active*)get_instance(cam12_163_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(cam12_163_instances))->alterables->values.set(1, loop_count);
            ((Active*)get_instance(cam11_161_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(cam13_165_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(cam14_166_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(cam15_167_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(youin_187_instances))->set(12);
            return;
        }
    }
    if ((((Active*)get_instance(cam15_167_instances))->alterables->values.get(0)) == (1)) {
        if (is_key_pressed_once(SDLK_UP)) {
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            {
                FrameObject * parent = ((Active*)get_instance(cam14_166_instances));
                if (parent != NULL) {
                    ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0);
                }
            }
            ((Active*)get_instance(cam14_166_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(cam14_166_instances))->alterables->values.set(1, loop_count);
            ((Active*)get_instance(cam11_161_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(cam12_163_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(cam13_165_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(cam15_167_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(youin_187_instances))->set(14);
            return;
        }
        if (is_key_pressed_once(SDLK_LEFT)) {
            ((Active*)get_instance(obj01_80_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj02_83_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj03_82_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj04_86_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj05_88_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj06_89_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj07_90_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj08_94_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj09_95_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(obj10_96_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(clicked_104_instances))->set(1);
            camerascreen_105_instances.clear_selection();
            for (ObjectIterator p_it(camerascreen_105_instances); !p_it.end(); ++p_it) {
                FrameObject * parent = ((Active*)*p_it);
                add_object(create_smallblip_106(parent->x + 0, parent->y + 0), parent->layer);
            }
            {
                FrameObject * parent = ((Active*)get_instance(cam13_165_instances));
                if (parent != NULL) {
                    ((Active*)get_instance(viewing2_121_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0);
                }
            }
            ((Active*)get_instance(cam13_165_instances))->alterables->values.set(0, 1);
            ((Active*)get_instance(cam13_165_instances))->alterables->values.set(1, loop_count);
            ((Active*)get_instance(cam11_161_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(cam12_163_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(cam14_166_instances))->alterables->values.set(0, 0);
            ((Active*)get_instance(cam15_167_instances))->alterables->values.set(0, 0);
            ((Counter*)get_instance(youin_187_instances))->set(13);
            return;
        }
    }
}
CPPEOF_VENTCAM
echo "==OK=="

echo "=== [10/10] Keybind: M mutes the audio lure call ==="
python3 -c "
path = 'events_8.cpp'
content = open(path).read()
old = 'if (!(((Active*)(*it))->mouse_over() && is_mouse_pressed_once(SDL_BUTTON_LEFT))) { it.deselect(); continue; }\n            if (!(((Active*)(*it))->flags & VISIBLE)) { it.deselect(); continue; }'
new = 'if (!((((Active*)(*it))->mouse_over() && is_mouse_pressed_once(SDL_BUTTON_LEFT)) || is_key_pressed_once(SDLK_m))) { it.deselect(); continue; }\n            if (!(((Active*)(*it))->flags & VISIBLE)) { it.deselect(); continue; }'
count = content.count(old)
assert count == 1, f'mute_221 anchor: found {count} matches, expected 1'
content = content.replace(old, new, 1)
open(path, 'w').write(content)
print('==OK==')
"

echo "=== [11/11] Night reload fix: clear scare state kept in global objects ==="
python3 -c "
path = 'events_9.cpp'
content = open(path).read()
old = 'void Frames::on_frame_4_init()\\n{\\n'
assert content.count(old) == 1, f'on_frame_4_init: {content.count(old)} matches'
assert 'night reload: clear state kept in global objects' not in content
lines = [
    '    // night reload: clear state kept in global objects',
    '    global_data_41_bb_scare.value.values.set(0, 0);',
    '    global_data_45_chica_2.value.values.set(0, 0);',
    '    global_data_45_chica_2.value.values.set(1, 0);',
    '    global_data_46_foxy.value.values.set(0, 0);',
    '    global_data_42_fwalk.value.values.set(0, 0);',
    '    global_data_42_fwalk.value.values.set(1, 0);',
    '    global_data_44_phantom_head.value.values.set(0, 0);',
    '    global_data_44_phantom_head.value.values.set(1, 0);',
    '    global_data_44_phantom_head.value.values.set(2, 0);',
]
new = old + '\\n'.join(lines) + '\\n'
content = content.replace(old, new, 1)
open(path, 'w').write(content)
print('==OK==')
"

echo "=== All patches applied successfully ==="
