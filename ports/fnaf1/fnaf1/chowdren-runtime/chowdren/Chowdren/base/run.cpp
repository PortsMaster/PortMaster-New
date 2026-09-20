#include <stdlib.h>

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <fcntl.h>
#include <io.h>
#include <windows.h>
#endif

#include "manager.h"
#include "fpslimit.h"

GameManager manager;

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "chowconfig.h"
#include "framedata.h"
#include "common.h"
#include "fonts.h"
#include "crossrand.h"
#include "media.h"
#include "crashdump.cpp"
#include "transition.cpp"

// Single real definition of cross_seed (declared extern in crossrand.h).
// This must exist in exactly one translation unit - run.cpp is the natural
// home since it's the file that actually seeds it via cross_srand().
unsigned int cross_seed = 0;

// Forward declaration for game-specific WASD camera nav, implemented in
// generated code (events_6.cpp). Called directly from the main frame
// update loop below instead of from within the Fusion event graph's own
// call chain - the event-graph injection point was confirmed (via direct
// debug-print instrumentation) to never actually execute during real
// gameplay despite being placed on a provably-reached, unconditional,
// branch-free call path. Root cause undetermined; hooking here instead
// sidesteps whatever event-graph-specific mechanism was preventing it.

#if defined(CHOWDREN_IS_DESKTOP)
#include "SDL.h"
#endif

#ifdef CHOWDREN_IS_EMSCRIPTEN
#include <emscripten/emscripten.h>
#endif

// #define CHOWDREN_USER_PROFILER

#if !defined(NDEBUG)
#define CHOWDREN_SHOW_DEBUGGER
#define SHOW_STATS
#endif

GameManager::GameManager()
: frame(NULL), window_created(false), fullscreen(false), off_x(0), off_y(0),
  x_size(WINDOW_WIDTH), y_size(WINDOW_HEIGHT), values(NULL), strings(NULL),
  fade_value(0.0f), fade_dir(0.0f), lives(0), ignore_controls(false),
  player_press_flags(0), player_flags(0), joystick_press_flags(0),
  joystick_release_flags(0), joystick_flags(0), player_died(true)
{
}

static Frames static_frames;

#ifdef CHOWDREN_USER_PROFILER
static FSFile user_log;
#endif

void GameManager::init()
{
#ifdef CHOWDREN_USER_PROFILER
    user_log.open("log.txt", "w");
#endif

#ifdef CHOWDREN_USE_PROFILER
    PROFILE_SET_DAMPING(0.0);
#endif
    frame = &static_frames;

#ifdef CHOWDREN_IS_DEMO
    idle_timer_started = false;
    global_time = show_build_timer = reset_timer = manual_reset_timer = 0.0;
#endif

#ifdef CHOWDREN_USE_JOYTOKEY
    simulate_count = 0;
    axis_moved = false;
    last_axis = -1;
    deadzone = 0.4f;
    pad_selected = false;
    pad_disconnected = false;
    for (int i = 0; i < CHOWDREN_BUTTON_MAX-1; i++)
        key_mappings[i] = -1;
    for (int i = 0; i < CHOWDREN_AXIS_MAX-1; i++) {
        axis_pos_mappings[i] = -1;
        axis_neg_mappings[i] = -1;
        axis_values[i] = 0;
    }
#endif
    platform_init();
    media.init();
    set_window(false);

    // application setup
    preload_images();
    reset_globals();
    setup_keys(this);

    // setup random generator from start
    unsigned int rng_seed = (unsigned int)platform_get_global_time() ^ (unsigned int)getpid();
    FILE* urandom = fopen("/dev/urandom", "rb");
    if (urandom) { fread(&rng_seed, sizeof(rng_seed), 1, urandom); fclose(urandom); }
    cross_srand(rng_seed);

    fps_limit.start();
    set_framerate(FRAMERATE);

    int start_frame = 0;
#if defined(CHOWDREN_IS_AVGN)
    start_frame = 0;
#elif defined(CHOWDREN_IS_HFA)
    start_frame = 0;
#elif defined(CHOWDREN_IS_FP)
    player_died = false;
    lives = 3;
    // start_frame = 56;
    // values->set(1, 2);
    // values->set(12, 2);
#elif defined(CHOWDREN_IS_NAH)
    platform_set_scale_type(2);
    // start_frame = 8;
#else
    start_frame = 0;
#endif

#ifdef NDEBUG
    set_frame(0);
#else
    set_frame(start_frame);
#endif
}

