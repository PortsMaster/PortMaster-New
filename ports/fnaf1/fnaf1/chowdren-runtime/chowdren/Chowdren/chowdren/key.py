VK_TO_SDL = {
    0x1 : ['SDL_BUTTON_LEFT'],
    0x2 : ['SDL_BUTTON_RIGHT'],
    # 0x3 : ['SDLK_BREAK'],
    0x4 : ['SDL_BUTTON_MIDDLE'],
    0x5 : ['SDL_BUTTON_X1'],
    0x6 : ['SDL_BUTTON_X2'],
    0x8 : ['SDLK_BACKSPACE'],
    0x9 : ['SDLK_TAB'],
    0xC : ['SDLK_CLEAR'],
    0xD : ['SDLK_RETURN', 'SDLK_KP_ENTER'],
    0x10 : ['SDLK_LSHIFT', 'SDLK_RSHIFT'],
    0x11 : ['SDLK_LCTRL', 'SDLK_RCTRL'],
    0x12 : ['SDLK_RALT', 'SDLK_LALT'],
    0x13 : ['SDLK_PAUSE'],
    0x14 : ['SDLK_CAPSLOCK'],
    0x1B : ['SDLK_ESCAPE'],
    0x20 : ['SDLK_SPACE'],
    0x21 : ['SDLK_PAGEUP', 'SDLK_KP_9'],
    0x22 : ['SDLK_PAGEDOWN', 'SDLK_KP_3'],
    0x23 : ['SDLK_END', 'SDLK_KP_1'],
    0x24 : ['SDLK_HOME', 'SDLK_KP_7'],
    0x25 : ['SDLK_LEFT', 'SDLK_KP_4'],
    0x26 : ['SDLK_UP', 'SDLK_KP_8'],
    0x27 : ['SDLK_RIGHT', 'SDLK_KP_6'],
    0x28 : ['SDLK_DOWN', 'SDLK_KP_2'],
    0x2D : ['SDLK_INSERT', 'SDLK_KP_0'],
    0x2E : ['SDLK_DELETE', 'SDLK_KP_DECIMAL'],
    0x30 : ['SDLK_0'], # VK_0
    0x31 : ['SDLK_1'], # VK_1
    0x32 : ['SDLK_2'], # VK_2
    0x33 : ['SDLK_3'], # VK_3
    0x34 : ['SDLK_4'], # VK_4
    0x35 : ['SDLK_5'], # VK_5
    0x36 : ['SDLK_6'], # VK_6
    0x37 : ['SDLK_7'], # VK_7
    0x38 : ['SDLK_8'], # VK_8
    0x39 : ['SDLK_9'], # VK_9
    0x41 : ['SDLK_a'], # VK_A
    0x42 : ['SDLK_b'], # VK_B
    0x43 : ['SDLK_c'], # VK_C
    0x44 : ['SDLK_d'], # VK_D
    0x45 : ['SDLK_e'], # VK_E
    0x46 : ['SDLK_f'], # VK_F
    0x47 : ['SDLK_g'], # VK_G
    0x48 : ['SDLK_h'], # VK_H
    0x49 : ['SDLK_i'], # VK_I
    0x4A : ['SDLK_j'], # VK_J
    0x4B : ['SDLK_k'], # VK_K
    0x4C : ['SDLK_l'], # VK_L
    0x4D : ['SDLK_m'], # VK_M
    0x4E : ['SDLK_n'], # VK_N
    0x4F : ['SDLK_o'], # VK_O
    0x50 : ['SDLK_p'], # VK_P
    0x51 : ['SDLK_q'], # VK_Q
    0x52 : ['SDLK_r'], # VK_R
    0x53 : ['SDLK_s'], # VK_S
    0x54 : ['SDLK_t'], # VK_T
    0x55 : ['SDLK_u'], # VK_U
    0x56 : ['SDLK_v'], # VK_V
    0x57 : ['SDLK_w'], # VK_W
    0x58 : ['SDLK_x'], # VK_X
    0x59 : ['SDLK_y'], # VK_Y
    0x5A : ['SDLK_z'], # VK_Z
    0x5B : ['SDLK_LGUI'], # VK_LWIN
    0x5C : ['SDLK_RGUI'], # VK_RWIN
    0x5D : ['SDLK_MENU'], # VK_APPS
    0x60 : ['SDLK_KP_0'], # VK_NUMPAD0
    0x61 : ['SDLK_KP_1'], # VK_NUMPAD1
    0x62 : ['SDLK_KP_2'], # VK_NUMPAD2
    0x63 : ['SDLK_KP_3'], # VK_NUMPAD3
    0x64 : ['SDLK_KP_4'], # VK_NUMPAD4
    0x65 : ['SDLK_KP_5'], # VK_NUMPAD5
    0x66 : ['SDLK_KP_6'], # VK_NUMPAD6
    0x67 : ['SDLK_KP_7'], # VK_NUMPAD7
    0x68 : ['SDLK_KP_8'], # VK_NUMPAD8
    0x69 : ['SDLK_KP_9'], # VK_NUMPAD9
    0x6A : ['SDLK_KP_MULTIPLY'], # VK_MULTIPLY
    0x6B : ['SDLK_KP_PLUS'], # VK_ADD
    0x6D : ['SDLK_KP_MINUS'], # VK_SUBTRACT
    0x6E : ['SDLK_KP_DECIMAL'], # VK_DECIMAL
    0x6F : ['SDLK_KP_DIVIDE'], # VK_DIVIDE
    0x70 : ['SDLK_F1'], # VK_F1
    0x71 : ['SDLK_F2'], # VK_F2
    0x72 : ['SDLK_F3'], # VK_F3
    0x73 : ['SDLK_F4'], # VK_F4
    0x74 : ['SDLK_F5'], # VK_F5
    0x75 : ['SDLK_F6'], # VK_F6
    0x76 : ['SDLK_F7'], # VK_F7
    0x77 : ['SDLK_F8'], # VK_F8
    0x78 : ['SDLK_F9'], # VK_F9
    0x79 : ['SDLK_F10'], # VK_F10
    0x7A : ['SDLK_F11'], # VK_F11
    0x7B : ['SDLK_F12'], # VK_F12
    0x7C : ['SDLK_F13'], # VK_F13
    0x7D : ['SDLK_F14'], # VK_F14
    0x7E : ['SDLK_F15'], # VK_F15
    0x7F : ['SDLK_F16'], # VK_F16
    0x80 : ['SDLK_F17'], # VK_F17
    0x81 : ['SDLK_F18'], # VK_F18
    0x82 : ['SDLK_F19'], # VK_F19
    0x83 : ['SDLK_F20'], # VK_F20
    0x84 : ['SDLK_F21'], # VK_F21
    0x85 : ['SDLK_F22'], # VK_F22
    0x86 : ['SDLK_F23'], # VK_F23
    0x87 : ['SDLK_F24'], # VK_F24
    0x90 : ['SDLK_NUMLOCKCLEAR'], # VK_NUMLOCK
    0x91 : ['SDLK_SCROLLLOCK'], # VK_SCROLL
    0xA0 : ['SDLK_LSHIFT'], # VK_LSHIFT
    0xA1 : ['SDLK_RSHIFT'], # VK_RSHIFT
    0xA2 : ['SDLK_LCTRL'], # VK_LCONTROL
    0xA3 : ['SDLK_RCTRL'], # VK_RCONTROL
    0xA4 : ['SDLK_LALT'], # VK_LMENU
    0xA5 : ['SDLK_RALT'], # VK_RMENU
    0xBD : ['SDLK_MINUS'],
    0xBB : ['SDLK_EQUALS'],
    0xDB : ['SDLK_LEFTBRACKET'],
    0xDD : ['SDLK_RIGHTBRACKET'],
    0xDC : ['SDLK_BACKSLASH'],
    0xBA : ['SDLK_SEMICOLON'],
    0xDE : ['SDLK_QUOTE'],
    0xC0 : ['SDLK_BACKQUOTE'],
    0xBC : ['SDLK_COMMA'],
    0xBE : ['SDLK_PERIOD'],
    0xBF : ['SDLK_SLASH'],
    0xE2 : ['SDLK_BACKSLASH']
}

