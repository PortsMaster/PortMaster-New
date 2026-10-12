local GameConfig = {}

-- =============================================================================
-- SCREEN AND SCALING CONSTANTS
-- =============================================================================

GameConfig.VIRTUAL_WIDTH = 640
GameConfig.VIRTUAL_HEIGHT = 480
GameConfig.SCALE = 1.0
GameConfig.TARGET_ASPECT_RATIO = 4 / 3
GameConfig.CRT_ON = true

GameConfig.WINDOW = {
    TITLE = "TetraCore",
    DEFAULT_WIDTH = 640,
    DEFAULT_HEIGHT = 480,
    MIN_WIDTH = 640,
    MIN_HEIGHT = 480,
    MAX_WIDTH = 1280,
    MAX_HEIGHT = 960,
    RESIZABLE = false
}

-- =============================================================================
-- GAME PLAY CONSTANTS
-- =============================================================================

GameConfig.PLAY_CONSTANTS = {
    SCORE = 0,
    HIGH_SCORE = 0,
    RINGS_CLEARED = 0,
    BOARD_LEFT = 192,
    BOARD_RIGHT = 448,
    BOARD_TOP = 112,
    BOARD_BOTTOM = 340,
    CENTER_X = 320,
    CENTER_Y = 240,
    TILE_SIZE = 16
}

-- =============================================================================
-- INPUT CONSTANTS
-- =============================================================================

-- Input timing
GameConfig.INPUT = {
    MENU_REPEAT_DELAY = 0.2,  -- Time in seconds before menu navigation repeats when holding a direction
    REMAPPING_COOLDOWN = 0.2,  -- Cooldown after remapping a key
    GAMEPAD_AXIS_THRESHOLD = 0.5  -- Threshold for gamepad analog stick input
}

-- Default key bindings
GameConfig.DEFAULT_KEY_BINDINGS = {
    keyboard = {
        up = "up",
        down = "down",
        left = "left",
        right = "right",
        select = "return",
        back = "escape",
        ["pause"] = "p",
        ["rotateCore"] = "x",
        ["rotateShape"] = "z",
        ["speedUp"] = "space",
    },
    gamepad = {
        up = "dpup",
        down = "dpdown",
        left = "dpleft",
        right = "dpright",
        select = "a",
        back = "b",
        ["pause"] = "start",
        ["rotateCore"] = "a",
        ["rotateShape"] = "y",
        ["speedUp"] = "x",
    }
}

-- =============================================================================
-- UI LAYOUT CONSTANTS
-- =============================================================================

-- Menu layout
GameConfig.MENU = {
    BUTTON_WIDTH = 128,   -- Width on the virtual canvas
    BUTTON_HEIGHT = 24,   -- Height on the virtual canvas
    BUTTON_SPACING = 5,  -- Spacing between buttons
    TITLE_Y_OFFSET = 0.15 -- Title position as percentage of screen height
}

-- Settings layout
GameConfig.SETTINGS = {
    TITLE_Y_OFFSET = 0.06,          -- Title position as percentage of screen height
    START_Y_OFFSET = 0.15,          -- Starting Y position for controls
    SPACING_OFFSET = 0.15,          -- Vertical spacing between elements
    CONTROL_WIDTH_RATIO = 0.20,     -- Control width as ratio of screen width
    BUTTON_WIDTH_RATIO = 0.18,      -- Button width as ratio of screen width
    BUTTON_HEIGHT_RATIO = 0.08,     -- Button height as ratio of screen height
    CONTROL_HEIGHT_RATIO = 0.06,    -- Control height as ratio of screen height
    BOTTOM_BUTTON_MARGIN = 5,      -- Margin from bottom of screen for buttons
    SLIDER_STEP_DIVISOR = 5,       -- Slider adjustment step (range / 20)
    DROPDOWN_Y_OFFSET = 8,         -- Y offset for dropdowns
    MAX_VISIBLE_DROPDOWN_OPTIONS = 6
}

-- Controls layout
GameConfig.CONTROLS = {
    TITLE_Y_OFFSET = 0.05,          -- Title position
    HEADER_Y_OFFSET = 0.15,         -- Section headers position
    START_Y_OFFSET = 0.15,          -- Starting Y position for controls
    SPACING_OFFSET = 0.07,          -- Vertical spacing between controls
    COLUMN_WIDTH_RATIO = 0.42,      -- Column width as ratio of screen width
    BUTTON_WIDTH_RATIO = 0.15,      -- Button width as ratio of screen width
    BUTTON_HEIGHT_RATIO = 0.06,     -- Button height as ratio of screen height
    KEYBOARD_X_OFFSET = 50,        -- X offset for keyboard column
    GAMEPAD_X_OFFSET = 4,          -- X offset for gamepad column
    ACTION_LABEL_X_RATIO = 0.2,     -- Action label X position as ratio of screen width
    ACTION_LABEL_Y_OFFSET = 0.02,   -- Y offset for action labels
    MODAL_WIDTH_RATIO = 0.4,        -- Modal dialog width as ratio of screen width
    MODAL_HEIGHT_RATIO = 0.2,       -- Modal dialog height as ratio of screen height
    MODAL_X_RATIO = 0.3,            -- Modal dialog X position as ratio of screen width
    MODAL_Y_RATIO = 0.4             -- Modal dialog Y position as ratio of screen height
}