void GameManager::reset_globals()
{
    delete values;
    delete strings;
    values = frame->global_values = new GlobalValues;
    strings = frame->global_strings = new GlobalStrings;
    setup_globals(values, strings);
}

void GameManager::set_window(bool fullscreen)
{
    if (window_created) {
        if (fullscreen == this->fullscreen)
            return;
        this->fullscreen = fullscreen;
        platform_set_fullscreen(fullscreen);
        return;
    }
    this->fullscreen = fullscreen;
    window_created = true;

    platform_create_display(fullscreen);

    // OpenGL init
    Render::init();

#ifdef CHOWDREN_VSYNC
    platform_set_vsync(true);
#else
    platform_set_vsync(false);
#endif
}

void GameManager::set_window_scale(int scale)
{
#ifdef CHOWDREN_IS_DESKTOP
    platform_set_display_scale(scale);
#endif
}

void GameManager::set_scale_type(int type)
{
#ifdef CHOWDREN_IS_DESKTOP
    platform_set_scale_type(type);
#endif
}

bool GameManager::is_fullscreen()
{
    return fullscreen;
}

void GameManager::on_key(int key, bool state)
{
#ifdef CHOWDREN_IS_DEMO
    idle_timer_started = true;
    idle_timer = 0.0;
#endif

    if (state)
        keyboard.add(key);
    else
        keyboard.remove(key);

    if (state)
        frame->last_key = key;
}

void GameManager::on_mouse(int key, bool state)
{
    if (state)
        mouse.add(key);
    else
        mouse.remove(key);
}

int GameManager::update_frame()
{
#ifdef CHOWDREN_USE_PROFILER
    PROFILE_FUNC();
#endif
    double dt = fps_limit.dt;

// #ifdef SHOW_STATS
//     if (dt > (1.2 / fps_limit.framerate)) {
//         std::cout << "Bad frame: " << dt << " " << (1.0 / dt) << std::endl;
//         std::cout << last_events << " " << last_draw << std::endl;
//     }
// #endif

    if (fade_dir != 0.0f) {
        fade_value += fade_dir * (float)dt;
        if (fade_value <= 0.0f || fade_value >= 1.0f) {
            fade_dir = 0.0f;
            fade_value = std::min(1.0f, std::max(0.0f, fade_value));
            return 2;
        }
        return 1;
    }

    if (frame->next_frame != -1 && fade_dir == 0.0f) {
        // platform layer may want to force a swap if double-buffered, etc.
        platform_prepare_frame_change();
        set_frame(frame->next_frame);
    }

    this->dt = float(dt);

#ifdef CHOWDREN_IS_DEMO
    global_time += dt;
    if (idle_timer_started) {
        idle_timer += dt;
        reset_timer += dt;
    }
    if (platform_should_reset())
        manual_reset_timer += dt;
    else
        manual_reset_timer = 0.0;
    if (idle_timer >= 60 || manual_reset_timer >= 3.0) {
        set_frame(-2);
    }
    if (reset_timer >= 60*10) {
        reset_timer = -10.0;
        media.stop_samples();
        set_frame(5);
    }
    if (global_time <= 60) {
        show_build_timer -= dt;
        if (platform_show_build_info())
            show_build_timer = 3.0;
    }
#endif
    bool ret = frame->update();
    if (ret)
        return 1;
    return 0;
}

void GameManager::set_framerate(int framerate)
{
    fps_limit.set(framerate);
#ifdef CHOWDREN_VSYNC
    static bool vsync_temp = false;
    if (framerate < 100) {
        if (!vsync_temp)
            return;
        platform_set_vsync(true);
        vsync_temp = false;
        return;
    }
    vsync_temp = true;
    platform_set_vsync(false);
#endif
}

#ifdef CHOWDREN_IS_DEMO
#include "font.h"
FTTextureFont * get_font(int size);
#endif

