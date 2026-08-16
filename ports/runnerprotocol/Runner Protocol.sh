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

GAMEDIR="/$directory/ports/runnerprotocol"
cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Pure stdlib Python drawing straight to the framebuffer - no SDL, no
# packages. It needs a python3 interpreter, which ArkOS-family firmware ships.
if ! command -v python3 > /dev/null 2>&1; then
  echo "RUNNER PROTOCOL needs python3, which this firmware does not ship."
  echo "ArkOS-family firmware has it. See README.md."
  sleep 5
  pm_finish
  exit 1
fi

# history and identity live in conf/, which survives port updates
mkdir -p "$GAMEDIR/conf"
export RUNNER_HIST="$GAMEDIR/conf/usage_hist.jsonl"

$ESUDO chmod 666 /dev/uinput 2>/dev/null
$GPTOKEYB "python3" -c "$GAMEDIR/runnerprotocol.gptk" &

# the receiver listens on :8788 for the OPTIONAL PC companion pusher; it
# exits cleanly on its own if something else already owns the port
$ESUDO env RUNNER_HIST="$RUNNER_HIST" python3 "$GAMEDIR/runnerprotocol/receiver.py" > /dev/null 2>&1 &

$ESUDO env RUNNER_HIST="$RUNNER_HIST" python3 "$GAMEDIR/runnerprotocol/runner.py"

pm_finish