SDL_SCANCODE_UNKNOWN = 0

# /**
#   \name Usage page 0x07
# 
#   These values are from usage page 0x07 (USB keyboard page).
# /
# /* @{# /

SDL_SCANCODE_A = 4
SDL_SCANCODE_B = 5
SDL_SCANCODE_C = 6
SDL_SCANCODE_D = 7
SDL_SCANCODE_E = 8
SDL_SCANCODE_F = 9
SDL_SCANCODE_G = 10
SDL_SCANCODE_H = 11
SDL_SCANCODE_I = 12
SDL_SCANCODE_J = 13
SDL_SCANCODE_K = 14
SDL_SCANCODE_L = 15
SDL_SCANCODE_M = 16
SDL_SCANCODE_N = 17
SDL_SCANCODE_O = 18
SDL_SCANCODE_P = 19
SDL_SCANCODE_Q = 20
SDL_SCANCODE_R = 21
SDL_SCANCODE_S = 22
SDL_SCANCODE_T = 23
SDL_SCANCODE_U = 24
SDL_SCANCODE_V = 25
SDL_SCANCODE_W = 26
SDL_SCANCODE_X = 27
SDL_SCANCODE_Y = 28
SDL_SCANCODE_Z = 29

SDL_SCANCODE_1 = 30
SDL_SCANCODE_2 = 31
SDL_SCANCODE_3 = 32
SDL_SCANCODE_4 = 33
SDL_SCANCODE_5 = 34
SDL_SCANCODE_6 = 35
SDL_SCANCODE_7 = 36
SDL_SCANCODE_8 = 37
SDL_SCANCODE_9 = 38
SDL_SCANCODE_0 = 39

SDL_SCANCODE_RETURN = 40
SDL_SCANCODE_ESCAPE = 41
SDL_SCANCODE_BACKSPACE = 42
SDL_SCANCODE_TAB = 43
SDL_SCANCODE_SPACE = 44

SDL_SCANCODE_MINUS = 45
SDL_SCANCODE_EQUALS = 46
SDL_SCANCODE_LEFTBRACKET = 47
SDL_SCANCODE_RIGHTBRACKET = 48
SDL_SCANCODE_BACKSLASH = 49 # /**< Located at the lower left of the return
                             #    key on ISO keyboards and at the right end
                             #    of the QWERTY row on ANSI keyboards.
                             #    Produces REVERSE SOLIDUS (backslash) and
                             #    VERTICAL LINE in a US layout REVERSE
                             #    SOLIDUS and VERTICAL LINE in a UK Mac
                             #    layout NUMBER SIGN and TILDE in a UK
                             #    Windows layout DOLLAR SIGN and POUND SIGN
                             #    in a Swiss German layout NUMBER SIGN and
                             #    APOSTROPHE in a German layout GRAVE
                             #    ACCENT and POUND SIGN in a French Mac
                             #    layout and ASTERISK and MICRO SIGN in a
                             #    French Windows layout.
                             # /
SDL_SCANCODE_NONUSHASH = 50 # /**< ISO USB keyboards actually use this code
                             #    instead of 49 for the same key but all
                             #    OSes I've seen treat the two codes
                             #    identically. So as an implementor unless
                             #    your keyboard generates both of those
                             #    codes and your OS treats them differently
                             #    you should generate SDL_SCANCODE_BACKSLASH
                             #    instead of this code. As a user you
                             #    should not rely on this code because SDL
                             #    will never generate it with most (all?)
                             #    keyboards.
                             # /