void GameManager::draw()
{
    int window_width, window_height;
    platform_get_size(&window_width, &window_height);
    if (window_width <= 0 || window_height <= 0)
        // for some reason, GLFW sets these properties to 0 when minimized.
        return;

#ifdef CHOWDREN_FORCE_REMOTE
    platform_set_remote_value(CHOWDREN_REMOTE_TARGET);
#endif

    PROFILE_FUNC();

    PROFILE_BEGIN(platform_begin_draw);
    platform_begin_draw();
    PROFILE_END();

#ifdef CHOWDREN_USE_SUBAPP
    Frame * render_frame;
    if (SubApplication::current != NULL &&
        SubApplication::current->flags & VISIBLE) {
        render_frame = &SubApplication::current->subapp_frame;
    } else
        render_frame = frame;
#else
    Frame * render_frame = frame;
#endif

    PROFILE_BEGIN(frame_draw);
#ifdef CHOWDREN_IS_WIIU
    int remote_setting = platform_get_remote_value();
    if (remote_setting == CHOWDREN_HYBRID_TARGET) {
        platform_set_display_target(CHOWDREN_REMOTE_TARGET);
        render_frame->draw(CHOWDREN_REMOTE_TARGET);
        draw_fade();
        platform_set_display_target(CHOWDREN_TV_TARGET);
        render_frame->draw(CHOWDREN_TV_TARGET);
        draw_fade();
    } else {
        platform_set_display_target(CHOWDREN_TV_TARGET);
        render_frame->draw(CHOWDREN_HYBRID_TARGET);
        draw_fade();
        if (remote_setting == CHOWDREN_REMOTE_TARGET) {
            platform_clone_buffers();
            platform_set_display_target(CHOWDREN_REMOTE_TARGET);
            render_frame->draw(CHOWDREN_REMOTE_ONLY);
        }
    }
#elif CHOWDREN_IS_3DS
    platform_set_display_target(CHOWDREN_TV_TARGET);
    render_frame->draw(CHOWDREN_TV_TARGET);
    draw_fade();

    // only draw 30 fps on bottom screen
    static int draw_interval = 0;
    if (draw_interval == 0) {
        platform_set_display_target(CHOWDREN_REMOTE_TARGET);
        render_frame->draw(CHOWDREN_REMOTE_TARGET);
        draw_fade();
    }
    draw_interval = (draw_interval + 1) % 3;
#else
    render_frame->draw(CHOWDREN_HYBRID_TARGET);
    draw_fade();
#endif
    PROFILE_END();

    Render::set_offset(0, 0);

#ifdef CHOWDREN_IS_DEMO
    if (show_build_timer > 0.0) {
        std::string date(__DATE__);
        std::string tim(__TIME__);
        std::string val = date + " " + tim;
        glPushMatrix();
        glTranslatef(50, 50, 0);
        glScalef(5, -5, 5);
        glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
        get_font(24)->Render(val.c_str(), val.size(), FTPoint(),
                             FTPoint());
        glPopMatrix();
    }
#endif

    PROFILE_BEGIN(platform_swap_buffers);
    platform_swap_buffers();
    PROFILE_END();
}

void GameManager::draw_fade()
{
    if (fade_dir == 0.0f)
        return;
    Render::set_offset(0, 0);
    Transition::draw();
}

void GameManager::set_frame(int index)
{
    ignore_controls = false;

#ifdef CHOWDREN_IS_DEMO
    idle_timer = 0.0;
    idle_timer_started = false;
#endif

#ifndef CHOWDREN_SAMPLES_OVER_FRAMES
    media.stop_samples();
#endif

    if (frame->index != -1) {
        frame->on_end();
        flush_image_cache();
    }

    if (index == -2) {
        platform_begin_draw();
        media.stop_samples();
        Render::clear(Color(0, 0, 0, 255));
        platform_swap_buffers();
#ifdef CHOWDREN_IS_DEMO
        reset_timer = 0.0;
#endif
        index = 0;
        // reset_global_data();
        reset_globals();
    }

    std::cout << "Setting frame: " << index << std::endl;

#ifdef CHOWDREN_USER_PROFILER
    std::string logline = "Setting frame: " + number_to_string(index) + "\n";
    user_log.write(&logline[0], logline.size());
#endif

    frame->set_index(index);

    std::cout << "Frame set" << std::endl;
}

