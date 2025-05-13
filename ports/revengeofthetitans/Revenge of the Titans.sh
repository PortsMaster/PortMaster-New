#!/bin/bash

# PortMaster preamble
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


SCRIPT="`basename \"$0\"`"
GAMEDIR="/$directory/ports/revengeofthetitans"
LOGFILE="${GAMEDIR}/${SCRIPT}.log"
INSTALLDIR="$GAMEDIR/install"
SAVE_SOURCE="${HOME}/.revenge_of_the_titans_1.80"
SAVE_TARGET="$GAMEDIR/user/saves"

HEAP_SIZE=384
if [ ${CFW_NAME} == "knulli"  ]; then
  HEAP_SIZE=256
fi

cd $GAMEDIR

# Logging
> "${GAMEDIR}/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Adjust these to your paths and desired java version
java_runtime="zulu17.54.21-ca-jre17.0.13-linux"


if [ "$DISPLAY_WIDTH" -gt 1280 ]; then
	echo "Display width is over 1280px"
	gptk_filename="revenge1920.gptk"
elif [ "$DISPLAY_WIDTH" -gt 720 ]; then
	echo "Display width is over 720px"
	gptk_filename="revenge1280.gptk"
else
	echo "Display width is 720px or less"
	gptk_filename="revenge.gptk"
fi

pm_message "home dir ${HOME}"

# Create directory temp game files
CONFDIR="$GAMEDIR/user/"
$ESUDO mkdir -p -m 0755 "${CONFDIR}"
rm -rf "${HOME}/Puppygames"

TARFILE=$(ls "$INSTALLDIR"/*.tar 2>/dev/null | head -n 1)
if [ -n "$TARFILE" ]; then
    pm_message "Unpacking game files, this takes a couple of minutes, please be patient"
	zcat "$TARFILE" > $INSTALLDIR/tmp_extract
    tar -xf $INSTALLDIR/tmp_extract -C $INSTALLDIR
    mv "$INSTALLDIR/revenge/"* "$GAMEDIR/"\

	rmdir "$INSTALLDIR/revenge"
    rm -f "$INSTALLDIR/tmp_extract"
    rm -f "$TARFILE"
    pm_message "Game files extracted and installed to $GAMEDIR."
fi

[ ! -f "${GAMEDIR}/RevengeOfTheTitans.jar" ] && echo "Missig game data!"
[ -f "${GAMEDIR}/data-steam.jar" ] && echo "Steam game data is not compatible!"

# Sync save data for easier backup and restore, do not overwrite newer save files
mkdir -p -m 0755 "$SAVE_SOURCE" "$SAVE_TARGET" 
if command -v rsync &> /dev/null; then
	[ -d "$SAVE_SOURCE" ] && rsync -au "$SAVE_TARGET/" "$SAVE_SOURCE/"
	# [ -d "$SAVE_SOURCE" ] && cp -a "$SAVE_TARGET/." "$SAVE_SOURCE/"
fi

# set default profile for knulli if it doesn't exist already
if [[ ! -f "${SAVE_SOURCE}/prefs.json" && ${CFW_NAME} == "knulli"  ]]; then
  cp "$GAMEDIR/prefs.json" "${SAVE_SOURCE}/prefs.json"
  pm_message "Saved default profile to ${SAVE_SOURCE}"
fi

# Mount Weston runtime
weston_dir=/tmp/weston
$ESUDO mkdir -p "${weston_dir}"
weston_runtime="weston_pkg_0.2"
if [ ! -f "$controlfolder/libs/${weston_runtime}.squashfs" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
  fi
  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${weston_runtime}.squashfs"
fi
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
fi
$ESUDO mount "$controlfolder/libs/${weston_runtime}.squashfs" "${weston_dir}"

[[ ! -d "${GAMEDIR}" ]] && mkdir -m 0755 "${GAMEDIR}"

# Mount Java runtime
export JAVA_HOME="/tmp/javaruntime/"
$ESUDO mkdir -p "${JAVA_HOME}"
if [ ! -f "$controlfolder/libs/${java_runtime}.squashfs" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
  fi
  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${java_runtime}.squashfs"
fi
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${JAVA_HOME}"
fi

$ESUDO mount "$controlfolder/libs/${java_runtime}.squashfs" "${JAVA_HOME}"
export PATH="$JAVA_HOME/bin:$PATH"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

cd $GAMEDIR
$GPTOKEYB2 "java" -c "$GAMEDIR/$gptk_filename" &

$ESUDO env HOME=$HOME CRUSTY_SHOW_CURSOR=0 $weston_dir/westonwrap.sh headless noop kiosk crusty_glx_gl4es \
PATH="$PATH" JAVA_HOME="$JAVA_HOME" XDG_DATA_HOME="$GAMEDIR" WAYLAND_DISPLAY= \
/tmp/javaruntime/bin/java -server \
	-javaagent:${GAMEDIR}/alert-override.jar \
	-Djava.util.prefs.userRoot=${HOME}/Puppygames \
    -Djava.library.path="${GAMEDIR}/aarch64" \
    -Dorg.lwjgl.librarypath="${GAMEDIR}/aarch64" \
    -Dorg.lwjgl.util.NoChecks=false \
    -Djava.net.preferIPv4Stack=true \
    -Dnet.puppygames.applet.Launcher.resources=resources-hib.dat \
    -Dnet.puppygames.applet.Game.gameResource=game.hib \
    -XX:MaxGCPauseMillis=3 \
    -XX:+TieredCompilation \
    -XX:Tier2CompileThreshold=70000 \
    -XX:+DoEscapeAnalysis \
    -Xms64m \
    -Xmx${HEAP_SIZE}m \
    -cp RevengeOfTheTitans.jar:music.jar:fx-mono.jar:fx-stereo.jar:images.jar:gfx.jar:fonts.jar:data-hib.jar:common-cp-java6.jar:common.jar:spgl-lite.jar:aarch64/lwjgl.jar:lwjgl_util.jar:gson.jar:jinput.jar:ogg.jar:gamecommerce.jar:steampuppy-public.jar:remote.jar \
    net.puppygames.applet.Launcher \
    "$@" 

if command -v rsync &> /dev/null; then
	# sync save data to game dir, delete orphaned files
	rsync -av --delete "$SAVE_SOURCE/" "$SAVE_TARGET/"
	# cp -a "$SAVE_SOURCE/." "$SAVE_TARGET/"
	pm_message "Save data backed to: $SAVE_TARGET"
fi

pm_finish
