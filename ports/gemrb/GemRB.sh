#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
if [ -z ${TASKSET+x} ]; then
  source $controlfolder/tasksetter
fi

get_controls

## TODO: Change to PortMaster/tty when Johnnyonflame merges the changes in,
CUR_TTY=/dev/tty0

PORTDIR="/$directory/ports"
GAMEDIR="$PORTDIR/gemrb"
cd $GAMEDIR

width=55
height=15

$ESUDO chmod 666 $CUR_TTY
$ESUDO touch log.txt
$ESUDO chmod 666 log.txt
$ESUDO chmod 666 /dev/uinput
export TERM=linux
printf "\033c" > $CUR_TTY

## Converts path names to game codes
PROPER_GAME_ID() {
  GAMENAME=$(echo "$1" | tr '[:upper:]' '[:lower:]')

  case $GAMENAME in
    bg2|baldur*gate\ 2|baldur*gate\ ii)
      echo "bg2"
      ;;
    bg1|baldur*gate)
      echo "bg1"
      ;;
    bg2ee)
      echo "bg2ee"
      ;;
    pst|planescape*)
      echo "pst"
      ;;
    how|*how*|*totl*)
      echo "how"
      ;;
    iwd|icewind\ dale)
      echo "iwd"
      ;;
    iwd2|icewind\ dale\ 2)
      echo "iwd2"
      ;;
    demo)
      echo "demo"
      ;;
    *)
      echo $GAMENAME
      ;;
  esac
}

## Converts path name to proper name
PROPER_GAME_NAME() {
  GAMEID=$(PROPER_GAME_ID "$1")
  case $GAMEID in
    bg1)
      echo "Baldurs Gate"
      ;;
    bg2)
      echo "Baldurs Gate II"
      ;;
    bg2ee)
      echo "Baldurs Gate II EE"
      ;;
    pst)
      echo "Planescape Torment"
      ;;
    how)
      echo "Icewind Dale - HoW or ToTL"
      ;;
    iwd)
      echo "Icewind Dale"
      ;;
    iwd2)
      echo "Icewind Dale 2"
      ;;
    demo)
      echo "Demo Game"
      ;;
    *)
      echo "$1"
      ;;
  esac
}

# Extract the game if it exists
if [ -f "$GAMEDIR/engine.zip" ]; then
  if [ -d "$GAMEDIR/engine" ]; then
    $ESUDO echo "Removing old engine."
    $ESUDO rm -fRv "$GAMEDIR/engine"
  fi
  # Extract the engine from the build zip.
  $ESUDO unzip "$GAMEDIR/engine.zip"
  $ESUDO mv -fv "$GAMEDIR/engine/gemrb" "$GAMEDIR/gemrb"
  $ESUDO rm -f "$GAMEDIR/engine.zip"
fi

# Copy over the demo game
if [ -d "$GAMEDIR/engine/demo" ]; then
  # Copy demo over, but dont overwrite just incase it has been modified.
  if [ -d "$GAMEDIR/games/demo" ]; then
    $ESUDO rm -fRv "$GAMEDIR/engine/demo"
  else
    $ESUDO mv -fv "$GAMEDIR/engine/demo" "$GAMEDIR/games/demo"
  fi
fi