SDL_SCANCODE_SEMICOLON = 51
SDL_SCANCODE_APOSTROPHE = 52
SDL_SCANCODE_GRAVE = 53 # /**< Located in the top left corner (on both ANSI
                         #    and ISO keyboards). Produces GRAVE ACCENT and
                         #    TILDE in a US Windows layout and in US and UK
                         #    Mac layouts on ANSI keyboards GRAVE ACCENT
                         #    and NOT SIGN in a UK Windows layout SECTION
                         #    SIGN and PLUS-MINUS SIGN in US and UK Mac
                         #    layouts on ISO keyboards SECTION SIGN and
                         #    DEGREE SIGN in a Swiss German layout (Mac:
                         #    only on ISO keyboards) CIRCUMFLEX ACCENT and
                         #    DEGREE SIGN in a German layout (Mac: only on
                         #    ISO keyboards) SUPERSCRIPT TWO and TILDE in a
                         #    French Windows layout COMMERCIAL AT and
                         #    NUMBER SIGN in a French Mac layout on ISO
                         #    keyboards and LESS-THAN SIGN and GREATER-THAN
                         #    SIGN in a Swiss German German or French Mac
                         #    layout on ANSI keyboards.
                         # /
SDL_SCANCODE_COMMA = 54
SDL_SCANCODE_PERIOD = 55
SDL_SCANCODE_SLASH = 56
SDL_SCANCODE_CAPSLOCK = 57
SDL_SCANCODE_F1 = 58
SDL_SCANCODE_F2 = 59
SDL_SCANCODE_F3 = 60
SDL_SCANCODE_F4 = 61
SDL_SCANCODE_F5 = 62
SDL_SCANCODE_F6 = 63
SDL_SCANCODE_F7 = 64
SDL_SCANCODE_F8 = 65
SDL_SCANCODE_F9 = 66
SDL_SCANCODE_F10 = 67
SDL_SCANCODE_F11 = 68
SDL_SCANCODE_F12 = 69
SDL_SCANCODE_PRINTSCREEN = 70
SDL_SCANCODE_SCROLLLOCK = 71
SDL_SCANCODE_PAUSE = 72
SDL_SCANCODE_INSERT = 73 # /**< insert on PC help on some Mac keyboards (but
                          #    does send code 73 not 117)# /
SDL_SCANCODE_HOME = 74
SDL_SCANCODE_PAGEUP = 75
SDL_SCANCODE_DELETE = 76
SDL_SCANCODE_END = 77
SDL_SCANCODE_PAGEDOWN = 78
SDL_SCANCODE_RIGHT = 79
SDL_SCANCODE_LEFT = 80
SDL_SCANCODE_DOWN = 81
SDL_SCANCODE_UP = 82
SDL_SCANCODE_NUMLOCKCLEAR = 83 # /**< num lock on PC clear on Mac keyboards
                                # /
SDL_SCANCODE_KP_DIVIDE = 84
SDL_SCANCODE_KP_MULTIPLY = 85
SDL_SCANCODE_KP_MINUS = 86
SDL_SCANCODE_KP_PLUS = 87
SDL_SCANCODE_KP_ENTER = 88
SDL_SCANCODE_KP_1 = 89
SDL_SCANCODE_KP_2 = 90
SDL_SCANCODE_KP_3 = 91
SDL_SCANCODE_KP_4 = 92
SDL_SCANCODE_KP_5 = 93
SDL_SCANCODE_KP_6 = 94
SDL_SCANCODE_KP_7 = 95
SDL_SCANCODE_KP_8 = 96
SDL_SCANCODE_KP_9 = 97
SDL_SCANCODE_KP_0 = 98
SDL_SCANCODE_KP_PERIOD = 99

SDL_SCANCODE_NONUSBACKSLASH = 100 # /**< This is the additional key that ISO
                                   #    keyboards have over ANSI ones
                                   #    located between left shift and Y.
                                   #    Produces GRAVE ACCENT and TILDE in a
                                   #    US or UK Mac layout REVERSE SOLIDUS
                                   #    (backslash) and VERTICAL LINE in a
                                   #    US or UK Windows layout and
                                   #    LESS-THAN SIGN and GREATER-THAN SIGN
                                   #    in a Swiss German German or French
                                   #    layout.# /
SDL_SCANCODE_APPLICATION = 101 # /**< windows contextual menu compose# /
SDL_SCANCODE_POWER = 102 # /**< The USB document says this is a status flag
                          #    not a physical key - but some Mac keyboards
                          #    do have a power key.# /
