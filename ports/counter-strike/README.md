# Counter-Strike 1.6

> **No game assets are included.** 

> You must provide your own legally obtained Counter-Strike 1.6 files.

---

## Requirements

- Counter-Strike 1.6 **`cstrike`** folder (from your own install)
- Half-Life **`valve`** folder (from your own install) 

> Counter-Strike does **not** require the Half-Life port to be installed.

---

## Installation

1. Install this port via the autoinstall tool 
( Copy the zip above to ports/autoinstall and then open PortMaster)

2. Buy the game on steam https://store.steampowered.com/app/10/CounterStrike/

3. Copy your **`valve`** folder into:
   ```
   /roms/ports/counter-strike/valve
   ```

4. Copy your **`cstrike`** folder into:
   ```
   /roms/ports/counter-strike/cstrike
   ```

5. **Do not overwrite existing port files** when copying game data.
   If prompted, choose **Skip / Keep existing files**.

6. Launch **Counter-Strike** from PortMaster.

> **Quick check:** After installation, both `valve` and `cstrike` folders
> should be populated with game data (not empty).

---

## Controls (Default)

| Button | Action |
|------|------|
| Left stick | Move |
| Right stick | Look / Aim |
| R1 | Primary fire |
| R2 | Secondary fire |
| L1 | Crouch |
| L2 | Walk / speed modifier |
| D-Pad | Weapon / Buy / Menu slots |
| A | Use |
| B | Jump |
| Y | Reload |
| X | Buy ammo (buy zone) |
| L3 | Buy menu |
| R3 (hold) | Scoreboard |
| Start | Game menu |
| Select / Back | Slot 10 (bomb / utility) |

Bindings may be customized by editing:
```
/roms/ports/counter-strike/cstrike/userconfig.cfg
```

---

## Bots (YaPB)

- Offline bot play is supported out of the box
- No additional setup required

⚠️ Replacing `liblist.gam` may disable bot support.

<details>
<summary><b>Advanced: YaPB configuration</b></summary>

Primary config file:
```
/roms/ports/counter-strike/cstrike/addons/yapb/conf/yapb.cfg
```

Common options:
- `yapb_quota` — number of bots
- `yapb_difficulty` — skill level (0–4)
- `yapb_autovacate` — remove bots when humans join

</details>

---

## Multiplayer / Network Play

- LAN and Internet play are supported but lightly tested
- Many devices require a USB Wi-Fi adapter
- “Play online” is **disabled by default**

<details>
<summary><b>Enable “Play online”</b></summary>

Edit:
```
/roms/ports/counter-strike/cstrike/userconfig.cfg
```

Add:
```
ui_menu_play_online 1
```

Restart the game after saving.

</details>

---

## Renderer Notes

If the game fails to start or shows a black screen, you may need to switch
the renderer used by the launcher script.

- `-ref gles2` — hardware accelerated (default)
- `-ref soft` — software fallback

This setting can be changed inside **Counter-Strike.sh**.

---

## Known Issues & Limitations

- Network play has limited testing and may vary by device
- “Play online” must currently be enabled manually
- Overwriting port files may break bots or menus
- Some devices may require switching renderers
- Temporary black screen may occur while a match initializes

---

## Legal

Counter-Strike 1.6 and Half-Life are © Valve Corporation.

This port:
- Does not distribute proprietary game assets
- Contains only open-source code, scripts, and configuration
- Requires legally obtained game data

---

## Credits

- Valve — Counter-Strike / Half-Life
- Xash3D FWGS — engine
- cs16-client — Counter-Strike client for Xash3D
- ReGameDLL_CS — CS game DLL
- YaPB — bot support
- PortMaster community

---

**Port author:** Ryan Gunn  
Last updated: January 2026
