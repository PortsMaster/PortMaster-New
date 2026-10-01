#!/bin/bash

set -e

unset PYTHONHOME
unset PYTHONPATH

BUILD="$1"
if [ -z "$BUILD" ]; then
    echo "Usage: $0 /path/to/build" >&2
    exit 1
fi

resolve_id() {
    local base="$1"
    local matches
    matches=$(grep -oE "#define [A-Za-z0-9_]*${base}_[0-9]+_instances" "$BUILD/lists.h" \
              | sed 's/^#define //; s/_instances$//' | sort -u)
    local count
    count=$(printf '%s\n' "$matches" | grep -c .)
    if [ "$count" -eq 0 ]; then
        echo "ERROR: could not resolve object identifier for '$base' in $BUILD/lists.h" >&2
        echo "       (the object may have been renamed, removed, or this is a different .exe)" >&2
        exit 1
    fi
    if [ "$count" -gt 1 ]; then
        echo "ERROR: '$base' matched more than one object in $BUILD/lists.h - ambiguous:" >&2
        printf '%s\n' "$matches" >&2
        exit 1
    fi
    printf '%s\n' "$matches"
}

resolve_id_exact() {
    local exact="$1"
    local match
    match=$(grep -oE "#define [A-Za-z0-9_]*${exact}_instances" "$BUILD/lists.h" \
            | sed 's/^#define //; s/_instances$//')
    if [ -z "$match" ]; then
        echo "ERROR: could not resolve exact object identifier '$exact' in $BUILD/lists.h" >&2
        echo "       (the object may have been renamed/removed, or the _N suffix shifted - re-check lists.h)" >&2
        exit 1
    fi
    printf '%s\n' "$match"
}

echo "=== Resolving object identifiers from lists.h ==="

FLIPUP=$(resolve_id flipup)
FLIPDOWN=$(resolve_id flipdown)
FLIPIT=$(resolve_id flipit)
DOOROPENLEFT=$(resolve_id dooropenleft)
LIGHTONLEFT=$(resolve_id lightonleft)
DOOROPENRIGHT=$(resolve_id dooropenright)
LIGHTONRIGHT=$(resolve_id lightonright)
LEFTHIGH=$(resolve_id lefthigh)
RIGHTHIGH=$(resolve_id righthigh)
MUTECALL=$(resolve_id mutecall)
ACTIVE2=$(resolve_id active2)
SETVIEWINGTO=$(resolve_id setviewingto)
VIEWING=$(resolve_id viewing)
LASTCLICKED=$(resolve_id lastclicked)
YOU=$(resolve_id you)
OBJ1ASHOWSTAGE=$(resolve_id_exact obj1ashowstage_75)
OBJ1BDININGAREA=$(resolve_id obj1bdiningarea)
BACKSTAGE=$(resolve_id backstage)
OBJ1ASHOWSTAGE=$(resolve_id_exact obj1ashowstage_75)
OBJ1BDININGAREA=$(resolve_id obj1bdiningarea)
OBJ1CSTAGEB=$(resolve_id obj1cstageb)
CAM2A=$(resolve_id cam2a)
CAM2B=$(resolve_id cam2b)
CAM3CLOSET=$(resolve_id cam3closet)
CAM4A=$(resolve_id cam4a)
CAM4B=$(resolve_id cam4b)
CAM6KITCHEN=$(resolve_id cam6kitchen)
CAM7BATHROOMS=$(resolve_id cam7bathrooms)
CAM2A=$(resolve_id cam2a)
CAM2B=$(resolve_id cam2b)
CAM4A=$(resolve_id cam4a)
CAM4B=$(resolve_id cam4b)
CAM6KITCHEN=$(resolve_id cam6kitchen)
CAM7BATHROOMS=$(resolve_id cam7bathrooms)
FREDDYAI=$(resolve_id freddyai)
BONIEAI=$(resolve_id bonieai)
CHICAAI=$(resolve_id chicaai)
FOXYAI=$(resolve_id foxyai)

