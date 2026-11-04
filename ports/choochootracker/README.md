# ChooChooTracker

ChooChooTracker is a handheld tracker based on ChipNomad. It combines AY/YM synthesis, the 47 accessible Mutable Instruments Braids models, 24 Plaits engines and clean PCM8/16 samples.

## Controls

- D-Pad: move
- A: edit
- B: option
- Start: play
- Select: shift
- Select + D-Pad: change screen
- B + A: clear value

The first PortMaster build targets aarch64 devices such as the Anbernic RG353V. Audio runs at 96 kHz.

## ROCKNIX

PortMaster must be fully installed in the active ROMs location. With two SD
cards, a copy on the internal card alone is not sufficient if Ports uses the
external card. Missing `control.txt` prevents the tracker from starting.

The launcher uses PortMaster's bundled `gptokeyb2` on ROCKNIX, with the same
controls and Guide hotkey. InputPlumber can emit Select and Guide together;
the older mapper can then leave Shift held after Select is released.
Other firmware continues to use `gptokeyb`.

Validated on an RG353V with ROCKNIX 20261101: both panfrost and libmali
started from Ports, displayed correctly, released Select/Shift normally,
played DNB with audio, and supported normal exit and relaunch with the
same tracker executable. This is a functional check, not an endurance test.

Launcher regression test (from the repository root, with Python 3 and Bash):
`python3 tracker/tests/test_portmaster_launcher.py`.

## Ableton Link

Ableton Link tempo sync requires Wi-Fi: it only works when the device is on a network with other Link participants (e.g. a phone running LinkHut or a computer running Ableton Live). Enable it on the Project screen (Clock source → Ableton Link, then Connect). Beat alignment is best-effort within roughly 10-15 ms on PortMaster; tempo sync itself is exact.

## Instrument FX

- Braids: `BMD` model, `BTM` timbre, `BCL` color, `BCF` cutoff, `BRS` resonance.
- Plaits: `PMD` engine, `PHA` harmonic, `PTM` timbre, `PMO` morph, `PAX` Main/Aux, `PCF` cutoff, `PRS` resonance.
- Sample: `SPT` pitch, `SST` start, `SEN` end, `SVL` volume, `SCF` cutoff, `SRS` resonance.

Mixer provides per-track level, mute/solo, Clouds Reverb send and tick-synchronized ping-pong Delay send. `PRO`, `MOD` and `SPD` provide conditional triggers and per-track speed. See `USER_MANUAL.md` in the port folder for the complete manual.

Instrument FX use the existing FX columns and remain active until the next note trigger.

## Credits

Thanks to Megus for creating ChipNomad, and to Emilie Gillet / Mutable
Instruments for Braids, Plaits, Clouds and stmlib. Thanks to the PortMaster
team and community testers for their help with handheld compatibility.

## Compile

Source: https://github.com/paiheulevrai/Choochootracker

Use the native ARM64 PortMaster build container from the repository's
`.github/workflows/portmaster.yml`, or the ARM64 toolchain documented in
`docs/build-notes.md`:

```sh
git clone --recurse-submodules https://github.com/paiheulevrai/Choochootracker.git
cd Choochootracker/tracker
make -j4 -f Makefile.portmaster PortMaster-deploy \
  COMMON_CFLAGS='-std=c++17 -Wall -g -Os -DTEST'
```
