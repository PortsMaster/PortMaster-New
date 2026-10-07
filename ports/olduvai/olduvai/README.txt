Olduvai (PortMaster)
====================

Olduvai is a native recreation of the ENGINE of Prehistorik (1991).  It ships no
game content and reads your own game files.  Get the game from GOG.com
("Prehistorik 1+2") or use your original DOS copy.


game  --  WHERE THE GAME FILES GO (the only step you must do)
-------------------------------------------------------------
Put your own copies of these into  ports/olduvai/game/ :

    FILESA.CUR
    FILESB.CUR
    FILESA.VGA
    FILESB.VGA
    and EITHER  HISTORIK.EXE  OR  PREH.SQZ

GOG and other CD-era releases have no HISTORIK.EXE — they ship the executable in
its compressed form, PREH.SQZ, and Olduvai reads that directly.  If that is what
your copy contains, it is correct; nothing is missing.


mt32-roms / soundfonts  --  MUSIC
---------------------------------
By default you get the Sound Blaster sound of 1991 - FM music (the AdLib
chip) with digital sound effects - which needs nothing.
If you own Roland MT-32 or CM-32L ROM images, copy them into  ports/olduvai/mt32-roms/
(CM32L_CONTROL.ROM + CM32L_PCM.ROM, and/or MT32_CONTROL.ROM + MT32_PCM.ROM) and
the Roland sound is used instead.  For General MIDI, copy a SoundFont (.sf2)
into  ports/olduvai/soundfonts/ : it is used when no Roland ROMs are present.


IF IT DOES NOT START
--------------------
Read  ports/olduvai/log.txt .  Its first line names the build; quote it in a
bug report.  A missing game file names the folder searched and the files wanted.


LICENCE
-------
Olduvai is free software, GPL-3.0-or-later; with the xBRZ scaler the binaries
are conveyed under GPL-3.0.  Every licence is in licenses/.  Source code:
https://github.com/ksokolowski/olduvai