SDL_SCANCODE_KP_EQUALS = 103
SDL_SCANCODE_F13 = 104
SDL_SCANCODE_F14 = 105
SDL_SCANCODE_F15 = 106
SDL_SCANCODE_F16 = 107
SDL_SCANCODE_F17 = 108
SDL_SCANCODE_F18 = 109
SDL_SCANCODE_F19 = 110
SDL_SCANCODE_F20 = 111
SDL_SCANCODE_F21 = 112
SDL_SCANCODE_F22 = 113
SDL_SCANCODE_F23 = 114
SDL_SCANCODE_F24 = 115
SDL_SCANCODE_EXECUTE = 116
SDL_SCANCODE_HELP = 117
SDL_SCANCODE_MENU = 118
SDL_SCANCODE_SELECT = 119
SDL_SCANCODE_STOP = 120
SDL_SCANCODE_AGAIN = 121   # /**< redo# /
SDL_SCANCODE_UNDO = 122
SDL_SCANCODE_CUT = 123
SDL_SCANCODE_COPY = 124
SDL_SCANCODE_PASTE = 125
SDL_SCANCODE_FIND = 126
SDL_SCANCODE_MUTE = 127
SDL_SCANCODE_VOLUMEUP = 128
SDL_SCANCODE_VOLUMEDOWN = 129
SDL_SCANCODE_KP_COMMA = 133
SDL_SCANCODE_KP_EQUALSAS400 = 134
SDL_SCANCODE_INTERNATIONAL1 = 135
SDL_SCANCODE_INTERNATIONAL2 = 136
SDL_SCANCODE_INTERNATIONAL3 = 137 # /**< Yen# /
SDL_SCANCODE_INTERNATIONAL4 = 138
SDL_SCANCODE_INTERNATIONAL5 = 139
SDL_SCANCODE_INTERNATIONAL6 = 140
SDL_SCANCODE_INTERNATIONAL7 = 141
SDL_SCANCODE_INTERNATIONAL8 = 142
SDL_SCANCODE_INTERNATIONAL9 = 143
SDL_SCANCODE_LANG1 = 144 # /**< Hangul/English toggle# /
SDL_SCANCODE_LANG2 = 145 # /**< Hanja conversion# /
SDL_SCANCODE_LANG3 = 146 # /**< Katakana# /
SDL_SCANCODE_LANG4 = 147 # /**< Hiragana# /
SDL_SCANCODE_LANG5 = 148 # /**< Zenkaku/Hankaku# /
SDL_SCANCODE_LANG6 = 149 # /**< reserved# /
SDL_SCANCODE_LANG7 = 150 # /**< reserved# /
SDL_SCANCODE_LANG8 = 151 # /**< reserved# /
SDL_SCANCODE_LANG9 = 152 # /**< reserved# /
SDL_SCANCODE_ALTERASE = 153 # /**< Erase-Eaze# /
SDL_SCANCODE_SYSREQ = 154
SDL_SCANCODE_CANCEL = 155
SDL_SCANCODE_CLEAR = 156
SDL_SCANCODE_PRIOR = 157
SDL_SCANCODE_RETURN2 = 158
SDL_SCANCODE_SEPARATOR = 159
SDL_SCANCODE_OUT = 160
SDL_SCANCODE_OPER = 161
SDL_SCANCODE_CLEARAGAIN = 162
SDL_SCANCODE_CRSEL = 163
SDL_SCANCODE_EXSEL = 164
SDL_SCANCODE_KP_00 = 176
SDL_SCANCODE_KP_000 = 177
SDL_SCANCODE_THOUSANDSSEPARATOR = 178
SDL_SCANCODE_DECIMALSEPARATOR = 179
SDL_SCANCODE_CURRENCYUNIT = 180
SDL_SCANCODE_CURRENCYSUBUNIT = 181
SDL_SCANCODE_KP_LEFTPAREN = 182
SDL_SCANCODE_KP_RIGHTPAREN = 183
SDL_SCANCODE_KP_LEFTBRACE = 184
SDL_SCANCODE_KP_RIGHTBRACE = 185
SDL_SCANCODE_KP_TAB = 186
SDL_SCANCODE_KP_BACKSPACE = 187
SDL_SCANCODE_KP_A = 188
SDL_SCANCODE_KP_B = 189
SDL_SCANCODE_KP_C = 190
SDL_SCANCODE_KP_D = 191
SDL_SCANCODE_KP_E = 192
SDL_SCANCODE_KP_F = 193
SDL_SCANCODE_KP_XOR = 194
SDL_SCANCODE_KP_POWER = 195
SDL_SCANCODE_KP_PERCENT = 196
SDL_SCANCODE_KP_LESS = 197
SDL_SCANCODE_KP_GREATER = 198
SDL_SCANCODE_KP_AMPERSAND = 199
SDL_SCANCODE_KP_DBLAMPERSAND = 200
SDL_SCANCODE_KP_VERTICALBAR = 201
SDL_SCANCODE_KP_DBLVERTICALBAR = 202
SDL_SCANCODE_KP_COLON = 203
SDL_SCANCODE_KP_HASH = 204
SDL_SCANCODE_KP_SPACE = 205
SDL_SCANCODE_KP_AT = 206
SDL_SCANCODE_KP_EXCLAM = 207
SDL_SCANCODE_KP_MEMSTORE = 208
SDL_SCANCODE_KP_MEMRECALL = 209
SDL_SCANCODE_KP_MEMCLEAR = 210
SDL_SCANCODE_KP_MEMADD = 211
SDL_SCANCODE_KP_MEMSUBTRACT = 212
SDL_SCANCODE_KP_MEMMULTIPLY = 213
SDL_SCANCODE_KP_MEMDIVIDE = 214
SDL_SCANCODE_KP_PLUSMINUS = 215
SDL_SCANCODE_KP_CLEAR = 216
SDL_SCANCODE_KP_CLEARENTRY = 217
SDL_SCANCODE_KP_BINARY = 218
SDL_SCANCODE_KP_OCTAL = 219
SDL_SCANCODE_KP_DECIMAL = 220
SDL_SCANCODE_KP_HEXADECIMAL = 221
SDL_SCANCODE_LCTRL = 224
SDL_SCANCODE_LSHIFT = 225
SDL_SCANCODE_LALT = 226
SDL_SCANCODE_LGUI = 227
SDL_SCANCODE_RCTRL = 228
SDL_SCANCODE_RSHIFT = 229
SDL_SCANCODE_RALT = 230
SDL_SCANCODE_RGUI = 231
SDL_SCANCODE_MODE = 257
SDL_SCANCODE_AUDIONEXT = 258
SDL_SCANCODE_AUDIOPREV = 259
SDL_SCANCODE_AUDIOSTOP = 260
SDL_SCANCODE_AUDIOPLAY = 261
SDL_SCANCODE_AUDIOMUTE = 262
SDL_SCANCODE_MEDIASELECT = 263
SDL_SCANCODE_WWW = 264
SDL_SCANCODE_MAIL = 265
SDL_SCANCODE_CALCULATOR = 266
SDL_SCANCODE_COMPUTER = 267
SDL_SCANCODE_AC_SEARCH = 268
SDL_SCANCODE_AC_HOME = 269
SDL_SCANCODE_AC_BACK = 270
SDL_SCANCODE_AC_FORWARD = 271
SDL_SCANCODE_AC_STOP = 272
SDL_SCANCODE_AC_REFRESH = 273
SDL_SCANCODE_AC_BOOKMARKS = 274
SDL_SCANCODE_BRIGHTNESSDOWN = 275
SDL_SCANCODE_BRIGHTNESSUP = 276
SDL_SCANCODE_DISPLAYSWITCH = 277
SDL_SCANCODE_KBDILLUMTOGGLE = 278
SDL_SCANCODE_KBDILLUMDOWN = 279
SDL_SCANCODE_KBDILLUMUP = 280
SDL_SCANCODE_EJECT = 281
SDL_SCANCODE_SLEEP = 282
SDL_SCANCODE_APP1 = 283
SDL_SCANCODE_APP2 = 284
SDL_NUM_SCANCODES = 512

