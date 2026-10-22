#!/bin/bash
# PORTMASTER: SNfetchPLAYER.sh

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

[ -f "$controlfolder/control.txt" ] && source "$controlfolder/control.txt"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls 2>/dev/null || true

GAMEDIR="/$directory/ports/snfetchplayer"
[ ! -d "$GAMEDIR" ] && GAMEDIR="/roms/ports/snfetchplayer"

cd "$GAMEDIR"

# Auto-Registrierung in EmulationStation gamelist.xml (Screenshot, Beschreibung & Metadaten)
GAMELIST_XML="$(dirname "$GAMEDIR")/gamelist.xml"
NEEDS_RESTART_FILE="$GAMEDIR/.needs_es_restart"
rm -f "$NEEDS_RESTART_FILE"

if [ -f "$GAMELIST_XML" ] && [ -f "$GAMEDIR/gameinfo.xml" ]; then
  python3 -c "
import xml.etree.ElementTree as ET
try:
    g_tree = ET.parse('$GAMELIST_XML')
    g_root = g_tree.getroot()
    i_tree = ET.parse('$GAMEDIR/gameinfo.xml')
    i_game = i_tree.getroot().find('game')
    if i_game is not None:
        target = None
        for g in g_root.findall('game'):
            p = g.find('path')
            if p is not None and p.text and p.text.strip() in ('./SNfetchPLAYER.sh', 'SNfetchPLAYER.sh'):
                target = g
                break
        needs_reload = False
        if target is None:
            g_root.append(i_game)
            needs_reload = True
        else:
            for child in i_game:
                existing = target.find(child.tag)
                if existing is None or not existing.text:
                    if existing is None:
                        target.append(child)
                    else:
                        existing.text = child.text
                    needs_reload = True
        if needs_reload:
            g_tree.write('$GAMELIST_XML', encoding='utf-8', xml_declaration=True)
            open('$NEEDS_RESTART_FILE', 'w').close()
except Exception:
    pass
" 2>/dev/null || true
fi

# Logging aktivieren
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export HOME="$GAMEDIR"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Gamepad-to-Keyboard Mapping starten
if [ -n "$GPTOKEYB" ]; then
  $GPTOKEYB "python3" -c "$GAMEDIR/snfetchplayer.gptk" &
fi

# Cursor ausblenden
printf "\033[?25l" > /dev/tty0 2>/dev/null || true

# SNfetchPLAYER Queue Player sofort starten (In-App Asset Sync im Splash Screen)
python3 "$GAMEDIR/player.py" "$@"

# Aufräumen & sauber zurück zu EmulationStation
if [ -n "$ESUDOKILL" ]; then
  $ESUDOKILL $(pidof gptokeyb) 2>/dev/null || true
fi
printf "\033[?25h" > /dev/tty0 2>/dev/null || true

# Falls Metadaten neu registriert wurden, ES frisch neustarten um Überschreiben durch RAM-Cache zu verhindern
if [ -f "$NEEDS_RESTART_FILE" ]; then
  rm -f "$NEEDS_RESTART_FILE"
  # Gamelist final befüllen
  python3 -c "
import xml.etree.ElementTree as ET
try:
    g_tree = ET.parse('$GAMELIST_XML')
    g_root = g_tree.getroot()
    i_tree = ET.parse('$GAMEDIR/gameinfo.xml')
    i_game = i_tree.getroot().find('game')
    if i_game is not None:
        for g in g_root.findall('game'):
            p = g.find('path')
            if p is not None and p.text and p.text.strip() in ('./SNfetchPLAYER.sh', 'SNfetchPLAYER.sh'):
                for child in i_game:
                    ex = g.find(child.tag)
                    if ex is None:
                        g.append(child)
                    else:
                        ex.text = child.text
                break
        g_tree.write('$GAMELIST_XML', encoding='utf-8', xml_declaration=True)
except Exception:
    pass
" 2>/dev/null || true
  touch /tmp/es-restart
  killall -9 emulationstation 2>/dev/null || true
  exit 0
fi

if type pm_finish >/dev/null 2>&1; then
  pm_finish
fi
