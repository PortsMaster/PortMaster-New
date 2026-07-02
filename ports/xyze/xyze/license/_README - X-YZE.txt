#################
###   X-YZE   ###
###   v1.02   ###
#################

"Thanks for downloading my game, X-YZE!" ~ Chris

Here's the itch page: https://chrislsound.itch.io/x-yze

You can also find the soundtrack on Bandcamp: https://chrislogsdon.bandcamp.com/album/x-yze-original-game-soundtrack

If you run into any bugs or otherwise would like to reach out to me, I'm on various socials or chris [at] ChrisLSound [dot] com.


####################
###   CONTROLS   ###
####################

-= KEYBOARD =-
Arrow keys or WASD: Move

Z or Spacebar: Dash, Confirm, Advance text
(note: Dash not unlocked at start of game)

Esc: Pause, Skip text

-= GAMEPAD =-
D-pad or Left stick: Move

Bottom or Left Face Buttons: Dash, Confirm, Advance text
(note: Dash not unlocked at start of game)

Start: Pause, Skip text


#################
###   NOTES   ###
#################

-= WHICH FILE TO RUN? =-
You can run either the console or the non-console version. It shouldn't really matter. The console version is there in case major troubleshooting is needed, in which case we'll probably be in contact with each other so I can walk you through how to enable debug mode and whatnot.
To clarify, "console version" means the .console.exe (Windows) / .command (Mac) / .sh (Linux) files.

-= STEAM DECK USERS =-
The game should generally work fine on Steam Deck. However, please be sure to launch it through Steam and not from the desktop. This is due to some issues with the gamepad being detected, and save data getting moved around.

-= GAMEPADS =-
If you want to do your own gamepad mapping (via JoyToKey or whatever else), you can go into the CONFIG menu in-game and disable gamepad. This will prevent the game from overriding any custom gamepad stuff you may have set up.

-= IF YOUR COMPUTER THINKS IT'S A VIRUS =-
I promise it's not. If you're on a Mac, you can go to your Settings -> Privacy & Security. In the Security section, click the "Open Anyway" button near the message that says "X-YZE was blocked to protect your Mac." Then click "Open Anyway" on the popup.


#####################
###   CHANGELOG   ###
#####################

-= v1.02 (2025-10-08) =-
FIXED:
- hopefully fixed most if not all issues with pause menu strangeness
- fixed incorrect font credit
- fixed some menu sfx not playing correctly
- fixed being able to pause during credits
- fixed game thinking you were in boss/server practice mode if you entered practice mode, quit, then continued a story mode game
- fixed various minor issues resulting from the "Save Every Room" gameplay option
- PSN: fixed incorrect boss healthbar capitalization
- HDD: fixed some room lock triggers being triggerable more than once
- HDD: fixed Jack-in-the-Box damage immunity flash getting stuck on sometimes
- EKI: fixed spike desync in one room
- EKI: removed some tiles that were floating in space in boss room
- EKI: fixed screen flashing when a Molotov died off-screen
- CHU: small cutscene fix
- CHU: yet another attempt to prevent hitching when glitch vfx plays at end of boss
- PSN2: fixed inconsistent boss wing attack speed
- PSN2: fixed [REDACTED] sprite not showing correctly during boss wing attack

ADDED:
- new setting to boost brightness of PUR background. a faint silhouette of the level should be visible, but some players saw a pure black background (I was able to reproduce this by plugging my laptop into a TV via HDMI)
- game version text now appears on title screen and pause menu
- config settings now wrap around from min to max values and vice-versa (except screen mult)
- cursor memory for title screen, config menu, and arcade mode screen
- PSN: added gate to checkpoint 1 that unlocks once you've hit the altar (auto unlocks on room load in arcade mode). this is to ensure players realize that the altars are important.

CHANGED:
- renamed arcade mode "full run" to "gauntlet" in honor of my buddy toad22484: https://www.twitch.tv/toad22484/
- made it less likely you'll accidentally skip dialogue
- reworked How To Play menu
- HDD: made a room in the first checkpoint very slightly easier
- EKI: made terminal hitboxes slightly taller since players often undershot when approaching from above
- EKI: fire now collides with your body instead of your feet
- EKI: moved boss computers very slightly away from the fire
- PUR: removed bomb buttons from Clamper room. fight it yourself! it's better this way anyways, trust me ;)
- PUR: boss pickup orbs are quicker to reach you and easier to pick up
- PSN2: slightly adjusted bump direction/force for some boss attacks
- PSN2: made it ever so slightly easier to use a certain strategy for dealing with the boss bullet maze attack. i wonder what this strat could be...?



-= v1.01 (2025-09-26) =-
- fixed some issues with EKI boss that made the final phase way harder than intended
- fixed final door at end of PUR boss fight having no collision, meaning you could just... walk through it without killing the Arbiter...
- fixed Dash Module HUD not appear properly in some cutscenes
- fixed issue in EKI where spike state could get desynced
- fixed a potential softlock in EKI
- made a couple tiny things in EKI a tiny bit less mean
- fixed potential softlock in HDD
- fixed issue in HDD where a Fairy could get stuck against a door. poor fairy :c