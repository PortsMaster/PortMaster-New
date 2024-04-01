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

hotkey="Select"
rklib="libmoonlight-rk.so.rot"
height="15"
width="55"

if [[ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]]; then
  param_device="anbernic"
  if [[ -e "/dev/input/by-path/platform-rg351v-keys-event" ]]; then
    $ESUDO setfont /usr/share/consolefonts/Lat7-Terminus20x10.psf.gz
    rklib="libmoonlight-rk.so.unrot"
    height="20"
    width="60"
  fi
elif [[ -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
  if [[ ! -z $(cat /etc/emulationstation/es_input.cfg | grep "190000004b4800000010000001010000") ]]; then
    param_device="oga"
    hotkey="Minus"
  else
    param_device="rk2020"
  fi
elif [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]]; then
  param_device="ogs"
  if [[ -e "/opt/.retrooz/device" ]]; then
    param_device="$(cat /opt/.retrooz/device)"
    if [[ "$param_device" == *"rgb10max2native"* ]]; then
      param_device="rgb10maxnative"
    elif [[ "$param_device" == *"rgb10max2top"* ]]; then
      param_device="rgb10maxtop"
    fi
  fi
  if [[ -e "/boot/rk3326-rg351mp-linux.dtb" ]] || [ $(cat "/storage/.config/.OS_ARCH") == "RG351MP" ]; then
    rklib="libmoonlight-rk.so.unrot"
    $ESUDO setfont /usr/share/consolefonts/Lat7-Terminus20x10.psf.gz
    height="20"
    width="60"
  fi
  if [ "$(cat ~/.config/.OS)" == "ArkOS" ] && [ "$(cat ~/.config/.DEVICE)" == "RGB10MAX" ]; then
    $ESUDO setfont /usr/share/consolefonts/Lat7-Terminus20x10.psf.gz
    hotkey="Top Left Button"
    height="30"
    width="110"
    export HOTKEY="guide"
  fi
elif [[ -e "/boot/rk3566.dtb" ]]; then
  rklib="libmoonlight-rk.so.unrot"
  $ESUDO setfont /usr/share/consolefonts/Lat7-Terminus20x10.psf.gz
  height="20"
  width="60"
  hotkey="L3"
else
  param_device="chi"
  hotkey="1"
  $ESUDO setfont /usr/share/consolefonts/Lat7-Terminus20x10.psf.gz
  rklib="libmoonlight-rk.so.unrot"
  height="20"
  width="60"
fi

source $controlfolder/control.txt
get_controls

GAMEDIR="/$directory/ports/moonlight"
cp -f $GAMEDIR/libs/$rklib $GAMEDIR/libs/libmoonlight-rk.so

$ESUDO chmod 666 /dev/tty0
export TERM=linux
export XDG_RUNTIME_DIR=/run/user/$UID/
printf "\033c" > /dev/tty0

# fix permissions
$ESUDO chown root:video /dev/vpu_service
$ESUDO chmod 660 /dev/vpu_service
$ESUDO chown root:video /dev/hevc_service
$ESUDO chmod 660 /dev/hevc_service

dpkg -s "dialog" &>/dev/null
if [ "$?" != "0" ]; then
  $ESUDO apt update && $ESUDO apt install -y dialog --no-install-recommends
fi

mapfile settings < $GAMEDIR/settings.txt

SaveSettings() {
  for j in "${settings[@]}"
  do
    echo $j 
  done > $GAMEDIR/settings.txt
}

Steam() {
    IP="$(cat $GAMEDIR/ip.txt)"

    if [ -z "$IP" ]; then
        Pair
    else
        ip=$(echo ${settings[0]}|tr -d '\n')
        fps=$(echo ${settings[1]}|tr -d '\n')
        res=$(echo ${settings[2]}|tr -d '\n')
        app=$(echo ${settings[3]}|tr -d '\n')
        platform=$(echo ${settings[4]}|tr -d '\n')

        $ESUDO kill -9 $(pidof oga_controls)
        if [[ $platform == "rk" ]]; then
          if [[ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]]; then
            $ESUDO rg351p-js2xbox --silent -t oga_joypad &
            sleep 0.5
            if [[ -e "/dev/input/by-path/platform-rg351v-keys-event" ]]; then
              $ESUDO ln -s /dev/input/event4 /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
            else
              $ESUDO ln -s /dev/input/event3 /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
            fi
            sleep 0.5
            $ESUDO chmod 777 /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
          fi
        fi
        printf "\033c" > /dev/tty0

        export LD_LIBRARY_PATH="$GAMEDIR/libs:/usr/lib"
        #$GAMEDIR/moonlight stream -fps $fps $res --unsupported --nosops -mapping $GAMEDIR/gamecontrollerdb.txt -app $app -platform $platform $ip > /dev/tty0
        cd $GAMEDIR/quit
        $ESUDO $controlfolder/oga_controls moonlight $param_device &
        $GAMEDIR/moonlight stream -fps $fps $res -mapping $controlfolder/gamecontrollerdb.txt -app $app -platform $platform $ip -codec h264 -bitrate 15000 -quitappafter
        $ESUDO kill -9 $(pidof oga_controls)
        if [[ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]]; then
          $ESUDO kill -9 $(pidof rg351p-js2xbox)
          $ESUDO rm /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
        fi
        unset LD_LIBRARY_PATH
        exit
    fi
}

Platform() {
    cmd=(dialog --clear --backtitle "Moonlight Game Streaming: Play Your PC Games Remotely" --title "[ Platform ]" --menu "${settings[4]}" $height $width "15")

    options=(
        Back "Back to main menu"
        "1)" "Rockchip"
        "2)" "SDL"
    )

    choices=$("${cmd[@]}" "${options[@]}" 2>&1 > /dev/tty0)

    case $choices in
        "1)")
            settings[4]="rk"
        ;;

        "2)")
            settings[4]="sdl"
        ;;
    esac

    SaveSettings
}

