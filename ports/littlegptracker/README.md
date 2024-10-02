## Notes
Thanks to the [Mdashdotdashn](https://github.com/Mdashdotdashn), [djdiskmachine](https://github.com/djdiskmachine)  and other contributors for creating this music tracker and making available for free.

## Controls
```
D-Pad: In screen navigation.
A: Insert Chain/Phrase/Note.
A,A: Insert next unused Chain/Phrase/Instrument.
L1+(B,A): Clone. This will overwrite the current Highlighted Item with a copy of itself using the next unused Item available. (in song view) while keeping L1 pressed, press A again without moving to Deep Clone (clone the phrases within the chain)
B+A: Cuts the current Highlighted Item .
A+D-Pad: Updates Highlighted Item value.
    A+UP/DOWN: +/- 0x10.
    A+RIGHT/LEFT: +/- 1.
B+D-Pad: Rapid Navigation.
    B+UP/DOWN: Page up/down in Song Screen, Next/Previous Phrase in Current Chain in Phrase Screen. Navigation +/- 0x10 in Instrument/Table Screen.
    B+LEFT/RIGHT: Next/Previous Channel in Chain/Phrase Screen. Navigation +/- 1 in Instrument/Table Screen. Switch between Song and Live Modes in Song Screen.
R1+D-Pad: Navigate between the Screens.
L1+UP/DOWN: Jump up/down to next populated row after a blank row (great for live mode entire row queuing!)
START: Start/Stop song playback from the Highlighted Row
```

For advanced controls visit this [link](https://github.com/ohol-vitaliy/LittleGPTracker/blob/master/docs/wiki/What-is-LittlePiggyTracker.md#basic-editing--navigation)

## Version
1.4.3-bacon0

## Compile
```shell
git clone https://github.com/ohol-vitaliy/LittleGPTracker
cd LittleGPTracker/projects
make PLATFORM=PORTMASTER #¯\_(ツ)_/¯
```
