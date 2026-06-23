Mysteries of the Sith — copy into openjkdf2/mots/.

From Steam (Jedi Knight Mysteries of the Sith) or GOG, copy:

  episode/          JKM.goo, JKM_KFY.goo, JKM_MP.goo, JKM_SABER.goo
  resource/         Jkmres.goo, JKMsndLO.goo, jk_.cd
  resource/video/   all .SAN files (incl. JKMINTRO.SAN) + CUTSCENES.ZIP
  MUSIC/            all Track*.ogg files (Steam: 13 tracks, Track02–Track14)

Do NOT copy JKDF2's jk_.cd into mots/resource/ — MOTS has its own key file.

Steam installs have no player/ folder; GOG may include player/ (optional).

Launch: Star Wars Jedi Knight - Mysteries of the Sith.sh

Low RAM (1 GB handhelds): low memory mode auto-enables (smaller sound cache, aggressive texture purge).
Override: OPENJKDF2_LOW_MEMORY=1 (force on) or =0 (force off). Cutscenes are not skipped.

If you see "Could not load level", check log.txt for "OpenJKDF2: MOTS —" lines.

Verify jk_.cd is from MOTS (not JKDF2):
  od -An -tx4 -N4 mots/resource/jk_.cd
  MOTS must show: 3b426929   (JKDF2 shows: 699232c4)