echo "=== Applying Five Nights at Freddy's patches ==="

# --------------------------------------------------------------------------
# Step 1/6: Interaction controls
# --------------------------------------------------------------------------
echo "=== Step 1/6: Interaction controls ==="

AMP='\&\&'

sed -i "s/((Active\*)get_instance(${DOOROPENLEFT}_instances))->mouse_over() ${AMP} is_mouse_pressed_once(SDL_BUTTON_LEFT)/(((Active*)get_instance(${DOOROPENLEFT}_instances))->mouse_over() ${AMP} is_mouse_pressed_once(SDL_BUTTON_LEFT)) || is_key_pressed_once(SDLK_e)/g" "$BUILD/events_2.cpp"

sed -i "s/((Active\*)get_instance(${LIGHTONLEFT}_instances))->mouse_over() ${AMP} is_mouse_pressed_once(SDL_BUTTON_LEFT)/(((Active*)get_instance(${LIGHTONLEFT}_instances))->mouse_over() ${AMP} is_mouse_pressed_once(SDL_BUTTON_LEFT)) || is_key_pressed_once(SDLK_f)/g" "$BUILD/events_3.cpp"

sed -i "s/((Active\*)get_instance(${DOOROPENRIGHT}_instances))->mouse_over() ${AMP} is_mouse_pressed_once(SDL_BUTTON_LEFT)/(((Active*)get_instance(${DOOROPENRIGHT}_instances))->mouse_over() ${AMP} is_mouse_pressed_once(SDL_BUTTON_LEFT)) || is_key_pressed_once(SDLK_i)/g" "$BUILD/events_2.cpp"

sed -i "s/((Active\*)get_instance(${LIGHTONRIGHT}_instances))->mouse_over() ${AMP} is_mouse_pressed_once(SDL_BUTTON_LEFT)/(((Active*)get_instance(${LIGHTONRIGHT}_instances))->mouse_over() ${AMP} is_mouse_pressed_once(SDL_BUTTON_LEFT)) || is_key_pressed_once(SDLK_j)/g" "$BUILD/events_3.cpp"

sed -i "s/if (!(((Active\*)get_instance(${LEFTHIGH}_instances))->mouse_over())) goto event_84_3_end;/if (!(((Active*)get_instance(${LEFTHIGH}_instances))->mouse_over() || is_key_pressed(SDLK_a))) goto event_84_3_end;/" "$BUILD/events_2.cpp"

sed -i "s/if (!(((Active\*)get_instance(${RIGHTHIGH}_instances))->mouse_over())) goto event_86_3_end;/if (!(((Active*)get_instance(${RIGHTHIGH}_instances))->mouse_over() || is_key_pressed(SDLK_d))) goto event_86_3_end;/" "$BUILD/events_2.cpp"

# --------------------------------------------------------------------------
# Step 2/6: Camera monitor
echo "=== Step 2/6: Camera monitor ==="

python3 -c "
path = '$BUILD/events_3.cpp'
with open(path) as f:
    content = f.read()

old_open = 'if (!(((Active*)get_instance(${FLIPUP}_instances))->mouse_over())) goto event_130_3_end;'
new_open = 'if (!(((Active*)get_instance(${FLIPUP}_instances))->mouse_over() || is_key_pressed_once(SDLK_g))) goto event_130_3_end;'
if content.count(old_open) != 1:
    raise SystemExit('ERROR: expected exactly 1 match for camera-open anchor line, found ' + str(content.count(old_open)))
content = content.replace(old_open, new_open, 1)

old_close = 'if (!(((Active*)get_instance(${FLIPUP}_instances))->mouse_over())) goto event_131_3_end;'
new_close = 'if (!(((Active*)get_instance(${FLIPUP}_instances))->mouse_over() || is_key_pressed_once(SDLK_h))) goto event_131_3_end;'
if content.count(old_close) != 1:
    raise SystemExit('ERROR: expected exactly 1 match for camera-close anchor line, found ' + str(content.count(old_close)))
content = content.replace(old_close, new_close, 1)

