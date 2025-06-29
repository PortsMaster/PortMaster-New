# Menu Launcher for Portmaster v0.3.0

This is a menu launcher for Portmaster that allows selecting configurable options through a `menu.items` file.

- supported: custom menu.items
- supported: Joystick Mapper

---

## How to add or remove menu items

To modify the menu options, edit the file:

```
menu.items
```

Each line represents a menu option shown to the user.

---

## Menu output and exit codes

- If **Exit** is selected, the exit code will be `0`.
- If the script fails or encounters any error, the exit code will be `1`.
- For selected menu options, the exit codes are:

| Option       | Exit Code (`exitcode`) |
|--------------|-----------------------|
| Option 1     | 2                     |
| Option 2     | 3                     |
| Option 5     | 6                     |

---

## Integration with your Portmaster script

To integrate this menu into your Portmaster launcher, add the following to your script:

```bash
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

if [ -n "$ESUDO" ]; then
  ESUDO="${ESUDO},SDL_GAMECONTROLLERCONFIG"
fi

# MENU
$GPTOKEYB2 "launch_menu" -c "./menu/controls.ini" &
$GAMEDIR/menu/launch_menu.$DEVICE_ARCH $GAMEDIR/menu/menu.items $GAMEDIR/menu/FiraCode-Regular.ttf

# MENU for GODOT
$GPTOKEYB2 "launch_menu" -c "./menu/controls.ini" &
$GAMEDIR/menu/launch_menu.$DEVICE_ARCH $GAMEDIR/menu/menu.items $GAMEDIR/menu/FiraCode-Regular.ttf --godot


# Capture the exit code
selection=$?

if [ -f "$GAMEDIR/controller.map" ]; then
    echo load controller.map
    export SDL_GAMECONTROLLERCONFIG="$(cat $GAMEDIR/controller.map)"
    echo $SDL_GAMECONTROLLERCONFIG
fi

env_vars=""

# Check what was selected
case $selection in
    0)
        pm_finish
        exit 2
        ;;
    1)
        echo "[MENU] ERROR"
        pm_finish
        exit 1
        ;;
    2)
        echo "[MENU] Native Control"
        control_subfix="native"
        ;;
    3)
        echo "[MENU] Virtual Control"
        env_vars="$env_vars CRUSTY_BLOCK_INPUT=1"
        control_subfix="virtual"
        ;;
    4)
        echo "[MENU] Lightweight Native Control"
        env_vars="$env_vars SHADER_PASSTHROUGH="
        ;;
    5)
        echo "[MENU] Lightweight Virtual Control"
        env_vars="$env_vars CRUSTY_BLOCK_INPUT=1"
        env_vars="$env_vars SHADER_PASSTHROUGH="
        control_subfix="virtual"
        ;;
    *)
        echo "[MENU] Unknown option: $selection"
        pm_finish
        exit 3
        ;;
esac

__pids=$(ps aux | grep '[g]ptokeyb2' | grep 'launch_menu' | awk '{print $2}')

if [ -n "$__pids" ]; then
  $ESUDO kill $__pids
fi

sleep 3
```

---

Ready to use your custom menu launcher in Portmaster!