-- =============================================================================
-- UI COMPONENT CONSTANTS
-- =============================================================================

-- Initialize UI table
GameConfig.UI = {}

-- Button styling
GameConfig.UI.BUTTON = {
    CORNER_RADIUS = 0,              -- Corner radius base value
    BORDER_WIDTH = 2,               -- Border width base value
    FONT_SIZE = 16,                 -- Base font size for virtual canvas
    POP_SCALE = 1.25,               -- How dramatic the bounce effect is on select
    -- Colors
    NORMAL_COLOR = {1.0, 1.0, 1.0, 1},
    HOVER_COLOR = {1, 0, 0},
    DISABLED_COLOR = {0.3, 0.3, 0.3, 0.7},
    TEXT_COLOR = {1, 1, 1, 1},
    DISABLED_TEXT_COLOR = {0.7, 0.7, 0.7, 0.7},
    BORDER_COLOR = {1, 1, 1, 1},
    DISABLED_BORDER_COLOR = {0.5, 0.5, 0.5, 0.5},
    SELECTION_HIGHLIGHT_COLOR = {1, 0, 0, 0.2},
}

-- Slider styling
GameConfig.UI.SLIDER = {
    TRACK_HEIGHT = 5,              -- Visual height of slider track
    CORNER_RADIUS_SCALE = 0,        -- Corner radius multiplied by GUI scale
    HANDLE_WIDTH_SCALE = 8,        -- Handle width multiplied by GUI scale
    HANDLE_HEIGHT_OFFSET = 4,       -- Additional height for handle beyond track
    HANDLE_CORNER_RADIUS = 0,       -- Corner radius for handle
    LABEL_Y_OFFSET = 2,             -- Distance between label and slider
    FONT_SIZE = 16,                 -- Font size for labels
    CLICK_AREA_PADDING = 2,        -- Extra clickable area around slider
    -- Colors
    BAR_COLOR = {0.0, 0.0, 0.0, 1},
    FILL_COLOR = {1, 1, 1},
    HANDLE_COLOR = {0.65, 0.65, 0.65, 1},
    BORDER_COLOR = {1,1,1,1},
    TEXT_COLOR = {1, 1, 1, 1},
    HOVER_COLOR = {1, 0, 0, 0.7},
}

-- =============================================================================
-- FONT CONSTANTS
-- =============================================================================

GameConfig.FONTS = {
    TITLE = 32,          -- Menu titles
    SETTINGS_TITLE = 16, -- Settings screen title
    CONTROLS_TITLE = 16, -- Controls screen title
    LABEL = 16,          -- General labels
    BUTTON = 16,         -- Button text
    SLIDER = 16,         -- Slider labels
    DROPDOWN = 16,       -- Dropdown text
    SCORE = 16,          -- Game score display
    MESSAGE = 16,        -- Game over message

    -- Font paths
    DEFAULT_FONT = "assets/fonts/ease.ttf",
    FALLBACK_FONTS = {
        "assets/fonts/NotoSansBengali-Regular.ttf",
        "assets/fonts/NotoSansJP-Regular.ttf",
        "assets/fonts/NotoSansKR-Regular.ttf",
        "assets/fonts/NotoSansSC-Regular.ttf",
        "assets/fonts/NotoSansDevanagari-Regular.ttf"
    }
}

-- =============================================================================
-- AUDIO CONSTANTS
-- =============================================================================

GameConfig.AUDIO = {
    DEFAULT_MUSIC_VOLUME = 0.55,
    DEFAULT_EFFECTS_VOLUME = 1.0,

    -- Audio file paths
    MENU_MUSIC = "assets/music/menu.ogg",
    SOUNDS = {
        MENU_MOVE = "assets/sounds/click.mp3",
        MENU_SELECT = "assets/sounds/click.mp3",
        MENU_BACK = "assets/sounds/click.mp3",
    }
}

-- =============================================================================
-- GAME STATE CONSTANTS
-- =============================================================================

-- Default game settings
GameConfig.DEFAULT_SETTINGS = {
    musicVolume = 0.55,
    effectsVolume = 1.0,
    highScore = 0,
    ringsCleared = 0,
    screenSize = {
        width = 640,
        height = 480
    },
    language = "en",
    crtOn = true,
}

-- Available screen sizes
GameConfig.SCREEN_SIZES = {
	{width = 640, height = 480, label = "640 x 480"},
    {width = 1280, height = 960, label = "1280 x 960"},
}

-- =============================================================================
-- ASSET PATHS
-- =============================================================================

GameConfig.ASSETS = {
    FONTS = GameConfig.FONTS,  -- Reference to fonts section
    AUDIO = GameConfig.AUDIO   -- Reference to audio section
}

-- =============================================================================
-- CONFIGURATION FLAGS
-- =============================================================================

GameConfig.DEBUG = {
    ENABLE_CONSOLE = false,     -- Enable console output
    PRINT_FONT_LOADING = false -- Print font loading debug info
}

-- Game modules configuration
GameConfig.MODULES = {
    JOYSTICK = true,   -- Enable joystick/gamepad support
    PHYSICS = false    -- Disable physics module (not used)
}


return GameConfig