void GameManager::set_fade(Transition::Type type, const Color & color,
                           float dir)
{
    fade_type = type;
    fade_color = color;
    fade_dir = dir;
    if (fade_dir < 0.0f)
        fade_value = 1.0f;
    else
        fade_value = 0.0f;
}

static int get_player_control_flags(int player);
static int get_joystick_control_flags(int player);

#ifndef NDEBUG
struct InstanceCount
{
    int id;
    int count;
};

static bool sort_count(const InstanceCount & a, const InstanceCount & b)
{
    return a.count > b.count;
}

static InstanceCount counts[MAX_OBJECT_ID];

static void print_instance_stats()
{
    return;
    int count = 0;
    for (int i = 0; i < MAX_OBJECT_ID; i++) {
        int instance_count = manager.frame->instances.items[i].size();
        count += instance_count;
        counts[i].id = i;
        counts[i].count = instance_count;
    }
    std::cout << "Instance count: " << count << std::endl;

    std::sort(counts, counts + MAX_OBJECT_ID, sort_count);
    for (int i = 0; i < std::min<int>(5, MAX_OBJECT_ID); i++) {
        std::cout << counts[i].id << " has " << counts[i].count
            << " instances" << std::endl;
    }
}
#endif

#ifdef CHOWDREN_USE_JOYTOKEY

void GameManager::set_deadzone(float value)
{
    deadzone = value;
}

void GameManager::simulate_key(const std::string & key)
{
    int key_int = -1;
    if (!key.empty())
        key_int = translate_string_to_key(key);
    simulate_key(key_int);
}

void GameManager::simulate_key(int key_int)
{
    if (simulate_count >= InputList::STATE_COUNT)
        return;
    if (key_int == -1)
        return;
    for (int i = 0; i < simulate_count; i++) {
        if (simulate_keys[i].key != key_int)
            continue;
        simulate_keys[i].down = true;
        return;
    }

    simulate_keys[simulate_count].key = key_int;
    simulate_keys[simulate_count].down = true;
    keyboard.add(key_int);
    simulate_count++;
}

void GameManager::map_button(int button, const std::string & key)
{
    if (button >= UNIFIED_AXIS_0 && button < UNIFIED_POV_0) {
        button = button - UNIFIED_AXIS_0;
        int axis = button / 2;
        int is_neg = button - axis * 2;
        axis++;
        if (axis == CHOWDREN_AXIS_INVALID || axis >= CHOWDREN_AXIS_MAX)
            return;
        int old_key;
        int key_int = -1;
        if (!key.empty())
            key_int = translate_string_to_key(key);
        if (is_neg) {
            old_key = axis_neg_mappings[axis-1];
            axis_neg_mappings[axis-1] = key_int;
        } else {
            old_key = axis_pos_mappings[axis-1];
            axis_pos_mappings[axis-1] = key_int;
        }
        if (old_key != -1 && old_key != key_int)
            keyboard.remove(old_key);
        return;
    }
    button++;
    if (button == CHOWDREN_BUTTON_INVALID || button >= CHOWDREN_BUTTON_MAX)
        return;
    int key_int = -1;
    if (!key.empty())
        key_int = translate_string_to_key(key);
    int old_key = key_mappings[button-1];
    if (old_key != -1 && old_key != key_int)
        keyboard.remove(old_key);
    key_mappings[button-1] = key_int;
}

void GameManager::map_axis(int axis,
                           const std::string & neg,
                           const std::string & pos)
{
    axis++;
    if (axis == CHOWDREN_AXIS_INVALID || axis >= CHOWDREN_AXIS_MAX)
        return;
    int old_key;
    int key = -1;
    if (!neg.empty())
        key = translate_string_to_key(neg);
    old_key = axis_neg_mappings[axis-1];
    if (old_key != -1 && old_key != key)
        keyboard.remove(old_key);
    axis_neg_mappings[axis-1] = key;
    key = -1;
    if (!pos.empty())
        key = translate_string_to_key(pos);
    old_key = axis_pos_mappings[axis-1];
    if (old_key != -1 && old_key != key)
        keyboard.remove(old_key);
    axis_pos_mappings[axis-1] = key;
}

