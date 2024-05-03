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

GAMEDIR="/$directory/ports/noparachute"

export XDG_DATA_HOME="$GAMEDIR/conf" # allowing saving to the same path as the game
export XDG_CONFIG_HOME="$GAMEDIR/conf"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CONFIG_HOME"

exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

GAME_FILE="No Parachute.exe"
LAUNCH_FILE="noparachute"

if [ -f "$GAME_FILE" ]; then
  LUASTEAM_FILE="luasteam.lua"
  cp "patch/$LUASTEAM_FILE" "$LUASTEAM_FILE"
  ./bin/7za u -mx0 -aoa -y "$GAME_FILE" "$LUASTEAM_FILE"
  rm "$LUASTEAM_FILE"
  ./bin/7za d "$GAME_FILE" "luasteam.dll"

  PLANERENDERINGLUA_FILE="core/systems/PlaneRendering.lua"
  ./bin/7za x "$GAME_FILE" "$PLANERENDERINGLUA_FILE"
  sed -i "s/uniform vec4 fogcolor = vec4(1, 0, 0, 1)/extern vec4 fogcolor/" "$PLANERENDERINGLUA_FILE"
  sed -i "s/uniform float depth = 0.0/extern float depth/" "$PLANERENDERINGLUA_FILE"
  sed -i "s/uniform float border = 1.0/extern float border/" "$PLANERENDERINGLUA_FILE"
  sed -i "s/uniform vec4 bgcolor = vec4(98\.0\/255\.0, 73\.0\/255\.0, 69\.0\/255\.0, 1\.0)/extern vec4 bgcolor/" "$PLANERENDERINGLUA_FILE"
  sed -i "s/uniform float aspect_ratio = 0.0/extern float aspect_ratio/" "$PLANERENDERINGLUA_FILE"
  sed -i "s/uniform float blur_level = 0.0/extern float blur_level/" "$PLANERENDERINGLUA_FILE"
  sed -i "s/Texel(texture, texcoord - i \* dir)/Texel(texture, texcoord - float(i) \* dir)/" "$PLANERENDERINGLUA_FILE"
  sed -i "s/step(vec2(0, 0), coord) - step(vec2(1, 1), coord)/step(vec2(0.0, 0.0), coord) - step(vec2(1.0, 1.0), coord)/" "$PLANERENDERINGLUA_FILE"
  sed -i "s/borderMul > 0/borderMul > 0.0/" "$PLANERENDERINGLUA_FILE"
  sed -i "s/1 - texcolor.a/1.0 - texcolor.a/" "$PLANERENDERINGLUA_FILE"
  sed -i "s/texcolor.a += 1/texcolor.a += 1.0/" "$PLANERENDERINGLUA_FILE"
  sed -i "s/float borderMul = 1 - borderStep\.x \* borderStep\.y/float borderMul = 1\.0 - borderStep\.x * borderStep\.y/" "$PLANERENDERINGLUA_FILE"
  sed -i "/texcolor\.rgb = mix(texcolor\.rgb \* vcolor\.rgb, fogcolor\.rgb, depth)/a\    if (texcolor\.r >= 0.98 && texcolor\.g >= 0.98 && texcolor\.b >= 0.98) \{return vec4(0.0, 0.0, 0.0, 0.0);\}" "$PLANERENDERINGLUA_FILE"
  ./bin/7za u -mx0 -aoa -y "$GAME_FILE" "$PLANERENDERINGLUA_FILE"
  rm -rf "core"
  
  # fix settigns scaling for non 16:9
  SETTINGSLUA_FILE="ui/SettingsOverlay.lua"
  ./bin/7za x "$GAME_FILE" "$SETTINGSLUA_FILE"
  sed -i "s/local overlayWidth = screenWidth \* 0\.55/local overlayWidth = screenWidth \* 0\.75/" "$SETTINGSLUA_FILE"
  sed -i "s/local overlayHeight = overlayWidth \* 0\.75/local overlayHeight = overlayWidth \* 0\.80/" "$SETTINGSLUA_FILE"  
  sed -i "s/overlayY + overlayHeight \* 0\.94/overlayY + overlayHeight \* 0\.80/" "$SETTINGSLUA_FILE"
  sed -i "s/(\"btn_settings_close\"), overlayX, overlayY + overlayHeight/(\"btn_settings_close\"), overlayX, overlayY + overlayHeight \* 0\.84/" "$SETTINGSLUA_FILE"
  ./bin/7za u -mx0 -aoa -y "$GAME_FILE" "$SETTINGSLUA_FILE"
  rm -rf "ui"
  
  MAFLUA_FILE="lib/maf.lua"
  ./bin/7za x "$GAME_FILE" "$MAFLUA_FILE"
  sed -i "/add = function(v, u, out)/a \            if type(u) ~= \"table\" then out\.x, out\.y, out\.z = v\.x + u, v\.y + u, v\.z + u return out end" "$MAFLUA_FILE"
  ./bin/7za u -mx0 -aoa -y "$GAME_FILE" "$MAFLUA_FILE"
  rm -rf "lib"
  
  SCREENLUA_FILE="ui/screens/GameScreen.lua"
  ./bin/7za x "$GAME_FILE" "$SCREENLUA_FILE"
  sed -i "s/love\.mouse\.setVisible(true)/love\.mouse\.setVisible(false)/" "$SCREENLUA_FILE"
  ./bin/7za u -mx0 -aoa -y "$GAME_FILE" "$SCREENLUA_FILE"
  rm -rf "ui"
  MOUSE_FILE="left_ptr.png"
  cp "patch/$MOUSE_FILE" "$MOUSE_FILE"
  ./bin/7za u -mx0 -aoa -y "$GAME_FILE" "$MOUSE_FILE"
  rm "$MOUSE_FILE"  
  MAIN_FILE="main.lua"  
  ./bin/7za x "$GAME_FILE" "$MAIN_FILE"
  sed -i "/function love.load(arg)/a \  cursorImage = love.graphics.newImage('left_ptr.png')" $MAIN_FILE
  
  echo "" >> $MAIN_FILE
  echo "function drawCursor()" >> $MAIN_FILE
  echo "  local mouseX, mouseY = love.mouse.getPosition()" >> $MAIN_FILE
  echo "  love.graphics.draw(cursorImage, mouseX, mouseY)" >> $MAIN_FILE
  echo "end" >> $MAIN_FILE
  
  sed -i "/screenManager:draw()/a \  drawCursor()" $MAIN_FILE  
  sed -i "/function love\.load(arg)/a \    love\.mouse\.setVisible(false)" $MAIN_FILE
  ./bin/7za u -mx0 -aoa -y "$GAME_FILE" "$MAIN_FILE"
  rm $MAIN_FILE

  mv "$GAME_FILE" "$LAUNCH_FILE"
fi

$GPTOKEYB "love" -c "noparachute_$ANALOG_STICKS.gptk" &
./bin/love "$LAUNCH_FILE"

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0