#!/bin/bash
# PORTMASTER: sm64.zip, sm64.sh

BASEROM='baserom.us.z64'
RESTOOL_DIR="restool"
RESTOOL_ZIP="restool.zip"

# Ressources stuffs
RES_DIR="res"
BASEZIP="base.zip"
DEMOS_DIR="demos"
TEXTS_DIR="texts"

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

# We source the control.txt file contents here
source $controlfolder/control.txt

# With device_info we can get dynamic device information like resolution, cpu, cfw etc.
source $controlfolder/device_info.txt

# We source custom mod files from the portmaster folder example mod_jelos.txt which containts pipewire fixes
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

# We pull the controller configs like the correct SDL2 Gamecontrollerdb GUID from the get_controls function from the control.txt file here
get_controls

# We switch to the port's directory location below & set the variable for the gamedir and a configuration dir  easier handling below
GAMEDIR="/$directory/ports/render96ex"
CONFDIR="$GAMEDIR/conf/"

# Ensure the conf directory exists
mkdir -p "$CONFDIR"

# Switch to the game directory
cd $GAMEDIR

# Log the execution of the script, the script overwrites itself on each launch
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Starting with the multiarch support we make sure that older PortMaster versions still revert to the old binary names. 
export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"

# Port specific additional libraries should be included within the port's directory in a separate subfolder named libs.aarch64, libs.armhf or libs.x64
export LD_LIBRARY_PATH="${GAMEDIR}/libs.${DEVICE_ARCH}:${LD_LIBRARY_PATH}"

# Add text_viewer binary path in PATH
export PATH="${GAMEDIR}/bin.${DEVICE_ARCH}:${PATH}"

# Provide appropriate controller configuration if it recognizes SDL controller input
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

# For Ports that use gptokeyb's xbox360 mode, interactive input or config-mode we need to make sure /dev/uinput is accessible on non-root cfws
# For distros running as root, including sudo in scripts can be problematic. The $ESUDO variable dynamically uses sudo based on the OS."
$ESUDO chmod 666 /dev/uinput

# We launch gptokeyb using this $GPTOKEYB variable as it will take care of sourcing the executable from the central location,
# assign the appropriate exit hotkey dependent on the device (ex. select + start for most devices and minus + start for the 
# rgb10) and assign the appropriate method for killing an executable dependent on the OS the port is run from.
# With -c we assign a custom mapping file else gptokeyb will only run as a tool to kill the process.
# For $ANALOGSTICKS we have the ability to supply multiple gptk files to support 1 and 2 analogue stick devices in different ways.
# For a proper documentation how gptokeyb works: [Link](https://github.com/PortsMaster/gptokeyb)
$GPTOKEYB "sm64.us.f3dex2e.${DEVICE_ARCH}" &

# If the user has put the rom let's install the ressources
if [ -f "$BASEROM" ]
then

  # Let's first ask if the user wants to start the ressource installion process
  text_viewer -f 25 -w -t "Ressources installation" --input_file $GAMEDIR/restool-msg.txt -y
  
  if [ $? -eq 21 ]
  then

    # Unpack the restool workspace
    unzip "${RESTOOL_ZIP}" 2>&1

    if [ ! $? -eq 0 ]
    then

      # Something went wrong with unzip
      echo "$0: An error occured while extracting ${RESTOOL_ZIP}"
      text_viewer -e -f 25 -w -t "Error" -m "Oh, no! An error has occured while extracting ${RESTOOL_ZIP}. Please see log for details."

    fi

    cd "${RESTOOL_DIR}"
    ./install-res.sh ${CFW_NAME} 2>&1
    cd ../

    rm -rf ${RESTOOL_DIR}

  fi

fi

# Check if madatory ressources are installed
if [ ! -f $GAMEDIR/$RES_DIR/$BASEZIP ] || [ ! -d $GAMEDIR/$RES_DIR/$DEMOS_DIR ] || [ ! -d $GAMEDIR/$RES_DIR/$TEXTS_DIR ]
then

  echo "Ressources are missing."
  text_viewer -e -f 25 -w -t "Error" -m "Oh, no! Ressources are missing. Install them first (put ${BASEROM} in ${GAMEDIR})."

else

  # Now we launch the port's executable with multiarch support.
  ./sm64.us.f3dex2e.${DEVICE_ARCH} --savepath ./conf/ 2>&1

fi

# Although you can kill most of the ports (if not all of the ports) via a hotkey, the user may choose to exit gracefully.
# That's fine but let's make sure gptokeyb is killed so we don't get ghost inputs or worse yet, 
# launch it again and have 2 or more of them running.
$ESUDO kill -9 $(pidof gptokeyb)

# The line below is helpful for ArkOS, RetroOZ, and TheRA as some of these ports tend to cause the 
# global hotkeys (like brightness and volume control) to stop working after exiting the port for some reason.
$ESUDO systemctl restart oga_events &

# Finally we clean up the terminal screen just for neatness sake as some people care about this.
printf "\033c" > /dev/tty0