with open(path, 'w') as f:
    f.write(content)
"

# --------------------------------------------------------------------------
# Step 2.5/6: Camera flip-tab
echo "=== Step 2.5/6: Camera flip-tab reset (controller fix) ==="

python3 -c "
path = '$BUILD/events_3.cpp'
with open(path) as f:
    content = f.read()

old_reset = 'if (!(((Active*)get_instance(${FLIPDOWN}_instances))->mouse_over())) goto event_135_3_end;'
new_reset = 'if (!(((Active*)get_instance(${FLIPDOWN}_instances))->mouse_over() || ((Counter*)get_instance(${FLIPIT}_instances))->value == 0)) goto event_135_3_end;'
if content.count(old_reset) != 1:
    raise SystemExit('ERROR: expected exactly 1 match for flip-tab reset anchor line, found ' + str(content.count(old_reset)))
content = content.replace(old_reset, new_reset, 1)

with open(path, 'w') as f:
    f.write(content)
"

# --------------------------------------------------------------------------
# Step 3/6: Mute control
# --------------------------------------------------------------------------
echo "=== Step 3/6: Mute control ==="

sed -i "s/if (!(((Active\*)get_instance(${MUTECALL}_instances))->mouse_over() ${AMP} is_mouse_pressed_once(SDL_BUTTON_LEFT))) goto event_379_3_end;/if (!((((Active*)get_instance(${MUTECALL}_instances))->mouse_over() ${AMP} is_mouse_pressed_once(SDL_BUTTON_LEFT)) || is_key_pressed_once(SDLK_m))) goto event_379_3_end;/" "$BUILD/events_5.cpp"

# --------------------------------------------------------------------------
# Step 4/6: Custom Night start control
# --------------------------------------------------------------------------
echo "=== Step 4/6: Custom Night start control ==="

python3 -c "
path = '$BUILD/events_7.cpp'
with open(path) as f:
    content = f.read()
old1 = 'if (!(((Active*)get_instance(${ACTIVE2}_instances))->mouse_over() && is_mouse_pressed_once(SDL_BUTTON_LEFT))) goto event_2_12_end;'
new1 = 'if (!((((Active*)get_instance(${ACTIVE2}_instances))->mouse_over() && is_mouse_pressed_once(SDL_BUTTON_LEFT)) || is_key_pressed_once(SDLK_RETURN))) goto event_2_12_end;'
content = content.replace(old1, new1, 1)
old2 = 'if (!(((Active*)get_instance(${ACTIVE2}_instances))->mouse_over() && is_mouse_pressed_once(SDL_BUTTON_LEFT))) goto event_3_12_end;'
new2 = 'if (!((((Active*)get_instance(${ACTIVE2}_instances))->mouse_over() && is_mouse_pressed_once(SDL_BUTTON_LEFT)) || is_key_pressed_once(SDLK_RETURN))) goto event_3_12_end;'
content = content.replace(old2, new2, 1)
with open(path, 'w') as f:
    f.write(content)
"

# --------------------------------------------------------------------------
# Step 5/6: Camera directional navigation
# Hook point: handle_frame_4_pre_events() in events_6.cpp.
# --------------------------------------------------------------------------
echo "=== Step 5/6: Camera directional navigation ==="

sed -i 's/void handle_frame_6_events();/void handle_frame_6_events();\n    void handle_camera_nav();/' "$BUILD/events.h"

python3 -c "
path = '$BUILD/events_6.cpp'
with open(path) as f:
    content = f.read()
old = '''    event_func_453();
}'''
new = '''    event_func_453();
    handle_camera_nav();
}'''
content = content.replace(old, new, 1)
with open(path, 'w') as f:
    f.write(content)
"