FPS() {
    cmd=(dialog --clear --backtitle "Moonlight Game Streaming: Play Your PC Games Remotely" --title "[ FPS ]" --menu "${settings[1]}" $height $width "15")

    options=(
        Back "Back to main menu"
        "1)" "24"
        "2)" "30"
        "3)" "60"
    )

    choices=$("${cmd[@]}" "${options[@]}" 2>&1 > /dev/tty0)

    case $choices in
        "1)")
            settings[1]="24"
        ;;

        "2)")
            settings[1]="30"
        ;;

        "3)")
            settings[1]="60"
        ;;
    esac

    SaveSettings
}

Resolution() {
    cmd=(dialog --clear --backtitle "Moonlight Game Streaming: Play Your PC Games Remotely" --title "[ Resolution ]" --menu "${settings[2]}" $height $width "15")

    options=(
        Back "Back to main menu"
        "1)" "480p"
        "2)" "720p"
        "3)" "1080p"
    )

    choices=$("${cmd[@]}" "${options[@]}" 2>&1 > /dev/tty0)

    case $choices in
        "1)")
            settings[2]="-width 480 -height 320"
        ;;

        "2)")
            settings[2]="-720"
        ;;

        "3)")
            settings[2]="-1080"
        ;;
    esac

    SaveSettings
}

App() {
    cmd=(dialog --clear --backtitle "Moonlight Game Streaming: Play Your PC Games Remotely" --title "[ App ]" --menu "Add the app in GeForce Experience under SHIELD:" $height $width "15")

    options=(
        Back "Back to main menu"
        "Steam" "Steam"
        "Desktop" "Desktop"
        "PPSSPP" "PPSSPP"
        "Dolphin" "Dolphin"
        "pcsx2" "pcsx2"
        "rpcs3" "rpcs3"
        "redream" "redream"
    )

    choices=$("${cmd[@]}" "${options[@]}" 2>&1 > /dev/tty0)
    settings[3]="${choices[0]}"

    SaveSettings
}