# Select a game.
if [ -z ${GAME+x} ]; then

  printf "\e[?25h" > $CUR_TTY
  dialog --clear > $CUR_TTY

  $GPTOKEYB "dialog" -c "${GAMEDIR}/gemrb-menu.gptk" &

  # Find all the games, each game has 'chitin.key' so we can use that to find them.
  readarray -d '' GAMEEXE < <(find games/ -maxdepth 2 -iname 'chitin.key' -print0)
  IFS=$'\n' GAMEEXES=($(sort <<<"${GAMEEXE[*]}"))
  unset IFS

  if [ "${#GAMEEXES[@]}" -eq 0 ]; then
    dialog \
    --backtitle "Gem RB" \
    --title "[ Error ]" \
    --clear \
    --msgbox "No Games Found!" $height $width > $CUR_TTY

    printf "\033c" > $CUR_TTY
    $ESUDO kill -9 $(pidof gptokeyb)
    $ESUDO systemctl restart oga_events &
    exit 1;
  fi

  VN_CHOICES=()
  VN_DIRS=()

  OFFSET=0
  if [ -f "${GAMEDIR}/save/last_game" ]; then
    LAST_GAME=$(cat "${GAMEDIR}/save/last_game")
    LAST_NAME=$(PROPER_GAME_NAME "$LAST_GAME")
    VN_CHOICES+=(0 "${LAST_NAME}")
    VN_DIRS+=("$LAST_GAME")
    echo "0 -> **${LAST_GAME}** -> ${LAST_NAME}" 2>&1 | tee -a ./log.txt
    OFFSET=1
  else
    LAST_GAME=""
  fi

  for i in "${!GAMEEXES[@]}"; do
    VN_PATH=$(dirname "${GAMEEXES[$i]}")
    VN_DIR=${VN_PATH##*/}
    VN_NAME=$(PROPER_GAME_NAME "$VN_DIR")

    if [ "$VN_DIR" = "$LAST_GAME" ]; then
      OFFSET=$(($OFFSET-1))
    else
      i=$(($i+$OFFSET))
      echo "$i -> ${VN_DIR} -> ${VN_NAME}" 2>&1 | tee -a ./log.txt
      VN_SHORTCUT="$PORTDIR/${VN_NAME}.sh"
      VN_DIRS+=("${VN_DIR}")
      if [ -f "$PORTDIR/${VN_DIR}.sh" ]; then
        VN_CHOICES+=($i "${VN_NAME} - Installed")
      else
        VN_CHOICES+=($i "${VN_NAME}")
      fi
    fi
  done

  IN_CHOICES=( "${VN_CHOICES[@]}" )

  VN_CHOICES+=("" "")
  VN_CHOICES+=("i" "Install Game Shortcut")

  if [ "${#VN_DIRS[@]}" -eq 1 ]; then
    GAME="${VN_DIRS[0]}"
  else
    GAME_SELECT=(dialog \
      --backtitle "GemRB" \
      --title "[ Select Game ]" \
      --clear \
      --menu "Choose Your Game" $height $width 15)


    VN_CHOICE=$("${GAME_SELECT[@]}" "${VN_CHOICES[@]}" 2>&1 > $CUR_TTY)
    if [ $? != 0 ]; then
      $ESUDO kill -9 $(pidof gptokeyb)
      $ESUDO systemctl restart oga_events &
      echo "QUIT: ${VN_CHOICE}" 2>&1 | $ESUDO tee -a ./log.txt
      printf "\033c" > $CUR_TTY
      exit 1;
    fi

    if [ $VN_CHOICE = "i" ]; then
      IN_SELECT=(dialog \
        --backtitle "Gem RB" \
        --title "[ Install Game Shortcut ]" \
        --clear \
        --menu "Choose Your Game" $height $width 15)

      IN_CHOICE=$("${IN_SELECT[@]}" "${IN_CHOICES[@]}" 2>&1 > $CUR_TTY)
      if [ $? != 0 ]; then
        $ESUDO kill -9 $(pidof gptokeyb)
        $ESUDO systemctl restart oga_events &
        echo "QUIT: ${IN_CHOICE}" 2>&1 | tee -a ./log.txt
        printf "\033c" > $CUR_TTY
        exit 1;
      fi

      IN_GAME="${VN_DIRS[$IN_CHOICE]}"
      IN_GAME_NAME=$(PROPER_GAME_NAME "$IN_GAME")

      printf "#!/usr/bin/bash\nGAME=\"$IN_GAME\" $PORTDIR/GemRB.sh\n" | $ESUDO tee "$PORTDIR/$IN_GAME_NAME.sh"

      dialog \
        --backtitle "Gem RB" \
        --title "[ Success ]" \
        --clear \
        --msgbox "Installed shortcut for $IN_GAME_NAME\n\nRestart Emulation Station to find the game under ports." $height $width > $CUR_TTY

      $ESUDO kill -9 $(pidof gptokeyb)
      $ESUDO systemctl restart oga_events &
      printf "\033c" > $CUR_TTY
      exit 0;
    fi

    echo "C ${VN_CHOICE} -> ${VN_DIRS[$VN_CHOICE]}" 2>&1 | tee -a ./log.txt

    $ESUDO kill -9 $(pidof gptokeyb)

    GAME="${VN_DIRS[$VN_CHOICE]}"
  fi

  if [ ! -d "${GAMEDIR}/save" ]; then
    $ESUDO mkdir "${GAMEDIR}/save"
  fi
  # Save the selected game as the last game
  printf "$GAME" | $ESUDO tee "${GAMEDIR}/save/last_game"
fi

printf "\033c" > $CUR_TTY
## RUN SCRIPT HERE

# Install appropriate GemRB.cfg
GAMEID=$(PROPER_GAME_ID "$GAME")

if [ ! -f "${GAMEDIR}/games/${GAME}/GemRB.cfg" ]; then
  if [ -f "${GAMEDIR}/configs/GemRB.cfg.${GAMEID}" ]; then
    # Does one for this game exist?
    $ESUDO cp -v "${GAMEDIR}/configs/GemRB.cfg.${GAMEID}" "${GAMEDIR}/games/${GAME}/GemRB.cfg"
  else
    # Otherwise use the default one
    $ESUDO cp -v "${GAMEDIR}/configs/GemRB.cfg.default" "${GAMEDIR}/games/${GAME}/GemRB.cfg"
  fi
fi

# Use game specific controller config if it exists.
if [ -f "${GAMEDIR}/gemrb-${GAMEID}.gptk" ]; then
  GPTOKEYB_CFG="${GAMEDIR}/gemrb-${GAMEID}.gptk"
else
  GPTOKEYB_CFG="${GAMEDIR}/gemrb.gptk"
fi

export TEXTINPUTPRESET="Name"
export TEXTINPUTINTERACTIVE="Y"
export TEXTINPUTNOAUTOCAPITALS="Y"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

export PYTHONHOME="$GAMEDIR"
export LD_LIBRARY_PATH="$GAMEDIR/lib:$LD_LIBRARY_PATH"

$GPTOKEYB "gemrb" -c "${GPTOKEYB_CFG}" textinput &
$TASKSET ./gemrb -c "${GAMEDIR}/games/${GAME}/GemRB.cfg" "${GAMEDIR}/games/${GAME}/" 2>&1 | $ESUDO tee -a ./log.txt

$ESUDO kill -9 $(pidof gptokeyb)
unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
$ESUDO systemctl restart oga_events &

# Disable console
printf "\033c" > $CUR_TTY
