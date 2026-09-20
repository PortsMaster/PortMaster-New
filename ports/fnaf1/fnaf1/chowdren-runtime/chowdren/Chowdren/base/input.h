#ifndef CHOWDREN_INPUT_H
#define CHOWDREN_INPUT_H

#include "types.h"

#define UNIFIED_POV_SIZE 4
#define UNIFIED_BUTTON_MAX (128)
#define UNIFIED_AXIS_SIZE 2
#define UNIFIED_AXIS_MAX (UNIFIED_AXIS_SIZE * 8) //16
#define UNIFIED_AXIS_0 UNIFIED_BUTTON_MAX
#define UNIFIED_POV_0 (UNIFIED_AXIS_0 + UNIFIED_AXIS_MAX)

enum {
    CHOWDREN_BUTTON_INVALID = 0,
    CHOWDREN_BUTTON_A,
    CHOWDREN_BUTTON_B,
    CHOWDREN_BUTTON_X,
    CHOWDREN_BUTTON_Y,
    CHOWDREN_BUTTON_BACK,
    CHOWDREN_BUTTON_GUIDE,
    CHOWDREN_BUTTON_START,
    CHOWDREN_BUTTON_LEFTSTICK,
    CHOWDREN_BUTTON_RIGHTSTICK,
    CHOWDREN_BUTTON_LEFTSHOULDER,
    CHOWDREN_BUTTON_RIGHTSHOULDER,
    CHOWDREN_BUTTON_DPAD_UP,
    CHOWDREN_BUTTON_DPAD_DOWN,
    CHOWDREN_BUTTON_DPAD_LEFT,
    CHOWDREN_BUTTON_DPAD_RIGHT,
    CHOWDREN_BUTTON_MAX
};

enum {
    CHOWDREN_AXIS_INVALID = 0,
    CHOWDREN_AXIS_LEFTX,
    CHOWDREN_AXIS_LEFTY,
    CHOWDREN_AXIS_RIGHTX,
    CHOWDREN_AXIS_RIGHTY,
    CHOWDREN_AXIS_TRIGGERLEFT,
    CHOWDREN_AXIS_TRIGGERRIGHT,
    CHOWDREN_AXIS_MAX
};

enum {
    CONTROL_KEYBOARD = 0,
    CONTROL_JOYSTICK1,
    CONTROL_JOYSTICK2,
    CONTROL_JOYSTICK3,
    CONTROL_JOYSTICK4
};

enum {
    CONTROL_UP = 1 << 0,
    CONTROL_DOWN = 1 << 1,
    CONTROL_LEFT = 1 << 2,
    CONTROL_RIGHT = 1 << 3,
    CONTROL_BUTTON1 = 1 << 4,
    CONTROL_BUTTON2 = 1 << 5,
    CONTROL_BUTTON3 = 1 << 6,
    CONTROL_BUTTON4 = 1 << 7
};

class InputList
{
public:
    struct InputState
    {
        int key;
        char state;
    };

    int last;
    enum {
        STATE_COUNT = 16,
        STATE_PRESSED = 0,
        STATE_HOLD = 1,
        STATE_RELEASED = 2
    };
    int count;
    InputState states[STATE_COUNT];

    InputList();
    void add(int v);
    void remove(int v);
    bool is_pressed_once(int v);
    bool is_pressed(int v);
    bool is_released_once(int v);
    bool is_any_pressed();
    bool is_any_pressed_once();
    int get_last();
    void clear();
    void update();
};

bool is_mouse_pressed(int button);
bool is_key_pressed(int button);
bool is_key_pressed(int key);
bool is_any_key_pressed();
bool is_any_key_pressed_once();
bool is_mouse_pressed_once(int key);
bool is_key_released_once(int key);
bool is_key_pressed_once(int key);
int get_last_key_pressed();

int get_joystick_direction(int n);
int get_joystick_direction_flags(int n);
bool test_joystick_direction_flags(int n, int flags);
int get_joystick_dpad(int n);
int get_joystick_dpad_degrees(int n);
int get_joystick_degrees(int n);
int get_joystick_lt(int n);
int get_joystick_rt(int n);
int get_joystick_z(int n);
int get_joystick_x(int n);
int get_joystick_y(int n);
float get_joystick_axis(int n, int axis);
bool is_joystick_pressed_once(int n, int button);
bool is_trigger_pressed_once(int side);
bool is_joystick_released_once(int n, int button);
bool any_joystick_pressed_once(int n);

bool is_player_pressed(int player, int flags);
bool is_player_pressed_once(int player, int flags);

int remap_button(int n);

#endif // CHOWDREN_INPUT_H