void GameManager::reset_map()
{
    for (int i = 0; i < CHOWDREN_BUTTON_MAX-1; i++) {
        int old_key = key_mappings[i];
        if (old_key != -1)
            keyboard.remove(old_key);
        key_mappings[i] = -1;
    }
    for (int i = 0; i < CHOWDREN_AXIS_MAX-1; i++) {
        int old_key = axis_pos_mappings[i];
        if (old_key != -1)
            keyboard.remove(old_key);
        axis_pos_mappings[i] = -1;
        old_key = axis_neg_mappings[i];
        if (old_key != -1)
            keyboard.remove(old_key);
        axis_neg_mappings[i] = -1;
        axis_values[i] = 0;
    }
}

#endif

bool GameManager::update()
{
#ifdef SHOW_STATS
    bool show_stats = false;
    static int measure_time = 0;
    measure_time -= 1;
    if (measure_time <= 0) {
        measure_time = 200;
        show_stats = true;
    }
#endif

#ifdef CHOWDREN_USER_PROFILER
    static int frame = 0;
    frame++;
    std::stringstream ss;
    ss << "Frame " << frame << ": " << fps_limit.dt << " ";
#endif

    // update input
    keyboard.update();
    mouse.update();

    platform_poll_events();

    // player controls
    int new_control = get_player_control_flags(1);
    player_press_flags = new_control & ~(player_flags);
    player_flags = new_control;

    // joystick controls
    new_control = get_joystick_control_flags(1);
    joystick_press_flags = new_control & ~(joystick_flags);
    joystick_release_flags = joystick_flags & ~(new_control);
    joystick_flags = new_control;

#ifdef CHOWDREN_USE_JOYTOKEY
    for (int i = 0; i < simulate_count; i++) {
        if (simulate_keys[i].down) {
            simulate_keys[i].down = false;
            continue;
        }
        keyboard.remove(simulate_keys[i].key);
        simulate_keys[i] = simulate_keys[simulate_count-1];
        i--;
        simulate_count--;
    }

    for (int i = 0; i < CHOWDREN_BUTTON_MAX-1; i++) {
        int key = key_mappings[i];
        if (key == -1)
            continue;
        if (is_joystick_pressed_once(1, i+1))
            keyboard.add(key);
        else if (is_joystick_released_once(1, i+1))
            keyboard.remove(key);
    }
    axis_moved = false;
    for (int i = 0; i < CHOWDREN_AXIS_MAX-1; i++) {
        float value = get_joystick_axis(1, i+1);
        int pos = axis_pos_mappings[i];
        int neg = axis_neg_mappings[i];

        int axis_value = 0;
        if (value > deadzone) {
            last_axis = i;
            if (pos != -1 && axis_values[i] != 1)
                keyboard.add(pos);
            axis_value = 1;
        } else {
            if (pos != -1 && axis_values[i] == 1)
                keyboard.remove(pos);
        }

        if (value < -deadzone) {
            last_axis = i;
            if (neg != -1 && axis_values[i] != -1)
                keyboard.add(neg);
            axis_value = -1;
        } else {
            if (neg != -1 && axis_values[i] == -1)
                keyboard.remove(neg);
        }

        axis_values[i] = axis_value;

        static bool last_move = false;
        bool new_move = axis_value != 0;
        if (new_move && new_move != last_move)
            axis_moved = true;

        last_move = new_move;
    }

    static bool last_connected = false;
    bool connected = is_joystick_attached(1);
    pad_selected = connected && last_connected != connected;
    pad_disconnected = !connected && last_connected != connected;
    last_connected = connected;
#endif

    // update mouse position
    platform_get_mouse_pos(&mouse_x, &mouse_y);

#ifdef SHOW_STATS
    if (show_stats)
        std::cout << "Framerate: " << fps_limit.current_framerate
            << std::endl;
#endif

    if (platform_has_error()) {
        if (platform_display_closed())
            return false;
    } else {
        double event_update_time = platform_get_time();

        int ret = update_frame();

#ifdef CHOWDREN_USER_PROFILER
        ss << (platform_get_time() - event_update_time) << " ";
#endif
#ifdef SHOW_STATS
        if (show_stats)
            std::cout << "Event update took " <<
                platform_get_time() - event_update_time << std::endl;
#endif

        if (ret == 0)
            return false;
        else if (ret == 2)
            return true;

        if (platform_display_closed())
            return false;
    }

    double draw_time = platform_get_time();

    draw();

#ifdef CHOWDREN_USER_PROFILER
    ss << (platform_get_time() - draw_time) << " ";
#endif

#ifdef SHOW_STATS
    if (show_stats) {
        std::cout << "Draw took " << platform_get_time() - draw_time
            << std::endl;
#ifndef NDEBUG
        print_instance_stats();
#endif
        platform_print_stats();
    }
#endif

    fps_limit.finish();

#ifdef CHOWDREN_USER_PROFILER
    ss << "\n";
    std::string logline = ss.str();
    user_log.write(&logline[0], logline.size());
#endif

#ifdef CHOWDREN_USE_PROFILER
    static int profile_time = 0;
    profile_time -= 1;
    if (profile_time <= 0) {
        profile_time += 500;
        PROFILE_UPDATE();
        PROFILE_OUTPUT("data:/profile.txt");
    }
#endif

    return true;
}

