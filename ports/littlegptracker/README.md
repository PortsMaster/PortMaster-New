## Notes
Thanks to the [Mdashdotdashn](https://github.com/Mdashdotdashn), [djdiskmachine](https://github.com/djdiskmachine), and other contributors for creating this music tracker and making it available for free.

## Controls
| Button | Action |
|--|--|
| D-Pad | In screen navigation. |
| A | Insert Chain/Phrase/Note. |
| B+A | Cuts the current Highlighted Item. |
| A+UP/DOWN | Updates Highlighted Item value +/-10 |
| A+RIGHT/LEFT | Updates Highlighted Item value +/-1. |
| B+UP/DOWN | Page up/down in Song Screen. <br/> Next/Previous Phrase in Current Chain in Phrase Screen. <br/> Navigation +/-10 in Instrument/Table Screen. |
| B+LEFT/RIGHT | Next/Previous Channel in Chain/Phrase Screen. <br/> Navigation +/-1 in Instrument/Table Screen. <br/> Switch between Song and Live Modes in Song Screen. |
| R1+D-Pad | Navigate between the Screens. |
| L1+UP/DOWN | Jump up/down to next populated row after a blank row |
| START | Start/Stop song playback from the Highlighted Row |

For advanced controls visit this [link](https://github.com/djdiskmachine/LittleGPTracker/blob/1.5.0-bacon1/docs/wiki/What-is-LittlePiggyTracker.md#basic-editing--navigation).

## Version
1.5.0-bacon1

## Compile
```shell
git clone https://github.com/ohol-vitaliy/PortMaster-LittleGPTracker
cd PortMaster-LittleGPTracker

# update Dockerfile to use your chosen LittleGPTracker release version
version="1.5.0-bacon1" && sed -ie "s/\( --branch\) \S*/\1 $version/g" Dockerfile
```
Then follow these [Docker steps](https://github.com/ohol-vitaliy/PortMaster-LittleGPTracker#steps).

## Useful Links
[LittleGPTracker releases](https://github.com/djdiskmachine/LittleGPTracker/releases)