def SDL_SCANCODE_TO_KEYCODE(v):
    return v | (1<<30)

SDL_KEYS = {
    'SDLK_RETURN' : '\r',
    'SDLK_ESCAPE' : '\033',
    'SDLK_BACKSPACE' : '\b',
    'SDLK_TAB' : '\t',
    'SDLK_SPACE' : ' ',
    'SDLK_EXCLAIM' : '!',
    'SDLK_QUOTEDBL' : '"',
    'SDLK_HASH' : '#',
    'SDLK_PERCENT' : '%',
    'SDLK_DOLLAR' : '$',
    'SDLK_AMPERSAND' : '&',
    'SDLK_QUOTE' : '\'',
    'SDLK_LEFTPAREN' : '(',
    'SDLK_RIGHTPAREN' : ')',
    'SDLK_ASTERISK' : '*',
    'SDLK_PLUS' : '+',
    'SDLK_COMMA' : ',',
    'SDLK_MINUS' : '-',
    'SDLK_PERIOD' : '.',
    'SDLK_SLASH' : '/',
    'SDLK_0' : '0',
    'SDLK_1' : '1',
    'SDLK_2' : '2',
    'SDLK_3' : '3',
    'SDLK_4' : '4',
    'SDLK_5' : '5',
    'SDLK_6' : '6',
    'SDLK_7' : '7',
    'SDLK_8' : '8',
    'SDLK_9' : '9',
    'SDLK_COLON' : ':',
    'SDLK_SEMICOLON' : ';',
    'SDLK_LESS' : '<',
    'SDLK_EQUALS' : '=',
    'SDLK_GREATER' : '>',
    'SDLK_QUESTION' : '?',
    'SDLK_AT' : '@',
    'SDLK_LEFTBRACKET' : '[',
    'SDLK_BACKSLASH' : '\\',
    'SDLK_RIGHTBRACKET' : ']',
    'SDLK_CARET' : '^',
    'SDLK_UNDERSCORE' : '_',
    'SDLK_BACKQUOTE' : '`',
    'SDLK_a' : 'a',
    'SDLK_b' : 'b',
    'SDLK_c' : 'c',
    'SDLK_d' : 'd',
    'SDLK_e' : 'e',
    'SDLK_f' : 'f',
    'SDLK_g' : 'g',
    'SDLK_h' : 'h',
    'SDLK_i' : 'i',
    'SDLK_j' : 'j',
    'SDLK_k' : 'k',
    'SDLK_l' : 'l',
    'SDLK_m' : 'm',
    'SDLK_n' : 'n',
    'SDLK_o' : 'o',
    'SDLK_p' : 'p',
    'SDLK_q' : 'q',
    'SDLK_r' : 'r',
    'SDLK_s' : 's',
    'SDLK_t' : 't',
    'SDLK_u' : 'u',
    'SDLK_v' : 'v',
    'SDLK_w' : 'w',
    'SDLK_x' : 'x',
    'SDLK_y' : 'y',
    'SDLK_z' : 'z',

    'SDLK_CAPSLOCK' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_CAPSLOCK),

    'SDLK_F1' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F1),
    'SDLK_F2' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F2),
    'SDLK_F3' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F3),
    'SDLK_F4' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F4),
    'SDLK_F5' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F5),
    'SDLK_F6' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F6),
    'SDLK_F7' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F7),
    'SDLK_F8' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F8),
    'SDLK_F9' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F9),
    'SDLK_F10' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F10),
    'SDLK_F11' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F11),
    'SDLK_F12' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F12),

    'SDLK_PRINTSCREEN' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_PRINTSCREEN),
    'SDLK_SCROLLLOCK' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_SCROLLLOCK),
    'SDLK_PAUSE' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_PAUSE),
    'SDLK_INSERT' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_INSERT),
    'SDLK_HOME' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_HOME),
    'SDLK_PAGEUP' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_PAGEUP),
    'SDLK_DELETE' : '\177',
    'SDLK_END' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_END),
    'SDLK_PAGEDOWN' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_PAGEDOWN),
    'SDLK_RIGHT' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_RIGHT),
    'SDLK_LEFT' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_LEFT),
    'SDLK_DOWN' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_DOWN),
    'SDLK_UP' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_UP),

    'SDLK_NUMLOCKCLEAR' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_NUMLOCKCLEAR),
    'SDLK_KP_DIVIDE' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_DIVIDE),
    'SDLK_KP_MULTIPLY' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_MULTIPLY),
    'SDLK_KP_MINUS' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_MINUS),
    'SDLK_KP_PLUS' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_PLUS),
    'SDLK_KP_ENTER' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_ENTER),
    'SDLK_KP_1' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_1),
    'SDLK_KP_2' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_2),
    'SDLK_KP_3' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_3),
    'SDLK_KP_4' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_4),
    'SDLK_KP_5' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_5),
    'SDLK_KP_6' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_6),
    'SDLK_KP_7' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_7),
    'SDLK_KP_8' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_8),
    'SDLK_KP_9' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_9),
    'SDLK_KP_0' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_0),
    'SDLK_KP_PERIOD' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_PERIOD),

    'SDLK_APPLICATION' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_APPLICATION),
    'SDLK_POWER' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_POWER),
    'SDLK_KP_EQUALS' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_EQUALS),
    'SDLK_F13' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F13),
    'SDLK_F14' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F14),
    'SDLK_F15' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F15),
    'SDLK_F16' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F16),
    'SDLK_F17' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F17),
    'SDLK_F18' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F18),
    'SDLK_F19' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F19),
    'SDLK_F20' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F20),
    'SDLK_F21' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F21),
    'SDLK_F22' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F22),
    'SDLK_F23' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F23),
    'SDLK_F24' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_F24),
    'SDLK_EXECUTE' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_EXECUTE),
    'SDLK_HELP' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_HELP),
    'SDLK_MENU' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_MENU),
    'SDLK_SELECT' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_SELECT),
    'SDLK_STOP' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_STOP),
    'SDLK_AGAIN' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AGAIN),
    'SDLK_UNDO' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_UNDO),
    'SDLK_CUT' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_CUT),
    'SDLK_COPY' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_COPY),
    'SDLK_PASTE' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_PASTE),
    'SDLK_FIND' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_FIND),
    'SDLK_MUTE' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_MUTE),
    'SDLK_VOLUMEUP' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_VOLUMEUP),
    'SDLK_VOLUMEDOWN' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_VOLUMEDOWN),
    'SDLK_KP_COMMA' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_COMMA),
    'SDLK_KP_EQUALSAS400' :
        SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_EQUALSAS400),

    'SDLK_ALTERASE' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_ALTERASE),
    'SDLK_SYSREQ' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_SYSREQ),
    'SDLK_CANCEL' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_CANCEL),
    'SDLK_CLEAR' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_CLEAR),
    'SDLK_PRIOR' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_PRIOR),
    'SDLK_RETURN2' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_RETURN2),
    'SDLK_SEPARATOR' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_SEPARATOR),
    'SDLK_OUT' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_OUT),
    'SDLK_OPER' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_OPER),
    'SDLK_CLEARAGAIN' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_CLEARAGAIN),
    'SDLK_CRSEL' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_CRSEL),
    'SDLK_EXSEL' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_EXSEL),

    'SDLK_KP_00' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_00),
    'SDLK_KP_000' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_000),
    'SDLK_THOUSANDSSEPARATOR' :
        SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_THOUSANDSSEPARATOR),
    'SDLK_DECIMALSEPARATOR' :
        SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_DECIMALSEPARATOR),
    'SDLK_CURRENCYUNIT' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_CURRENCYUNIT),
    'SDLK_CURRENCYSUBUNIT' :
        SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_CURRENCYSUBUNIT),
    'SDLK_KP_LEFTPAREN' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_LEFTPAREN),
    'SDLK_KP_RIGHTPAREN' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_RIGHTPAREN),
    'SDLK_KP_LEFTBRACE' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_LEFTBRACE),
    'SDLK_KP_RIGHTBRACE' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_RIGHTBRACE),
    'SDLK_KP_TAB' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_TAB),
    'SDLK_KP_BACKSPACE' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_BACKSPACE),
    'SDLK_KP_A' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_A),
    'SDLK_KP_B' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_B),
    'SDLK_KP_C' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_C),
    'SDLK_KP_D' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_D),
    'SDLK_KP_E' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_E),
    'SDLK_KP_F' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_F),
    'SDLK_KP_XOR' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_XOR),
    'SDLK_KP_POWER' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_POWER),
    'SDLK_KP_PERCENT' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_PERCENT),
    'SDLK_KP_LESS' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_LESS),
    'SDLK_KP_GREATER' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_GREATER),
    'SDLK_KP_AMPERSAND' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_AMPERSAND),
    'SDLK_KP_DBLAMPERSAND' :
        SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_DBLAMPERSAND),
    'SDLK_KP_VERTICALBAR' :
        SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_VERTICALBAR),
    'SDLK_KP_DBLVERTICALBAR' :
        SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_DBLVERTICALBAR),
    'SDLK_KP_COLON' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_COLON),
    'SDLK_KP_HASH' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_HASH),
    'SDLK_KP_SPACE' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_SPACE),
    'SDLK_KP_AT' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_AT),
    'SDLK_KP_EXCLAM' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_EXCLAM),
    'SDLK_KP_MEMSTORE' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_MEMSTORE),
    'SDLK_KP_MEMRECALL' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_MEMRECALL),
    'SDLK_KP_MEMCLEAR' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_MEMCLEAR),
    'SDLK_KP_MEMADD' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_MEMADD),
    'SDLK_KP_MEMSUBTRACT' :
        SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_MEMSUBTRACT),
    'SDLK_KP_MEMMULTIPLY' :
        SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_MEMMULTIPLY),
    'SDLK_KP_MEMDIVIDE' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_MEMDIVIDE),
    'SDLK_KP_PLUSMINUS' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_PLUSMINUS),
    'SDLK_KP_CLEAR' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_CLEAR),
    'SDLK_KP_CLEARENTRY' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_CLEARENTRY),
    'SDLK_KP_BINARY' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_BINARY),
    'SDLK_KP_OCTAL' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_OCTAL),
    'SDLK_KP_DECIMAL' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_DECIMAL),
    'SDLK_KP_HEXADECIMAL' :
        SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KP_HEXADECIMAL),

    'SDLK_LCTRL' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_LCTRL),
    'SDLK_LSHIFT' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_LSHIFT),
    'SDLK_LALT' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_LALT),
    'SDLK_LGUI' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_LGUI),
    'SDLK_RCTRL' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_RCTRL),
    'SDLK_RSHIFT' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_RSHIFT),
    'SDLK_RALT' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_RALT),
    'SDLK_RGUI' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_RGUI),

    'SDLK_MODE' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_MODE),

    'SDLK_AUDIONEXT' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AUDIONEXT),
    'SDLK_AUDIOPREV' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AUDIOPREV),
    'SDLK_AUDIOSTOP' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AUDIOSTOP),
    'SDLK_AUDIOPLAY' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AUDIOPLAY),
    'SDLK_AUDIOMUTE' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AUDIOMUTE),
    'SDLK_MEDIASELECT' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_MEDIASELECT),
    'SDLK_WWW' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_WWW),
    'SDLK_MAIL' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_MAIL),
    'SDLK_CALCULATOR' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_CALCULATOR),
    'SDLK_COMPUTER' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_COMPUTER),
    'SDLK_AC_SEARCH' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_SEARCH),
    'SDLK_AC_HOME' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_HOME),
    'SDLK_AC_BACK' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_BACK),
    'SDLK_AC_FORWARD' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_FORWARD),
    'SDLK_AC_STOP' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_STOP),
    'SDLK_AC_REFRESH' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_REFRESH),
    'SDLK_AC_BOOKMARKS' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_AC_BOOKMARKS),

    'SDLK_BRIGHTNESSDOWN' :
        SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_BRIGHTNESSDOWN),
    'SDLK_BRIGHTNESSUP' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_BRIGHTNESSUP),
    'SDLK_DISPLAYSWITCH' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_DISPLAYSWITCH),
    'SDLK_KBDILLUMTOGGLE' :
        SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KBDILLUMTOGGLE),
    'SDLK_KBDILLUMDOWN' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KBDILLUMDOWN),
    'SDLK_KBDILLUMUP' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_KBDILLUMUP),
    'SDLK_EJECT' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_EJECT),
    'SDLK_SLEEP' : SDL_SCANCODE_TO_KEYCODE(SDL_SCANCODE_SLEEP)
}

