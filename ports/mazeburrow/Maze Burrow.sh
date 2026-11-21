#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/$directory/ports/mazeburrow"
FULL_MARKER="$GAMEDIR/gamedata/.mazeburrow_setup_complete"
DEMO_MARKER="$GAMEDIR/demodata/.mazeburrow_demo_setup_complete"
PREPARE="$GAMEDIR/patch/prepare_maze_first_run.py"
runtime="dotnet-6.0.36"
netdir="$HOME/dotnet"

cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

mkdir -p "$GAMEDIR/gamedata" "$GAMEDIR/savedata"

# Install / update from any dropped download. maze-burrow-linux.zip (full game) and
# MazeBurrow_v0_7_LinuxInstaller.zip (demo) are recognised automatically; a newer or different
# zip dropped later is picked up here too, and the full game supersedes the demo.
python3 "$PREPARE" --pending
if [ $? -eq 0 ]; then
  pm_message "Preparing game files, this can take a minute..." --title "Please wait"
  python3 "$PREPARE"
  setup_rc=$?
  if [ $setup_rc -ne 0 ] && [ ! -f "$FULL_MARKER" ] && [ ! -f "$DEMO_MARKER" ]; then
    pm_show_error "First-run setup failed. Check log.txt, then launch again." --title "Setup failed"
    exit 1
  fi
fi

# Run the full game when it is installed, otherwise the demo.
if [ -f "$FULL_MARKER" ]; then
  mode="full"
elif [ -f "$DEMO_MARKER" ]; then
  mode="demo"
else
  pm_show_error "No game files found. Put maze-burrow-linux.zip (full game) or MazeBurrow_v0_7_LinuxInstaller.zip (demo) in the mazeburrow folder." --title "Game not found"
  exit 1
fi
echo "[Maze Burrow] Launching: $mode"

if [ ! -f "$controlfolder/libs/${runtime}.squashfs" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_show_error "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info." --title "PortMaster update needed"
    exit 1
  fi
  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${runtime}.squashfs"
fi
$ESUDO mkdir -p "$netdir"
$ESUDO umount "$netdir" || true
$ESUDO mount "$controlfolder/libs/${runtime}.squashfs" "$netdir"

export DOTNET_ROOT="$netdir"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

# MonoGame DesktopGL needs gl4es named explicitly, but only when PortMaster enabled it
if [[ ":$LD_LIBRARY_PATH:" == *":$GAMEDIR/gl4es:"* ]]; then
  export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es/libGL.so.1"
  export SDL_VIDEO_EGL_DRIVER="$GAMEDIR/gl4es/libEGL.so.1"
fi

if [ "$mode" = "full" ]; then
  bind_directories "$XDG_DATA_HOME/Kimimaru/Maze Burrow" "$GAMEDIR/savedata"
fi

if [ "$mode" = "demo" ]; then
  # The demo only has keyboard controls, so gptokeyb2 needs a key mapping for the gamepad
  $GPTOKEYB2 "dotnet" -c "$GAMEDIR/demo.gptk" > /dev/null 2>&1 &
else
  $GPTOKEYB2 "dotnet" > /dev/null 2>&1 &
fi

pm_platform_helper "$netdir/dotnet"

if [ "$mode" = "demo" ]; then
  # The demo keeps SaveData.sav, custom levels and crash logs in its working directory,
  # so run it from savedata/demo (no symlinks: SD cards are often FAT/exFAT).
  mkdir -p "$GAMEDIR/savedata/demo"
  cd "$GAMEDIR/savedata/demo"
  SDL_TOUCH_MOUSE_EVENTS=0 "$netdir/dotnet" "$GAMEDIR/demodata/PuzzleGameGL.dll"
else
  cd "$GAMEDIR/gamedata"
  SDL_TOUCH_MOUSE_EVENTS=0 "$netdir/dotnet" PuzzleGameGL.dll
fi

$ESUDO umount "$netdir"
pm_finish
