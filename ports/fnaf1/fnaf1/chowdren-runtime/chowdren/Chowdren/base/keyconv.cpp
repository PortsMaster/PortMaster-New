#include <string>
#include "keydef.h"
#include "stringcommon.h"

int translate_vk_to_key(int vk)
{
    switch (vk) {
        case 1: return SDL_BUTTON_LEFT;
        case 2: return SDL_BUTTON_RIGHT;
        case 4: return SDL_BUTTON_MIDDLE;
        case 5: return SDL_BUTTON_X1;
        case 6: return SDL_BUTTON_X2;
        case 8: return SDLK_BACKSPACE;
        case 9: return SDLK_TAB;
        case 12: return SDLK_CLEAR;
        case 13: return SDLK_RETURN;
        case 16: return SDLK_LSHIFT;
        case 17: return SDLK_LCTRL;
        case 18: return SDLK_RALT;
        case 19: return SDLK_PAUSE;
        case 20: return SDLK_CAPSLOCK;
        case 27: return SDLK_ESCAPE;
        case 32: return SDLK_SPACE;
        case 33: return SDLK_PAGEUP;
        case 34: return SDLK_PAGEDOWN;
        case 35: return SDLK_END;
        case 36: return SDLK_HOME;
        case 37: return SDLK_LEFT;
        case 38: return SDLK_UP;
        case 39: return SDLK_RIGHT;
        case 40: return SDLK_DOWN;
        case 45: return SDLK_INSERT;
        case 46: return SDLK_DELETE;
        case 48: return SDLK_0;
        case 49: return SDLK_1;
        case 50: return SDLK_2;
        case 51: return SDLK_3;
        case 52: return SDLK_4;
        case 53: return SDLK_5;
        case 54: return SDLK_6;
        case 55: return SDLK_7;
        case 56: return SDLK_8;
        case 57: return SDLK_9;
        case 65: return SDLK_a;
        case 66: return SDLK_b;
        case 67: return SDLK_c;
        case 68: return SDLK_d;
        case 69: return SDLK_e;
        case 70: return SDLK_f;
        case 71: return SDLK_g;
        case 72: return SDLK_h;
        case 73: return SDLK_i;
        case 74: return SDLK_j;
        case 75: return SDLK_k;
        case 76: return SDLK_l;
        case 77: return SDLK_m;
        case 78: return SDLK_n;
        case 79: return SDLK_o;
        case 80: return SDLK_p;
        case 81: return SDLK_q;
        case 82: return SDLK_r;
        case 83: return SDLK_s;
        case 84: return SDLK_t;
        case 85: return SDLK_u;
        case 86: return SDLK_v;
        case 87: return SDLK_w;
        case 88: return SDLK_x;
        case 89: return SDLK_y;
        case 90: return SDLK_z;
        case 91: return SDLK_LGUI;
        case 92: return SDLK_RGUI;
        case 93: return SDLK_MENU;
        case 96: return SDLK_KP_0;
        case 97: return SDLK_KP_1;
        case 98: return SDLK_KP_2;
        case 99: return SDLK_KP_3;
        case 100: return SDLK_KP_4;
        case 101: return SDLK_KP_5;
        case 102: return SDLK_KP_6;
        case 103: return SDLK_KP_7;
        case 104: return SDLK_KP_8;
        case 105: return SDLK_KP_9;
        case 106: return SDLK_KP_MULTIPLY;
        case 107: return SDLK_KP_PLUS;
        case 109: return SDLK_KP_MINUS;
        case 110: return SDLK_KP_DECIMAL;
        case 111: return SDLK_KP_DIVIDE;
        case 112: return SDLK_F1;
        case 113: return SDLK_F2;
        case 114: return SDLK_F3;
        case 115: return SDLK_F4;
        case 116: return SDLK_F5;
        case 117: return SDLK_F6;
        case 118: return SDLK_F7;
        case 119: return SDLK_F8;
        case 120: return SDLK_F9;
        case 121: return SDLK_F10;
        case 122: return SDLK_F11;
        case 123: return SDLK_F12;
        case 124: return SDLK_F13;
        case 125: return SDLK_F14;
        case 126: return SDLK_F15;
        case 127: return SDLK_F16;
        case 128: return SDLK_F17;
        case 129: return SDLK_F18;
        case 130: return SDLK_F19;
        case 131: return SDLK_F20;
        case 132: return SDLK_F21;
        case 133: return SDLK_F22;
        case 134: return SDLK_F23;
        case 135: return SDLK_F24;
        case 144: return SDLK_NUMLOCKCLEAR;
        case 145: return SDLK_SCROLLLOCK;
        case 160: return SDLK_LSHIFT;
        case 161: return SDLK_RSHIFT;
        case 162: return SDLK_LCTRL;
        case 163: return SDLK_RCTRL;
        case 164: return SDLK_LALT;
        case 165: return SDLK_RALT;
        case 186: return SDLK_SEMICOLON;
        case 187: return SDLK_EQUALS;
        case 188: return SDLK_COMMA;
        case 189: return SDLK_MINUS;
        case 190: return SDLK_PERIOD;
        case 191: return SDLK_SLASH;
        case 192: return SDLK_BACKQUOTE;
        case 219: return SDLK_LEFTBRACKET;
        case 220: return SDLK_BACKSLASH;
        case 221: return SDLK_RIGHTBRACKET;
        case 222: return SDLK_QUOTE;
        case 226: return SDLK_BACKSLASH;
    }
    return -1;
}

