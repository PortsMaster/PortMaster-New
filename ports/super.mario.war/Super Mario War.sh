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
source $controlfolder/device_info.txt

get_controls

GAMEDIR="/$directory/ports/smw"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

$ESUDO rm -rf ~/.smw
$ESUDO ln -s $GAMEDIR/conf/.smw ~/

if [ "$CFW_NAME" = "ArkOS" ]; then

	ESUDO="sudo"
	if [ -f "/storage/.config/.OS_ARCH" ]; then
	  ESUDO=""
	  LANG=""
	fi

	$ESUDO chmod 666 /dev/tty0
	export TERM=linux
	export XDG_RUNTIME_DIR=/run/user/$UID/
	printf "\033c" > /dev/tty0
	dialog --clear

	hotkey="Select"
	height="15"
	width="55"

	if [[ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]]; then
	  param_device="anbernic"
	  export LD_LIBRARY_PATH=/usr/local/bin
	  if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ] || [ -f "/opt/system/Advanced/Switch to SD2 for Roms.sh" ] || [ -f "/boot/rk3326-rg351v-linux.dtb" ]; then
		$ESUDO setfont /usr/share/consolefonts/Lat7-Terminus20x10.psf.gz
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
	  $ESUDO setfont /usr/share/consolefonts/Lat7-Terminus20x10.psf.gz
	  height="20"
	  width="60"
	elif [[ "$(cat /sys/firmware/devicetree/base/model)" == "Anbernic RG552" ]] || [[ -e "/dev/input/by-path/platform-singleadc-joypad-event-joystick" ]]; then
	  param_device="rg552"
	  $ESUDO setfont /usr/share/consolefonts/Lat7-Terminus20x10.psf.gz
	  height="20"
	  width="60"
	else
	  param_device="chi"
	  hotkey="1"
	  $ESUDO setfont /usr/share/consolefonts/Lat7-Terminus20x10.psf.gz
	  height="20"
	  width="60"
	fi

	SaveSettings() {
	  for j in "${settings[@]}"
	  do
		echo $j 
	  done > $GAMEDIR/conf/.smw/servers.yml
	}

	MPSettings() {

	 mapfile settings < $GAMEDIR/conf/.smw/servers.yml

	 playername=$(echo ${settings[0]} | cut -c 14-)
	 server1=$(echo ${settings[2]} | cut -c 3-)
	 server2=$(echo ${settings[3]} | cut -c 3-)
	 server3=$(echo ${settings[4]} | cut -c 3-)

	  cmd=(dialog --clear --backtitle "Super Mario War Netplay" --title "[ Settings ]" --menu "Select option from the list:" "12" "55" "15")

		options=(
			Back "Back to main menu"
			"1)" "Player Name: $playername"
			"2)" "Server 1: $server1"
			"3)" "Server 2: $server2"
			"4)" "server 3: $server3"
		)

		choices=$("${cmd[@]}" "${options[@]}" 2>&1 > /dev/tty0)

		case $choices in
			"1)")
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
				  newname=`osk "Enter your player name" | tail -n 1`
				  if [ ! -z "$newname" ]; then
					settings[0]="player_name: $newname"
					SaveSettings
					dialog --clear --title "Super Mario War Netplay settings" --msgbox "Sucessfully saved your new name, $newname" "15" "55"  2>&1 > /dev/tty0
				  else
					dialog --clear --title "Super Mario War Netplay settings" --msgbox "Did not set or save a new name." "15" "55"  2>&1 > /dev/tty0  
				  fi
				  if [[ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]]; then
					$ESUDO kill -9 $(pidof rg351p-js2xbox)
					$ESUDO rm /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
				  fi
			;;

			"2)")
				dialog --clear --backtitle "Super Mario War netplay" --title "" --clear \
				--yesno "\nWould you like to set server 1 as your internal ip of ${intip}?" $height $width 2>&1 > /dev/tty0

				case $? in
					0) 
						newserver1="$intip"
						if [ ! -z "$newserver1" ]; then
						  settings[2]="- $newserver1"
						  SaveSettings
						  dialog --clear --title "Super Mario War Netplay settings" --msgbox "Sucessfully saved your new Server 1, $newserver1" "15" "55"  2>&1 > /dev/tty0
						else
						  dialog --clear --title "Super Mario War Netplay settings" --msgbox "Did not set or save a new Server 1." "15" "55"  2>&1 > /dev/tty0  
						fi
					;;
					1)
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
						  newserver1=`osk "Enter server IP or URL" | tail -n 1`
						  if [ ! -z "$newserver1" ]; then
							settings[2]="- $newserver1"
							SaveSettings
							dialog --clear --title "Super Mario War Netplay settings" --msgbox "Sucessfully saved your new Server 1, $newserver1" "15" "55"  2>&1 > /dev/tty0
						  else
							dialog --clear --title "Super Mario War Netplay settings" --msgbox "Did not set or save a new Server 1." "15" "55"  2>&1 > /dev/tty0  
						  fi
						  if [[ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]]; then
							$ESUDO kill -9 $(pidof rg351p-js2xbox)
							$ESUDO rm /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
						  fi
					;;
				esac
			;;

			"3)")
				dialog --clear --backtitle "Super Mario War netplay" --title "" --clear \
				--yesno "\nWould you like to set server 1 as your external ip of ${extip}?" $height $width 2>&1 > /dev/tty0

				case $? in
					0) 
						newserver2="$extip"
						if [ ! -z "$newserver2" ]; then
						  settings[3]="- $newserver2"
						  SaveSettings
						  dialog --clear --title "Super Mario War Netplay settings" --msgbox "Sucessfully saved your new Server 2, $newserver2" "15" "55"  2>&1 > /dev/tty0
						else
						  dialog --clear --title "Super Mario War Netplay settings" --msgbox "Did not set or save a new Server 2." "15" "55"  2>&1 > /dev/tty0  
						fi
					;;
					1)
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
						  newserver2=`osk "Enter server IP or URL" | tail -n 1`
						  if [ ! -z "$newserver2" ]; then
							settings[3]="- $newserver2"
							SaveSettings
							dialog --clear --title "Super Mario War Netplay settings" --msgbox "Sucessfully saved your new Server 2, $newserver2" "15" "55"  2>&1 > /dev/tty0
						  else
							dialog --clear --title "Super Mario War Netplay settings" --msgbox "Did not set or save a new Server 2." "15" "55"  2>&1 > /dev/tty0  
						  fi
						  if [[ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]]; then
							$ESUDO kill -9 $(pidof rg351p-js2xbox)
							$ESUDO rm /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
						  fi
					;;
				esac
			;;

			"4)")
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
				  newserver3=`osk "Enter server IP or URL" | tail -n 1`
				  if [ ! -z "$newserver3" ]; then
					settings[4]="- $newserver3"
					SaveSettings
					dialog --clear --title "Super Mario War Netplay settings" --msgbox "Sucessfully saved your new Server 3, $newserver3" "15" "55"  2>&1 > /dev/tty0
				  else
					dialog --clear --title "Super Mario War Netplay settings" --msgbox "Did not set or save a new Server 3." "15" "55"  2>&1 > /dev/tty0  
				  fi
				  if [[ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]]; then
					$ESUDO kill -9 $(pidof rg351p-js2xbox)
					$ESUDO rm /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
				  fi
			;;
		esac

	}
	cd $GAMEDIR/conf

	runit() {

	cd $GAMEDIR

	$ESUDO chmod 666 /dev/tty1
	$ESUDO kill -9 $(pidof oga_controls)

	$ESUDO $controlfolder/oga_controls smw $param_device &


	./smw
	$ESUDO kill -9 $(pidof oga_controls)
	if [ ! -z $(pgrep smw-server) ]; then
	   $ESUDO kill -9 $(pidof smw-server)
	fi
	$ESUDO systemctl restart oga_events &
	printf "\033c" >> /dev/tty1
	printf "\033c" >> /dev/tty0
	}

	MPMenu() {

	extip="$(curl checkip.amazonaws.com)"
	if [ -f "/storage/.config/.OS_ARCH" ]; then
	  intip="$(ip route | awk '/src/ { print $7 }')"
	else 
	  intip="$(ip route | awk '/src/ { print $9 }')"
	fi

	while true; do

		selection=(dialog \
		   --backtitle "Super Mario War netplay" \
		   --title "Main Menu" \
		   --no-collapse \
		   --clear \
		--cancel-label "$hotkey + Start to Exit" \
		--menu "Your Internal IP is: ${intip}\nYour External IP is: ${extip}" 13 55 9)

		options=(
			"1)" "Start server"
			"2)" "Stop server"
			"3)" "Start game"
			"4)" "Settings"    
			"5)" "Quit"
		)

		choices=$("${selection[@]}" "${options[@]}" 2>&1 > /dev/tty0)

		for choice in $choices; do
			case $choice in
				"1)") 
					 if [ ! -z $(pgrep smw-server) ]; then
					   $ESUDO kill -9 $(pidof smw-server)
					 fi
					 cd $GAMEDIR 
					 ./smw-server &
					 if [ "$?" == "0" ]; then
					   dialog --clear --backtitle "Super Mario War netplay" --title "" --clear --msgbox "\n\nThe server has been started successfully." $height $width 2>&1 > /dev/tty0
					 else
					   dialog --clear --backtitle "Super Mario War netplay" --title "" --clear --msgbox "\n\nThe server has failed to start." $height $width 2>&1 > /dev/tty0 
					 fi
					 cd $GAMEDIR/conf
				;;
				"2)") 
					 $ESUDO kill -9 $(pidof smw-server)
					 if [ "$?" == "0" ]; then
					   dialog --clear --backtitle "Super Mario War netplay" --title "" --clear --msgbox "\n\nThe server has been stopped successfully." $height $width 2>&1 > /dev/tty0
					 else
					   dialog --clear --backtitle "Super Mario War netplay" --title "" --clear --msgbox "\n\nThe server wasn't running." $height $width 2>&1 > /dev/tty0 
					 fi
				;;
				"3)")
					runit
					$ESUDO kill -9 $(pidof oga_controls)
					printf "\033c" >> /dev/tty0
					unset LD_LIBRARY_PATH
					exit 0
				;;
				"4)")
					  MPSettings
				;;
				"5)") 
					  $ESUDO kill -9 $(pidof oga_controls)
					  if [ ! -z $(pgrep smw-server) ]; then
						$ESUDO kill -9 $(pidof smw-server)
					  fi
					  printf "\033c" >> /dev/tty0
					  unset LD_LIBRARY_PATH
					  exit 0
				;;
			esac
		done
	done
	}

	$ESUDO $controlfolder/oga_controls Mario $param_device &

	dialog --clear --backtitle "Super Mario War" --title "" --clear \
	--yesno "\nWould you like to start a netplay session?" $height $width 2>&1 > /dev/tty0

	  case $? in
		 0) MPMenu;;
		 1) runit;;
		 *) $ESUDO kill -9 $(pidof oga_controls)
			unset LD_LIBRARY_PATH
			printf "\033c" >> /dev/tty0
		 ;;
	  esac
else
	cd $GAMEDIR
	
	$ESUDO chmod 666 /dev/uinput

	$GPTOKEYB "smw" -c "./smw.gptk" &
	./smw

	$ESUDO kill -9 $(pidof gptokeyb)
fi