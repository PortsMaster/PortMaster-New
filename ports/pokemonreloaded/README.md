## Notes

Pokémon Reloaded The Last Beta 1.9.2.2 running natively on OpenGMK (Rust) with SDL2/KMSDRM.
No Wine or Windows emulation is used.

This is the centred build, selected for stability. In some battles the right edge of the battle
UI can be clipped, so the opponent's level may not be fully visible.

The port does not include the game. Download the official Windows release from the F3R blog and
extract its contents into `ports/pokemonreloaded/` so that `data/` and the `.exe` sit next to
`gm8emulator`.

Thanks to **F3R Productions** for creating Pokémon Reloaded, to **Klisee** for the Android/OpenGMK
port that this work is based on, and to the OpenGMK contributors. Packaging for R36S/ArkOS by
**Kuranesx**.