VK_TO_NAME = {
    1 : 'Mouse Left',
    2 : 'Mouse Right',
    3 : 'Control-break',
    4 : 'Mouse Middle',
    5 : 'Mouse X1',
    6 : 'Mouse X2',
    8 : 'Backspace',
    9 : 'Tab',
    12 : 'Clear',
    13 : 'Return',
    16 : 'Shift',
    17 : 'Control',
    18 : 'Alt',
    19 : 'Break',
    20 : 'Capslock',
    21 : 'Hangul*',
    23 : 'Junja*',
    24 : 'Final*',
    25 : 'Hanja*',
    25 : 'Kanji*',
    28 : 'convert*',
    29 : 'nonconvert*',
    30 : 'accept*',
    31 : 'change request*',
    27 : 'Escape',
    32 : 'Space',
    33 : 'Page up',
    34 : 'Page down',
    35 : 'End',
    36 : 'Home',
    37 : 'Left',
    38 : 'Up',
    39 : 'Right',
    40 : 'Down',
    41 : 'Select',
    42 : 'Print',
    43 : 'Execute',
    44 : 'Snapshot',
    45 : 'Insert',
    46 : 'Delete',
    47 : 'Help',
    48 : '0',
    49 : '1',
    50 : '2',
    51 : '3',
    52 : '4',
    53 : '5',
    54 : '6',
    55 : '7',
    56 : '8',
    57 : '9',
    65 : 'A',
    66 : 'B',
    67 : 'C',
    68 : 'D',
    69 : 'E',
    70 : 'F',
    71 : 'G',
    72 : 'H',
    73 : 'I',
    74 : 'J',
    75 : 'K',
    76 : 'L',
    77 : 'M',
    78 : 'N',
    79 : 'O',
    80 : 'P',
    81 : 'Q',
    82 : 'R',
    83 : 'S',
    84 : 'T',
    85 : 'U',
    86 : 'V',
    87 : 'W',
    88 : 'X',
    89 : 'Y',
    90 : 'Z',
    91 : 'Left Window',
    92 : 'Right Window',
    93 : 'Menu',
    95 : 'Sleep',
    96 : '0 numeric',
    97 : '1 numeric',
    98 : '2 numeric',
    99 : '3 numeric',
    100 : '4 numeric',
    101 : '5 numeric',
    102 : '6 numeric',
    103 : '7 numeric',
    104 : '8 numeric',
    105 : '9 numeric',
    106 : '*',
    107 : '+',
    108 : 'Separator',
    109 : '-',
    110 : 'Decimal',
    111 : '/',
    112 : 'F1',
    113 : 'F2',
    114 : 'F3',
    115 : 'F4',
    116 : 'F5',
    117 : 'F6',
    118 : 'F7',
    119 : 'F8',
    120 : 'F9',
    121 : 'F10',
    122 : 'F11',
    123 : 'F12',
    124 : 'F13',
    125 : 'F14',
    126 : 'F15',
    127 : 'F16',
    128 : 'F17',
    129 : 'F18',
    130 : 'F19',
    131 : 'F20',
    132 : 'F21',
    133 : 'F22',
    134 : 'F23',
    135 : 'F24',
    144 : 'Numlock',
    145 : 'Scrollock',
    160 : 'Shift Left',
    161 : 'Shift Right',
    162 : 'Control Left',
    163 : 'Control Right',
    164 : 'Alt Left',
    165 : 'Alt Right',
}