inline unsigned int
get_key_string_hash (register const char *str, register unsigned int len)
{
  static unsigned char asso_values[] =
    {
      255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255,   0, 255, 255, 255,
      255, 255, 112, 107, 255, 102, 255,  97,  27,  25,
       15,  75,  50,   5,   0,   7, 125, 120,   0,   0,
        5,   0, 255, 255, 255, 100,  17,  40,  70,  60,
       10,  37,  42,  80,  92,  32,  45,  30,  95,  87,
       90,  82,  65,  20,  35, 115,  62,  85,  77,   2,
       72, 255, 255, 255, 255, 255, 255, 100,  17,  40,
       70,  60,  10,  37,  42,  80,  92,  32,  45,  30,
       95,  87,  90,  82,  65,  20,  35, 115,  62,  85,
       77,   2,  72, 255, 255, 255, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255, 255, 255, 255, 255
    };
  register int hval = len;

  switch (hval)
    {
      default:
        hval += asso_values[(unsigned char)str[1]+4];
      /*FALLTHROUGH*/
      case 1:
        hval += asso_values[(unsigned char)str[0]];
        break;
    }
  return hval + asso_values[(unsigned char)str[len - 1]];
}


int translate_string_to_key(const std::string & in)
{
    if (in.empty())
        return -1;
    unsigned int hash = get_key_string_hash(&in[0], in.size());
    switch (hash) {
        case 1: return SDLK_6;
        case 5: return SDLK_y;
        case 11: return SDLK_5;
        case 12: return SDLK_F6;
        case 15: return SDLK_7;
        case 18: return SDLK_F16;
        case 19: return SDLK_F7;
        case 21: return SDLK_f;
        case 23: return SDLK_F15;
        case 25: return SDLK_F17;
        case 27: return SDLK_F2;
        case 28: return SDLK_F22;
        case 31: return SDLK_2;
        case 33: return SDLK_F12;
        case 35: return SDLK_b;
        case 38: return SDLK_F21;
        case 40: return SDLK_F20;
        case 41: return SDLK_s;
        case 42: return SDLK_F1;
        case 43: return SDLK_F11;
        case 45: return SDLK_F10;
        case 49: return SDLK_KP_6;
        case 51: return SDLK_1;
        case 54: return SDLK_KP_5;
        case 55: return SDLK_0;
        case 56: return SDLK_KP_7;
        case 61: return SDLK_m;
        case 63: return SDLK_F24;
        case 64: return SDLK_KP_2;
        case 65: return SDLK_k;
        case 68: return SDLK_F14;
        case 71: return SDLK_t;
        case 73: return SDL_BUTTON_X2;
        case 74: return SDLK_KP_1;
        case 75: return SDLK_g;
        case 76: return SDLK_KP_0;
        case 81: return SDLK_c;
        case 83: return SDL_BUTTON_X1;
        case 85: return SDLK_h;
        case 88: return SDLK_F23;
        case 91: return SDLK_l;
        case 93: return SDLK_F13;
        case 94: return SDLK_F3;
        case 95: return SDL_BUTTON_LEFT;
        case 96: return SDL_BUTTON_RIGHT;
        case 98: return SDLK_SCROLLLOCK;
        case 99: return SDLK_KP_4;
        case 101: return SDLK_4;
        case 105: return SDLK_LSHIFT;
        case 107: return SDLK_LCTRL;
        case 108: return SDLK_RCTRL;
        case 110: return SDLK_LSHIFT;
        case 111: return SDLK_RSHIFT;
        case 112: return SDLK_LCTRL;
        case 115: return SDLK_TAB;
        case 116: return SDLK_PAUSE;
        case 120: return SDLK_SPACE;
        case 121: return SDLK_e;
        case 122: return SDL_BUTTON_MIDDLE;
        case 124: return SDLK_KP_3;
        case 125: return SDLK_v;
        case 126: return SDLK_HOME;
        case 131: return SDLK_r;
        case 132: return SDLK_F9;
        case 135: return SDLK_RIGHT;
        case 136: return SDLK_NUMLOCKCLEAR;
        case 137: return SDLK_F5;
        case 138: return SDLK_F19;
        case 140: return SDLK_CAPSLOCK;
        case 141: return SDLK_d;
        case 142: return SDLK_F8;
        case 143: return SDLK_F18;
        case 145: return SDLK_z;
        case 146: return SDLK_BACKSPACE;
        case 151: return SDLK_3;
        case 155: return SDLK_x;
        case 161: return SDLK_i;
        case 164: return SDLK_LEFT;
        case 165: return SDLK_q;
        case 169: return SDLK_KP_9;
        case 171: return SDLK_w;
        case 174: return SDLK_KP_8;
        case 175: return SDLK_o;
        case 181: return SDLK_p;
        case 185: return SDLK_j;
        case 186: return SDLK_INSERT;
        case 187: return SDLK_F4;
        case 189: return SDLK_DOWN;
        case 191: return SDLK_n;
        case 192: return SDLK_RGUI;
        case 195: return SDLK_KP_DIVIDE;
        case 198: return SDLK_END;
        case 200: return SDLK_CLEAR;
        case 201: return SDLK_a;
        case 202: return SDLK_KP_DECIMAL;
        case 205: return SDLK_KP_MINUS;
        case 211: return SDLK_ESCAPE;
        case 215: return SDLK_KP_PLUS;
        case 216: return SDLK_DELETE;
        case 221: return SDLK_LGUI;
        case 225: return SDLK_KP_MULTIPLY;
        case 228: return SDLK_RALT;
        case 229: return SDLK_MENU;
        case 231: return SDLK_u;
        case 233: return SDLK_LALT;
        case 234: return SDLK_RALT;
        case 241: return SDLK_9;
        case 242: return SDLK_UP;
        case 246: return SDLK_RETURN;
        case 247: return SDLK_PAGEUP;
        case 251: return SDLK_8;
        case 254: return SDLK_PAGEDOWN;
    }
    return -1;
}