cat >> "$BUILD/events_6.cpp" << NAVFUNC
void Frames::handle_camera_nav()
{
    // Directional camera navigation. Mirrors the three real effects of a
    // mouse click on a camera thumbnail: the displayed view
    // (setviewingto), the player's tracked position used by animatronic
    // AI overlap checks (you), and the last-clicked marker
    // (lastclicked). Replicating only the display update causes
    // animatronics to appear duplicated across rooms until the monitor is
    // closed and reopened.
    //
    // Adjacency below matches patch_fnaf1_complete.sh exactly (the
    // confirmed-correct, real-playtested version - sourced from the
    // developer's own knowledge of the map, not pixel-coordinate
    // guessing, which was tried twice and proven wrong both times).
    // The earlier version of this function only ever resolved BACKSTAGE
    // among the room objects, so it physically couldn't reference most
    // rooms and used a smaller, incorrect graph instead.
    //
    // BUG FIX (v2 - corrected): must only act while the monitor is
    // actually open. flipit_69 was tried first but is WRONG for this -
    // it's only 1 during the brief flip-open/flip-close ANIMATION window,
    // and drops back to 0 the moment cams are fully open and just sitting
    // there (see events 130_3/133_3/134_3) - gating on it blocked cam-nav
    // for the entire time cams are actually open, causing total dead
    // input. viewing_49 is the correct signal: confirmed via every other
    // event in the game (events 1 through 6) that it is exactly 0 while
    // the monitor is closed and > 0 (the real current room ID) while
    // genuinely open. No remap needed - unlike the old "if (cur == 0)
    // cur = 1" line this replaces, which is what let Up/Down leak through
    // and act on the office (misreading closed-monitor as if it meant
    // "viewing cam 1").
    int cur = (int)((Counter*)get_instance(${VIEWING}_instances))->value;
    if (cur <= 0) return;

    if (cur == 2 && is_key_pressed_once(SDLK_UP)) {
        ((Counter*)get_instance(${SETVIEWINGTO}_instances))->set(1);
        { FrameObject * parent = ((Active*)get_instance(${OBJ1ASHOWSTAGE}_instances)); if (parent != NULL) { ((Active*)get_instance(${YOU}_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
        ((Counter*)get_instance(${LASTCLICKED}_instances))->set(1);
        return;
    }
    if (cur == 2 && is_key_pressed_once(SDLK_LEFT)) {
        ((Counter*)get_instance(${SETVIEWINGTO}_instances))->set(5);
        { FrameObject * parent = ((Active*)get_instance(${BACKSTAGE}_instances)); if (parent != NULL) { ((Active*)get_instance(${YOU}_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
        ((Counter*)get_instance(${LASTCLICKED}_instances))->set(5);
        return;
    }
    if (cur == 2 && is_key_pressed_once(SDLK_DOWN)) {
        ((Counter*)get_instance(${SETVIEWINGTO}_instances))->set(99);
        { FrameObject * parent = ((Active*)get_instance(${OBJ1CSTAGEB}_instances)); if (parent != NULL) { ((Active*)get_instance(${YOU}_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
        ((Counter*)get_instance(${LASTCLICKED}_instances))->set(99);
        return;
    }
    if (cur == 2 && is_key_pressed_once(SDLK_RIGHT)) {
        ((Counter*)get_instance(${SETVIEWINGTO}_instances))->set(7);
        { FrameObject * parent = ((Active*)get_instance(${CAM7BATHROOMS}_instances)); if (parent != NULL) { ((Active*)get_instance(${YOU}_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
        ((Counter*)get_instance(${LASTCLICKED}_instances))->set(7);
        return;
    }
    if (cur == 1 && is_key_pressed_once(SDLK_DOWN)) {
        ((Counter*)get_instance(${SETVIEWINGTO}_instances))->set(2);
        { FrameObject * parent = ((Active*)get_instance(${OBJ1BDININGAREA}_instances)); if (parent != NULL) { ((Active*)get_instance(${YOU}_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
        ((Counter*)get_instance(${LASTCLICKED}_instances))->set(2);
        return;
    }
    if (cur == 1 && is_key_pressed_once(SDLK_RIGHT)) {
        ((Counter*)get_instance(${SETVIEWINGTO}_instances))->set(7);
        { FrameObject * parent = ((Active*)get_instance(${CAM7BATHROOMS}_instances)); if (parent != NULL) { ((Active*)get_instance(${YOU}_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
        ((Counter*)get_instance(${LASTCLICKED}_instances))->set(7);
        return;
    }
    if (cur == 99 && is_key_pressed_once(SDLK_UP)) {
        ((Counter*)get_instance(${SETVIEWINGTO}_instances))->set(2);
        { FrameObject * parent = ((Active*)get_instance(${OBJ1BDININGAREA}_instances)); if (parent != NULL) { ((Active*)get_instance(${YOU}_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
        ((Counter*)get_instance(${LASTCLICKED}_instances))->set(2);
        return;
    }
    if (cur == 99 && is_key_pressed_once(SDLK_LEFT)) {
        ((Counter*)get_instance(${SETVIEWINGTO}_instances))->set(5);
        { FrameObject * parent = ((Active*)get_instance(${BACKSTAGE}_instances)); if (parent != NULL) { ((Active*)get_instance(${YOU}_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
        ((Counter*)get_instance(${LASTCLICKED}_instances))->set(5);
        return;
    }
    if (cur == 99 && is_key_pressed_once(SDLK_DOWN)) {
        ((Counter*)get_instance(${SETVIEWINGTO}_instances))->set(33);
        { FrameObject * parent = ((Active*)get_instance(${CAM3CLOSET}_instances)); if (parent != NULL) { ((Active*)get_instance(${YOU}_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
        ((Counter*)get_instance(${LASTCLICKED}_instances))->set(33);
        return;
    }
    if (cur == 5 && is_key_pressed_once(SDLK_RIGHT)) {
        ((Counter*)get_instance(${SETVIEWINGTO}_instances))->set(2);
        { FrameObject * parent = ((Active*)get_instance(${OBJ1BDININGAREA}_instances)); if (parent != NULL) { ((Active*)get_instance(${YOU}_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
        ((Counter*)get_instance(${LASTCLICKED}_instances))->set(2);
        return;
    }
    if (cur == 5 && is_key_pressed_once(SDLK_DOWN)) {
        ((Counter*)get_instance(${SETVIEWINGTO}_instances))->set(99);
        { FrameObject * parent = ((Active*)get_instance(${OBJ1CSTAGEB}_instances)); if (parent != NULL) { ((Active*)get_instance(${YOU}_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
        ((Counter*)get_instance(${LASTCLICKED}_instances))->set(99);
        return;
    }
    if (cur == 33 && is_key_pressed_once(SDLK_RIGHT)) {
        ((Counter*)get_instance(${SETVIEWINGTO}_instances))->set(3);
        { FrameObject * parent = ((Active*)get_instance(${CAM2A}_instances)); if (parent != NULL) { ((Active*)get_instance(${YOU}_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
        ((Counter*)get_instance(${LASTCLICKED}_instances))->set(3);
        return;
    }
    if (cur == 33 && is_key_pressed_once(SDLK_UP)) {
        ((Counter*)get_instance(${SETVIEWINGTO}_instances))->set(99);
        { FrameObject * parent = ((Active*)get_instance(${OBJ1CSTAGEB}_instances)); if (parent != NULL) { ((Active*)get_instance(${YOU}_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
        ((Counter*)get_instance(${LASTCLICKED}_instances))->set(99);
        return;
    }
    if (cur == 3 && is_key_pressed_once(SDLK_DOWN)) {
        ((Counter*)get_instance(${SETVIEWINGTO}_instances))->set(22);
        { FrameObject * parent = ((Active*)get_instance(${CAM2B}_instances)); if (parent != NULL) { ((Active*)get_instance(${YOU}_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
        ((Counter*)get_instance(${LASTCLICKED}_instances))->set(22);
        return;
    }
    if (cur == 3 && is_key_pressed_once(SDLK_RIGHT)) {
        ((Counter*)get_instance(${SETVIEWINGTO}_instances))->set(4);
        { FrameObject * parent = ((Active*)get_instance(${CAM4A}_instances)); if (parent != NULL) { ((Active*)get_instance(${YOU}_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
        ((Counter*)get_instance(${LASTCLICKED}_instances))->set(4);
        return;
    }
    if (cur == 3 && is_key_pressed_once(SDLK_LEFT)) {
        ((Counter*)get_instance(${SETVIEWINGTO}_instances))->set(33);
        { FrameObject * parent = ((Active*)get_instance(${CAM3CLOSET}_instances)); if (parent != NULL) { ((Active*)get_instance(${YOU}_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
        ((Counter*)get_instance(${LASTCLICKED}_instances))->set(33);
        return;
    }
    if (cur == 3 && is_key_pressed_once(SDLK_UP)) {
        ((Counter*)get_instance(${SETVIEWINGTO}_instances))->set(99);
        { FrameObject * parent = ((Active*)get_instance(${OBJ1CSTAGEB}_instances)); if (parent != NULL) { ((Active*)get_instance(${YOU}_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
        ((Counter*)get_instance(${LASTCLICKED}_instances))->set(99);
        return;
    }
    if (cur == 22 && is_key_pressed_once(SDLK_UP)) {
        ((Counter*)get_instance(${SETVIEWINGTO}_instances))->set(3);
        { FrameObject * parent = ((Active*)get_instance(${CAM2A}_instances)); if (parent != NULL) { ((Active*)get_instance(${YOU}_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
        ((Counter*)get_instance(${LASTCLICKED}_instances))->set(3);
        return;
    }
    if (cur == 22 && is_key_pressed_once(SDLK_RIGHT)) {
        ((Counter*)get_instance(${SETVIEWINGTO}_instances))->set(42);
        { FrameObject * parent = ((Active*)get_instance(${CAM4B}_instances)); if (parent != NULL) { ((Active*)get_instance(${YOU}_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
        ((Counter*)get_instance(${LASTCLICKED}_instances))->set(42);
        return;
    }
    if (cur == 4 && is_key_pressed_once(SDLK_DOWN)) {
        ((Counter*)get_instance(${SETVIEWINGTO}_instances))->set(42);
        { FrameObject * parent = ((Active*)get_instance(${CAM4B}_instances)); if (parent != NULL) { ((Active*)get_instance(${YOU}_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
        ((Counter*)get_instance(${LASTCLICKED}_instances))->set(42);
        return;
    }
    if (cur == 4 && is_key_pressed_once(SDLK_LEFT)) {
        ((Counter*)get_instance(${SETVIEWINGTO}_instances))->set(3);
        { FrameObject * parent = ((Active*)get_instance(${CAM2A}_instances)); if (parent != NULL) { ((Active*)get_instance(${YOU}_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
        ((Counter*)get_instance(${LASTCLICKED}_instances))->set(3);
        return;
    }
    if (cur == 4 && is_key_pressed_once(SDLK_RIGHT)) {
        ((Counter*)get_instance(${SETVIEWINGTO}_instances))->set(6);
        { FrameObject * parent = ((Active*)get_instance(${CAM6KITCHEN}_instances)); if (parent != NULL) { ((Active*)get_instance(${YOU}_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
        ((Counter*)get_instance(${LASTCLICKED}_instances))->set(6);
        return;
    }
    if (cur == 42 && is_key_pressed_once(SDLK_UP)) {
        ((Counter*)get_instance(${SETVIEWINGTO}_instances))->set(4);
        { FrameObject * parent = ((Active*)get_instance(${CAM4A}_instances)); if (parent != NULL) { ((Active*)get_instance(${YOU}_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
        ((Counter*)get_instance(${LASTCLICKED}_instances))->set(4);
        return;
    }
    if (cur == 42 && is_key_pressed_once(SDLK_LEFT)) {
        ((Counter*)get_instance(${SETVIEWINGTO}_instances))->set(22);
        { FrameObject * parent = ((Active*)get_instance(${CAM2B}_instances)); if (parent != NULL) { ((Active*)get_instance(${YOU}_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
        ((Counter*)get_instance(${LASTCLICKED}_instances))->set(22);
        return;
    }
    if (cur == 6 && is_key_pressed_once(SDLK_UP)) {
        ((Counter*)get_instance(${SETVIEWINGTO}_instances))->set(7);
        { FrameObject * parent = ((Active*)get_instance(${CAM7BATHROOMS}_instances)); if (parent != NULL) { ((Active*)get_instance(${YOU}_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
        ((Counter*)get_instance(${LASTCLICKED}_instances))->set(7);
        return;
    }
    if (cur == 6 && is_key_pressed_once(SDLK_LEFT)) {
        ((Counter*)get_instance(${SETVIEWINGTO}_instances))->set(4);
        { FrameObject * parent = ((Active*)get_instance(${CAM4A}_instances)); if (parent != NULL) { ((Active*)get_instance(${YOU}_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
        ((Counter*)get_instance(${LASTCLICKED}_instances))->set(4);
        return;
    }
    if (cur == 7 && is_key_pressed_once(SDLK_LEFT)) {
        ((Counter*)get_instance(${SETVIEWINGTO}_instances))->set(2);
        { FrameObject * parent = ((Active*)get_instance(${OBJ1BDININGAREA}_instances)); if (parent != NULL) { ((Active*)get_instance(${YOU}_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
        ((Counter*)get_instance(${LASTCLICKED}_instances))->set(2);
        return;
    }
    if (cur == 7 && is_key_pressed_once(SDLK_DOWN)) {
        ((Counter*)get_instance(${SETVIEWINGTO}_instances))->set(6);
        { FrameObject * parent = ((Active*)get_instance(${CAM6KITCHEN}_instances)); if (parent != NULL) { ((Active*)get_instance(${YOU}_instances))->set_global_position(parent->get_x() + 0, parent->get_y() + 0); } }
        ((Counter*)get_instance(${LASTCLICKED}_instances))->set(6);
        return;
    }
}
NAVFUNC

# --------------------------------------------------------------------------
# Step 6/6: Custom Night difficulty controls
# Hook point: handle_frame_13_pre_events() in events_7.cpp.
# --------------------------------------------------------------------------
echo "=== Step 6/6: Custom Night difficulty controls ==="

sed -i 's/void handle_camera_nav();/void handle_camera_nav();\n    void handle_custom_night_nav();/' "$BUILD/events.h"

python3 -c "
path = '$BUILD/events_7.cpp'
with open(path) as f:
    content = f.read()
old = '''    event_func_554();
}'''
new = '''    event_func_554();
    handle_custom_night_nav();
}'''
content = content.replace(old, new, 1)
with open(path, 'w') as f:
    f.write(content)
"

cat >> "$BUILD/events_7.cpp" << CUSTOMNIGHTFUNC
void Frames::handle_custom_night_nav()
{
    // Custom Night difficulty adjustment. Up/Down selects the active
    // animatronic, Left/Right adjusts its value - same bounds and
    // underlying counters as the original mouse-driven controls.
    static int selected = 0;

    if (is_key_pressed_once(SDLK_UP)) {
        selected = (selected + 3) % 4;
    }
    if (is_key_pressed_once(SDLK_DOWN)) {
        selected = (selected + 1) % 4;
    }

    Counter * c = NULL;
    switch (selected) {
        case 0: c = (Counter*)get_instance(${FREDDYAI}_instances); break;
        case 1: c = (Counter*)get_instance(${BONIEAI}_instances); break;
        case 2: c = (Counter*)get_instance(${CHICAAI}_instances); break;
        default: c = (Counter*)get_instance(${FOXYAI}_instances); break;
    }
    if (c == NULL) return;

    if (is_key_pressed_once(SDLK_RIGHT)) {
        if (c->value < 20) c->add(1);
    }
    if (is_key_pressed_once(SDLK_LEFT)) {
        if (c->value > 0) c->subtract(1);
    }
}
CUSTOMNIGHTFUNC

echo "=== Patching complete ==="