# not used yet, but will be useful in the future
VK_TO_CTRLX = {
    -47 : 'Right menu',
    -31 : 'Left shift',
    -19 : 'Right shift',
    -15 : 'Left menu',
    -13 : 'Left control',
    -6 : 'Right control',
    8 : 'Backspace',
    9 : 'Tab',
    13 : 'Return',
    16 : 'Shift',
    17 : 'Control',
    18 : 'none',
    19 : 'Break',
    20 : 'Capslock',
    27 : 'Escape',
    32 : 'Space',
    33 : 'Page up',
    34 : 'Page down',
    35 : 'End',
    36 : 'Home',
    37 : 'Left',
    38 : 'Up',
    39 : 'Right',
    40 : 'Down',
    41 : 'Select',
    42 : 'Print',
    43 : 'Execute',
    44 : 'Snapshot',
    45 : 'Insert',
    46 : 'Delete',
    47 : 'Help',
    48 : '0',
    49 : '1',
    50 : '2',
    51 : '3',
    52 : '4',
    53 : '5',
    54 : '6',
    55 : '7',
    56 : '8',
    57 : '9',
    65 : 'A',
    66 : 'B',
    67 : 'C',
    68 : 'D',
    69 : 'E',
    70 : 'F',
    71 : 'G',
    72 : 'H',
    73 : 'I',
    74 : 'J',
    75 : 'K',
    76 : 'L',
    77 : 'M',
    78 : 'N',
    79 : 'O',
    80 : 'P',
    81 : 'Q',
    82 : 'R',
    83 : 'S',
    84 : 'T',
    85 : 'U',
    86 : 'V',
    87 : 'W',
    88 : 'X',
    89 : 'Y',
    90 : 'Z',
    91 : 'Left Window',
    92 : 'Right Window',
    93 : 'Menu',
    96 : '0 on numeric',
    97 : '1 on numeric',
    98 : '2 on numeric',
    99 : '3 on numeric',
    100 : '4 on numeric',
    101 : '5 on numeric',
    102 : '6 on numeric',
    103 : '7 on numeric',
    104 : '8 on numeric',
    105 : '9 on numeric',
    106 : '*',
    108 : 'Separator',
    110 : 'Decimal',
    111 : '/',
    112 : 'F1',
    113 : 'F2',
    114 : 'F3',
    115 : 'F4',
    116 : 'F5',
    117 : 'F6',
    118 : 'F7',
    119 : 'F8',
    120 : 'F9',
    121 : 'F10',
    122 : 'F11',
    123 : 'F12',
    144 : 'Numlock',
    145 : 'Scrollock',
    186 : '\xbf',
    187 : '+',
    188 : ',',
    189 : '-',
    190 : '.',
    191 : "'",
    219 : '\xa6',
    220 : '\xba',
    226 : '<'
}