Pair() {
if [[ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]]; then
  $ESUDO kill -9 $(pidof rg351p-js2xbox)
  $ESUDO rg351p-js2xbox --silent -t oga_joypad &
  sleep 0.5
  if [[ -e "/dev/input/by-path/platform-rg351v-keys-event" ]]; then
    $ESUDO ln -s /dev/input/event5 /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
  else
    $ESUDO ln -s /dev/input/event4 /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
  fi
  sleep 0.5
  $ESUDO chmod 777 /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
fi
  IP=`$GAMEDIR/osk "Enter PC name or IP address" | tail -n 1`

  echo "$IP" > $GAMEDIR/ip.txt

  printf "\033c" > /dev/tty0

  if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ] || [ -f "/opt/system/Advanced/Switch to SD2 for Roms.sh" ]; then
    $ESUDO setfont /usr/share/consolefonts/Lat7-Terminus20x10.psf.gz
  fi
  export LD_LIBRARY_PATH="$GAMEDIR/libs:/usr/lib"
  $GAMEDIR/moonlight pair "$IP" > /dev/tty0
  if [ "$?" == "0" ]; then
    settings[0]="$IP"
    SaveSettings
    dialog --clear --title "Moonlight" --msgbox "Sucessfully paired this device to ${IP}.  Time to start streaming!" $height $width  2>&1 > /dev/tty0
  else
    dialog --clear --title "Moonlight" --msgbox "Failed to pair this device to ${IP}.  Are you sure gamestreaming is running on this PC and it is connected on the same network with this device?  Is the name or ip of the pc correct?" $height $width  2>&1 > /dev/tty0  
  fi
  if [[ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]]; then
    $ESUDO kill -9 $(pidof rg351p-js2xbox)
    $ESUDO rm /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
  fi
}

Unpair() {
  settings[0]=" "
  SaveSettings
  echo " " > $GAMEDIR/ip.txt
  $ESUDO rm -r ~/.cache/moonlight

if [ "$?" == "0" ]; then
  dialog --clear --title "Moonlight" --msgbox 'Sucessfully unpaired the PC from this device.  Be sure to remove the pairing information for this device from your pc as well.' $height $width  2>&1 > /dev/tty0
else
  dialog --clear --title "Moonlight" --msgbox 'Failed to unpair a PC from this device.  Did you have one paired?' $height $width  2>&1 > /dev/tty0
fi
}

Settings() {
    cmd=(dialog --clear --backtitle "Moonlight Game Streaming: Play Your PC Games Remotely" --title "[ Settings ]" --menu "Select option from the list:" $height $width "15")

    options=(
        Back "Back to main menu"
        "1)" "Pair PC"
        "2)" "App - ${settings[3]}"
        "3)" "Resolution - ${settings[2]}"
        "4)" "Frames per second - ${settings[1]}"
        "5)" "Platform - ${settings[4]}"
        "6)" "Unpair PC"
    )

    choices=$("${cmd[@]}" "${options[@]}" 2>&1 > /dev/tty0)

    case $choices in
        "1)")
            Pair
        ;;

        "2)")
            App
        ;;

        "3)")
            Resolution
        ;;

        "4)")
            FPS
        ;;

        "5)")
            Platform
        ;;

        "6)")
            Unpair
        ;;
    esac
}

#
# Joystick controls
#
# only one instance
$ESUDO kill -9 $(pidof oga_controls)
cd $GAMEDIR
$ESUDO $controlfolder/oga_controls Moonlight.sh $param_device &

#
# Main menu
#
while true; do
    pair=`cat $GAMEDIR/log.txt | tail -n 1`

    selection=(dialog \
       --backtitle "Moonlight Game Streaming: Play Your PC Games Remotely" \
       --title "Paired with ${settings[0]}" \
       --no-collapse \
       --clear \
    --cancel-label "$hotkey + Start to Exit" \
    --menu "$pair" 9 55 9)

    options=(
        "1)" "Start Streaming ${settings[3]}"
        "2)" "Settings"
    )

    choices=$("${selection[@]}" "${options[@]}" 2>&1 > /dev/tty0)

    for choice in $choices; do
        case $choice in
            "1)") Steam ;;
            "2)") Settings ;;
        esac
    done
done