#ifdef CHOWDREN_IS_EMSCRIPTEN
static void _emscripten_run()
{
    manager.update();
}
#endif

void GameManager::run()
{
    init();

#ifdef CHOWDREN_IS_EMSCRIPTEN
    emscripten_set_main_loop(_emscripten_run, 0, 1);
#else
    while (true) {
        if (!update())
            break;
    }
    frame->data->on_app_end();
    frame->data->on_end();
    media.stop();
    platform_exit();
#endif
}

// InputList

InputList::InputList()
: last(-1), count(0)
{
}

void InputList::add(int v)
{
    last = v;

    for (int i = 0; i < count; i++) {
        InputState & s = states[i];
        if (s.key != v)
            continue;
        s.state = STATE_PRESSED;
        return;
    }
    if (count >= STATE_COUNT)
        return;
    states[count].key = v;
    states[count].state = STATE_PRESSED;
    count++;
}

void InputList::remove(int v)
{
    for (int i = 0; i < count; i++) {
        InputState & s = states[i];
        if (s.key != v)
            continue;
        s.state = STATE_RELEASED;
        return;
    }
}

bool InputList::is_pressed(int v)
{
    for (int i = 0; i < count; i++) {
        const InputState & s = states[i];
        if (s.key != v)
            continue;
        return s.state != STATE_RELEASED;
    }
    return false;
}

bool InputList::is_pressed_once(int v)
{
    for (int i = 0; i < count; i++) {
        const InputState & s = states[i];
        if (s.key != v)
            continue;
        return s.state == STATE_PRESSED;
    }
    return false;
}

bool InputList::is_any_pressed()
{
    for (int i = 0; i < count; i++) {
        const InputState & s = states[i];
        if (s.state == STATE_RELEASED)
            continue;
        return true;
    }
    return false;
}

bool InputList::is_any_pressed_once()
{
    for (int i = 0; i < count; i++) {
        const InputState & s = states[i];
        if (s.state != STATE_PRESSED)
            continue;
        return true;
    }
    return false;
}

bool InputList::is_released_once(int v)
{
    for (int i = 0; i < count; i++) {
        const InputState & s = states[i];
        if (s.key != v)
            continue;
        return s.state == STATE_RELEASED;
    }
    return false;
}

void InputList::clear()
{
    count = 0;
}

void InputList::update()
{
    for (int i = 0; i < count; i++) {
        InputState & s = states[i];
        if (s.state != STATE_RELEASED) {
            s.state = STATE_HOLD;
            continue;
        }
        states[i] = states[count-1];
        count--;
        i--;
    }
}

// input helpers

bool is_mouse_pressed(int button)
{
    if (button < 0)
        return false;
    return manager.mouse.is_pressed(button);
}

