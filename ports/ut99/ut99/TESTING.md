# UT99 PortMaster testing

Community thread:
https://discord.com/channels/1122861252088172575/1544732545047068692

| Device / SoC | Firmware | Resolution | Result | Notes |
| --- | --- | --- | --- | --- |
| TrimUI Smart Pro / A133P | CrossMix / TrimUI | 1280x720 | Passed | Launch, fonts, gameplay, pause-menu cursor, controls, and audio confirmed by porter. |
| Retroid Pocket 5 / Snapdragon 865 | ROCKNIX | 1920x1080 | Passed after compatibility fix | Universal bundled `gconv` modules fixed the missing Windows-1252/UTF-16LE conversions. |
| RG34XXSP-class / H700 | muOS | 720x480 | Passed by tester | Startup and gameplay reported working. |
| R36S-class / RK3326 | dARKOS / dARKOSRE | 640x480 | Passed by tester | Gameplay reported working; pointer speed can be tuned in `User.ini`. A separate failure was missing donor file `Sounds/Female2Voice.uax`. |
| RG351P / RK3326 | dARKOS | 480x320 | Partial test | Display detection confirmed on an older build; the final build should be retested at this optional resolution. |
| R36S / RK3326 | ArkOS | 640x480 | Not documented | Obtain an official ArkOS result for the pull-request matrix. |
| RK3566 device | ROCKNIX | 640x480 or 1280x720 | Not documented | ROCKNIX is confirmed on Snapdragon; RK3566/Panfrost coverage remains useful. |
| AmberELEC device | AmberELEC | 640x480 | Not documented | Requested by the published PortMaster testing checklist. |
| H700 or A133P device | Knulli | 640x480 or 1280x720 | Optional / not documented | Optional firmware coverage. |

Each passing test should cover startup, menu colors and fonts, one visible menu
cursor, all cursor bounds before and after pausing, world rendering, HUD and
effects, both analog sticks, buttons, audio, and clean return to the frontend.