KEY_TO_NAME = {}
for vk, names in VK_TO_SDL.iteritems():
    string_name = VK_TO_NAME.get(vk, None)
    if string_name is None:
        continue
    for name in names:
        KEY_TO_NAME[name] = string_name

def convert_key(value):
    return VK_TO_SDL[value][0]

def main():
    # generate key definition files
    import sys
    sys.path.append('..')
    from chowdren.codewriter import CodeWriter
    from chowdren.common import get_base_path
    from chowdren.stringhash import get_string_int_map
    import os

    writer = CodeWriter(os.path.join(get_base_path(), 'keyconv.cpp'))

    # write keys file
    writer.putln('#include <string>')
    writer.putln('#include "keydef.h"')
    writer.putln('#include "stringcommon.h"')
    writer.putln('')

    writer.putmeth('int translate_vk_to_key', 'int vk')
    writer.putln('switch (vk) {')
    writer.indent()
    for vk, name in VK_TO_SDL.iteritems():
        writer.putln('case %s: return %s;' % (vk, name[0]))
    writer.end_brace()
    writer.putln('return -1;')
    writer.end_brace()
    writer.putln('')

    string_map = {}
    for vk, name in VK_TO_SDL.iteritems():
        string_name = VK_TO_NAME.get(vk, None)
        if string_name is None:
            continue
        string_map[string_name] = name[0]

    writer.putln(get_string_int_map('translate_string_to_key',
                                    'get_key_string_hash',
                                    string_map, False))

    writer.putmeth('std::string translate_vk_to_string',
                   'int vk')
    writer.putln('switch (vk) {')
    writer.indent()
    for vk, name in VK_TO_SDL.iteritems():
        string_name = VK_TO_NAME.get(vk, None)
        if string_name is None:
            continue
        writer.putlnc('case %s: return %r;', vk, string_name)
    writer.end_brace()
    writer.putln('return "";')
    writer.end_brace()
    writer.putln('')

    writer.putmeth('std::string translate_key_to_string',
                   'int key')
    writer.putln('switch (key) {')
    writer.indent()
    for name, string_name in KEY_TO_NAME.iteritems():
        writer.putlnc('case %s: return %r;', name, string_name)
    writer.end_brace()
    writer.putln('return "";')
    writer.end_brace()

    # keys = {}
    # for name, value in SDL_KEYS.iteritems():
    #     if isinstance(value, str):
    #         value = ord(value)
    #     keys[value] = name

    # writer.putmeth('int translate_key_to_index', 'int key')
    # writer.putln('switch (key) {')
    # writer.indent()
    # for index, value in enumerate(sorted(keys)):
    #     name = keys[value]
    #     writer.putlnc('case %s: return %r;', name, index)
    # writer.end_brace()
    # writer.putln('return -1;')
    # writer.end_brace()

    writer.close()

if __name__ == '__main__':
    main()