bool is_key_pressed(int button)
{
    if (button < 0)
        return false;
    if (button == SDLK_UP && manager.keyboard.is_pressed(SDLK_w)) return true;
    if (button == SDLK_DOWN && manager.keyboard.is_pressed(SDLK_s)) return true;
    return manager.keyboard.is_pressed(button);
}

bool is_any_key_pressed()
{
    return manager.keyboard.is_any_pressed();
}

bool is_any_key_pressed_once()
{
    return manager.keyboard.is_any_pressed_once();
}

bool is_mouse_pressed_once(int key)
{
    if (key < 0)
        return false;
    return manager.mouse.is_pressed_once(key);
}

bool is_key_released_once(int key)
{
    if (key < 0)
        return false;
    return manager.keyboard.is_released_once(key);
}

bool is_key_pressed_once(int key)
{
    if (key < 0)
        return false;
    if (key == SDLK_UP && manager.keyboard.is_pressed_once(SDLK_w)) return true;
    if (key == SDLK_DOWN && manager.keyboard.is_pressed_once(SDLK_s)) return true;
    return manager.keyboard.is_pressed_once(key);
}

int get_last_key_pressed()
{
    return manager.keyboard.last;
}

enum {
    JOYSTICK_BUTTON1 = CHOWDREN_BUTTON_A,
    JOYSTICK_BUTTON2 = CHOWDREN_BUTTON_B,
    JOYSTICK_BUTTON3 = CHOWDREN_BUTTON_X,
    JOYSTICK_BUTTON4 = CHOWDREN_BUTTON_Y,
};

static int get_player_control_flags(int player)
{
    GameManager & m = manager;
    if (m.ignore_controls)
        return 0;

    int flags = 0;

    if (m.control_type == CONTROL_KEYBOARD) {
        if (is_key_pressed(m.up))
            flags |= CONTROL_UP;
        if (is_key_pressed(m.down))
            flags |= CONTROL_DOWN;
        if (is_key_pressed(m.left))
            flags |= CONTROL_LEFT;
        if (is_key_pressed(m.right))
            flags |= CONTROL_RIGHT;
        if (is_key_pressed(m.button1))
            flags |= CONTROL_BUTTON1;
        if (is_key_pressed(m.button2))
            flags |= CONTROL_BUTTON2;
        if (is_key_pressed(m.button3))
            flags |= CONTROL_BUTTON3;
        if (is_key_pressed(m.button4))
            flags |= CONTROL_BUTTON4;
    } else {
        flags |= get_joystick_direction_flags(player);
        if (is_joystick_pressed(player, JOYSTICK_BUTTON1))
            flags |= CONTROL_BUTTON1;
        if (is_joystick_pressed(player, JOYSTICK_BUTTON2))
            flags |= CONTROL_BUTTON2;
        if (is_joystick_pressed(player, JOYSTICK_BUTTON3))
            flags |= CONTROL_BUTTON3;
        if (is_joystick_pressed(player, JOYSTICK_BUTTON4))
            flags |= CONTROL_BUTTON4;
    }
    return flags;
}

inline int get_joystick_flag(int n, int button)
{
    if (!is_joystick_pressed(n, button))
        return 0;
    return 8 << button;
}

static int get_joystick_control_flags(int n)
{
    int flags = 0;
    flags |= get_joystick_direction_flags(n);
    flags |= get_joystick_flag(n, CHOWDREN_BUTTON_A);
    flags |= get_joystick_flag(n, CHOWDREN_BUTTON_B);
    flags |= get_joystick_flag(n, CHOWDREN_BUTTON_X);
    flags |= get_joystick_flag(n, CHOWDREN_BUTTON_Y);
    flags |= get_joystick_flag(n, CHOWDREN_BUTTON_BACK);
    flags |= get_joystick_flag(n, CHOWDREN_BUTTON_GUIDE);
    flags |= get_joystick_flag(n, CHOWDREN_BUTTON_START);
    flags |= get_joystick_flag(n, CHOWDREN_BUTTON_LEFTSTICK);
    flags |= get_joystick_flag(n, CHOWDREN_BUTTON_RIGHTSTICK);
    flags |= get_joystick_flag(n, CHOWDREN_BUTTON_LEFTSHOULDER);
    flags |= get_joystick_flag(n, CHOWDREN_BUTTON_RIGHTSHOULDER);
    flags |= get_joystick_flag(n, CHOWDREN_BUTTON_DPAD_UP);
    flags |= get_joystick_flag(n, CHOWDREN_BUTTON_DPAD_DOWN);
    flags |= get_joystick_flag(n, CHOWDREN_BUTTON_DPAD_LEFT);
    flags |= get_joystick_flag(n, CHOWDREN_BUTTON_DPAD_RIGHT);

#ifdef CHOWDREN_IS_DESKTOP
    // extra joystick flags
    for (int i = 0; i < 8; i++) {
        flags |= get_joystick_flag(n, CHOWDREN_BUTTON_DPAD_RIGHT+1+i);
    }
#endif
    return flags;
}