std::string translate_vk_to_string(int vk)
{
    switch (vk) {
        case 1: return std::string("Mouse Left", 10);
        case 2: return std::string("Mouse Right", 11);
        case 4: return std::string("Mouse Middle", 12);
        case 5: return std::string("Mouse X1", 8);
        case 6: return std::string("Mouse X2", 8);
        case 8: return std::string("Backspace", 9);
        case 9: return std::string("Tab", 3);
        case 12: return std::string("Clear", 5);
        case 13: return std::string("Return", 6);
        case 16: return std::string("Shift", 5);
        case 17: return std::string("Control", 7);
        case 18: return std::string("Alt", 3);
        case 19: return std::string("Break", 5);
        case 20: return std::string("Capslock", 8);
        case 27: return std::string("Escape", 6);
        case 32: return std::string("Space", 5);
        case 33: return std::string("Page up", 7);
        case 34: return std::string("Page down", 9);
        case 35: return std::string("End", 3);
        case 36: return std::string("Home", 4);
        case 37: return std::string("Left", 4);
        case 38: return std::string("Up", 2);
        case 39: return std::string("Right", 5);
        case 40: return std::string("Down", 4);
        case 45: return std::string("Insert", 6);
        case 46: return std::string("Delete", 6);
        case 48: return std::string("0", 1);
        case 49: return std::string("1", 1);
        case 50: return std::string("2", 1);
        case 51: return std::string("3", 1);
        case 52: return std::string("4", 1);
        case 53: return std::string("5", 1);
        case 54: return std::string("6", 1);
        case 55: return std::string("7", 1);
        case 56: return std::string("8", 1);
        case 57: return std::string("9", 1);
        case 65: return std::string("A", 1);
        case 66: return std::string("B", 1);
        case 67: return std::string("C", 1);
        case 68: return std::string("D", 1);
        case 69: return std::string("E", 1);
        case 70: return std::string("F", 1);
        case 71: return std::string("G", 1);
        case 72: return std::string("H", 1);
        case 73: return std::string("I", 1);
        case 74: return std::string("J", 1);
        case 75: return std::string("K", 1);
        case 76: return std::string("L", 1);
        case 77: return std::string("M", 1);
        case 78: return std::string("N", 1);
        case 79: return std::string("O", 1);
        case 80: return std::string("P", 1);
        case 81: return std::string("Q", 1);
        case 82: return std::string("R", 1);
        case 83: return std::string("S", 1);
        case 84: return std::string("T", 1);
        case 85: return std::string("U", 1);
        case 86: return std::string("V", 1);
        case 87: return std::string("W", 1);
        case 88: return std::string("X", 1);
        case 89: return std::string("Y", 1);
        case 90: return std::string("Z", 1);
        case 91: return std::string("Left Window", 11);
        case 92: return std::string("Right Window", 12);
        case 93: return std::string("Menu", 4);
        case 96: return std::string("0 numeric", 9);
        case 97: return std::string("1 numeric", 9);
        case 98: return std::string("2 numeric", 9);
        case 99: return std::string("3 numeric", 9);
        case 100: return std::string("4 numeric", 9);
        case 101: return std::string("5 numeric", 9);
        case 102: return std::string("6 numeric", 9);
        case 103: return std::string("7 numeric", 9);
        case 104: return std::string("8 numeric", 9);
        case 105: return std::string("9 numeric", 9);
        case 106: return std::string("*", 1);
        case 107: return std::string("+", 1);
        case 109: return std::string("-", 1);
        case 110: return std::string("Decimal", 7);
        case 111: return std::string("/", 1);
        case 112: return std::string("F1", 2);
        case 113: return std::string("F2", 2);
        case 114: return std::string("F3", 2);
        case 115: return std::string("F4", 2);
        case 116: return std::string("F5", 2);
        case 117: return std::string("F6", 2);
        case 118: return std::string("F7", 2);
        case 119: return std::string("F8", 2);
        case 120: return std::string("F9", 2);
        case 121: return std::string("F10", 3);
        case 122: return std::string("F11", 3);
        case 123: return std::string("F12", 3);
        case 124: return std::string("F13", 3);
        case 125: return std::string("F14", 3);
        case 126: return std::string("F15", 3);
        case 127: return std::string("F16", 3);
        case 128: return std::string("F17", 3);
        case 129: return std::string("F18", 3);
        case 130: return std::string("F19", 3);
        case 131: return std::string("F20", 3);
        case 132: return std::string("F21", 3);
        case 133: return std::string("F22", 3);
        case 134: return std::string("F23", 3);
        case 135: return std::string("F24", 3);
        case 144: return std::string("Numlock", 7);
        case 145: return std::string("Scrollock", 9);
        case 160: return std::string("Shift Left", 10);
        case 161: return std::string("Shift Right", 11);
        case 162: return std::string("Control Left", 12);
        case 163: return std::string("Control Right", 13);
        case 164: return std::string("Alt Left", 8);
        case 165: return std::string("Alt Right", 9);
    }
    return "";
}

