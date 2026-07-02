## Notes

Exact Chinese Chess is a controller-first Xiangqi / Chinese Chess port for
PortMaster. It uses SDL2, the Exact Chinese Chess C rules engine, PNG-style
board artwork converted to BMP runtime assets, and optional bundled Pikafish
for stronger AI.

The rules and built-in AI were adapted with reference to the GPLv3
XMuli/ChineseChess project. The board/piece artwork and several UX/engine
integration ideas were taken or cross-checked with the MIT-licensed
Augus1217/Chinese-Chess project. Strong AI play uses the GPLv3 Pikafish engine.

Thanks to Slayer366 for helping test this PortMaster release across devices and
firmware.

## Controls

| Button | Action |
|--|--|
| D-pad | Move board cursor |
| A | Select piece / move |
| B | Cancel selection / close dropdown |
| X | Undo |
| Y | New game |
| L1 | Previous reviewed move |
| R2 | Next reviewed move |
| Right stick | Move UI pointer |
| R1 | Click UI pointer |
| Start | Cycle Main / Moves / Help panel |
| Select / Back | Quit |

## AI Levels

| Level | Behavior |
|--|--|
| Easy | Pikafish MultiPV 4, depth 1; sometimes chooses candidates 2-4 |
| Medium | Pikafish MultiPV 4, depth 1; less often chooses candidates 2-4 |
| Hard | Pikafish MultiPV 1, movetime 1200 ms |

## Compile

This release package is built with the PortMaster aarch64 builder:

```sh
cd path/to/exact-chinesechess
docker run --rm --platform=linux/arm64 \
  -v "$PWD:/src/exact-chinesechess" \
  -w /src/exact-chinesechess/portmaster \
  ghcr.io/monkeyx-net/portmaster-build-templates/portmaster-builder:aarch64-latest \
  make clean all package-layout DEVICE_ARCH=aarch64
```