static float prev_trigger_left = 0.0f;
static float prev_trigger_right = 0.0f;

bool is_trigger_pressed_once(int side)
{
    float value = get_joystick_axis(1, side == 0 ? CHOWDREN_AXIS_TRIGGERLEFT : CHOWDREN_AXIS_TRIGGERRIGHT);
    float * prev = (side == 0) ? &prev_trigger_left : &prev_trigger_right;
    const float threshold = 0.5f;
    bool now_pressed = value > threshold;
    bool was_pressed = *prev > threshold;
    *prev = value;
}

bool is_joystick_pressed_once(int n, int button)
{
    static int last_flags = -1;
    if (manager.joystick_press_flags != last_flags) {
        std::cout << "[DEBUG] joystick_press_flags changed to " << manager.joystick_press_flags << std::endl;
        last_flags = manager.joystick_press_flags;
    }
    if (n != 1)
        return false;
    int flags = 8 << button;
    return (manager.joystick_press_flags & flags) != 0;
}

bool is_joystick_released_once(int n, int button)
{
    if (n != 1)
        return false;
    int flags = 8 << button;
    return (manager.joystick_release_flags & flags) != 0;
}

bool any_joystick_pressed_once(int n)
{
    if (n != 1)
        return false;
    return (manager.joystick_press_flags >> 4) != 0;
}

bool is_player_pressed(int player, int flags)
{
    if (manager.ignore_controls)
        return false;
    if (flags == 0)
        return manager.player_flags == 0;
    return (manager.player_flags & flags) == flags;
}

bool is_player_pressed_once(int player, int flags)
{
    if (manager.ignore_controls)
        return false;
    if (flags == 0)
        return manager.player_press_flags == 0;
    return (manager.player_press_flags & flags) == flags;
}

// main function

#ifdef _WIN32
static void open_console()
{
#ifndef CHOWDREN_SHOW_DEBUGGER
    if (getenv("CHOWDREN_SHOW_DEBUGGER") == NULL)
        return;
#endif

    int outHandle, errHandle, inHandle;
    FILE *outFile, *errFile, *inFile;
    AllocConsole();
    CONSOLE_SCREEN_BUFFER_INFO coninfo;
    GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &coninfo);

    outHandle = _open_osfhandle((intptr_t)GetStdHandle(STD_OUTPUT_HANDLE),
                                _O_TEXT);
    errHandle = _open_osfhandle((intptr_t)GetStdHandle(STD_ERROR_HANDLE),
                                _O_TEXT);
    inHandle = _open_osfhandle((intptr_t)GetStdHandle(STD_INPUT_HANDLE),
                               _O_TEXT);

    outFile = _fdopen(outHandle, "w" );
    errFile = _fdopen(errHandle, "w");
    inFile =  _fdopen(inHandle, "r");

    *stdout = *outFile;
    *stderr = *errFile;
    *stdin = *inFile;

    setvbuf(stdout, NULL, _IONBF, 0);
    setvbuf(stderr, NULL, _IONBF, 0);
    setvbuf(stdin, NULL, _IONBF, 0);

    std::ios::sync_with_stdio();
}
#endif

int main(int argc, char *argv[])
{
    install_crash_handler();

#ifdef _WIN32
    open_console();
#endif

    manager.run();
    return 0;
}