std::string translate_key_to_string(int key)
{
    switch (key) {
        case SDLK_KP_MULTIPLY: return std::string("*", 1);
        case SDLK_CAPSLOCK: return std::string("Capslock", 8);
        case SDLK_DELETE: return std::string("Delete", 6);
        case SDLK_INSERT: return std::string("Insert", 6);
        case SDLK_UP: return std::string("Up", 2);
        case SDLK_b: return std::string("B", 1);
        case SDLK_RCTRL: return std::string("Control Right", 13);
        case SDL_BUTTON_MIDDLE: return std::string("Mouse Middle", 12);
        case SDLK_NUMLOCKCLEAR: return std::string("Numlock", 7);
        case SDL_BUTTON_X1: return std::string("Mouse X1", 8);
        case SDL_BUTTON_X2: return std::string("Mouse X2", 8);
        case SDLK_k: return std::string("K", 1);
        case SDLK_RGUI: return std::string("Right Window", 12);
        case SDLK_LGUI: return std::string("Left Window", 11);
        case SDLK_F24: return std::string("F24", 3);
        case SDLK_F23: return std::string("F23", 3);
        case SDLK_F22: return std::string("F22", 3);
        case SDLK_F21: return std::string("F21", 3);
        case SDLK_F20: return std::string("F20", 3);
        case SDLK_KP_8: return std::string("8 numeric", 9);
        case SDLK_KP_9: return std::string("9 numeric", 9);
        case SDLK_KP_4: return std::string("4 numeric", 9);
        case SDLK_KP_5: return std::string("5 numeric", 9);
        case SDLK_KP_6: return std::string("6 numeric", 9);
        case SDLK_KP_7: return std::string("7 numeric", 9);
        case SDLK_KP_0: return std::string("0 numeric", 9);
        case SDLK_KP_1: return std::string("1 numeric", 9);
        case SDLK_KP_2: return std::string("2 numeric", 9);
        case SDLK_KP_3: return std::string("3 numeric", 9);
        case SDLK_F12: return std::string("F12", 3);
        case SDLK_F13: return std::string("F13", 3);
        case SDLK_F10: return std::string("F10", 3);
        case SDLK_F11: return std::string("F11", 3);
        case SDLK_F16: return std::string("F16", 3);
        case SDLK_F17: return std::string("F17", 3);
        case SDLK_F14: return std::string("F14", 3);
        case SDLK_F15: return std::string("F15", 3);
        case SDLK_F18: return std::string("F18", 3);
        case SDLK_F19: return std::string("F19", 3);
        case SDLK_LCTRL: return std::string("Control Left", 12);
        case SDL_BUTTON_RIGHT: return std::string("Mouse Right", 11);
        case SDLK_RALT: return std::string("Alt Right", 9);
        case SDLK_RETURN: return std::string("Return", 6);
        case SDLK_PAUSE: return std::string("Break", 5);
        case SDLK_SCROLLLOCK: return std::string("Scrollock", 9);
        case SDLK_KP_ENTER: return std::string("Return", 6);
        case SDLK_ESCAPE: return std::string("Escape", 6);
        case SDLK_RSHIFT: return std::string("Shift Right", 11);
        case SDLK_KP_MINUS: return std::string("-", 1);
        case SDLK_KP_DECIMAL: return std::string("Decimal", 7);
        case SDLK_PAGEDOWN: return std::string("Page down", 9);
        case SDLK_PAGEUP: return std::string("Page up", 7);
        case SDL_BUTTON_LEFT: return std::string("Mouse Left", 10);
        case SDLK_0: return std::string("0", 1);
        case SDLK_KP_PLUS: return std::string("+", 1);
        case SDLK_END: return std::string("End", 3);
        case SDLK_TAB: return std::string("Tab", 3);
        case SDLK_HOME: return std::string("Home", 4);
        case SDLK_KP_DIVIDE: return std::string("/", 1);
        case SDLK_RIGHT: return std::string("Right", 5);
        case SDLK_DOWN: return std::string("Down", 4);
        case SDLK_u: return std::string("U", 1);
        case SDLK_t: return std::string("T", 1);
        case SDLK_w: return std::string("W", 1);
        case SDLK_v: return std::string("V", 1);
        case SDLK_q: return std::string("Q", 1);
        case SDLK_p: return std::string("P", 1);
        case SDLK_s: return std::string("S", 1);
        case SDLK_r: return std::string("R", 1);
        case SDLK_BACKSPACE: return std::string("Backspace", 9);
        case SDLK_y: return std::string("Y", 1);
        case SDLK_x: return std::string("X", 1);
        case SDLK_z: return std::string("Z", 1);
        case SDLK_e: return std::string("E", 1);
        case SDLK_d: return std::string("D", 1);
        case SDLK_g: return std::string("G", 1);
        case SDLK_f: return std::string("F", 1);
        case SDLK_a: return std::string("A", 1);
        case SDLK_c: return std::string("C", 1);
        case SDLK_LEFT: return std::string("Left", 4);
        case SDLK_m: return std::string("M", 1);
        case SDLK_l: return std::string("L", 1);
        case SDLK_o: return std::string("O", 1);
        case SDLK_n: return std::string("N", 1);
        case SDLK_i: return std::string("I", 1);
        case SDLK_h: return std::string("H", 1);
        case SDLK_LSHIFT: return std::string("Shift Left", 10);
        case SDLK_j: return std::string("J", 1);
        case SDLK_F8: return std::string("F8", 2);
        case SDLK_F9: return std::string("F9", 2);
        case SDLK_F1: return std::string("F1", 2);
        case SDLK_F2: return std::string("F2", 2);
        case SDLK_F3: return std::string("F3", 2);
        case SDLK_F4: return std::string("F4", 2);
        case SDLK_F5: return std::string("F5", 2);
        case SDLK_F6: return std::string("F6", 2);
        case SDLK_F7: return std::string("F7", 2);
        case SDLK_LALT: return std::string("Alt Left", 8);
        case SDLK_5: return std::string("5", 1);
        case SDLK_4: return std::string("4", 1);
        case SDLK_7: return std::string("7", 1);
        case SDLK_6: return std::string("6", 1);
        case SDLK_1: return std::string("1", 1);
        case SDLK_MENU: return std::string("Menu", 4);
        case SDLK_3: return std::string("3", 1);
        case SDLK_2: return std::string("2", 1);
        case SDLK_9: return std::string("9", 1);
        case SDLK_8: return std::string("8", 1);
        case SDLK_CLEAR: return std::string("Clear", 5);
        case SDLK_SPACE: return std::string("Space", 5);
    }
    return "";
}
