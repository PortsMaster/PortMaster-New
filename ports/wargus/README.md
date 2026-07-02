## Notes
Thanks to the [Wargus Team](https://stratagus.com/index.html) for creating this game and making it available for free!

Thanks to Blizzard the original developers of WarCraft II. 

Thanks to my wife for giving me the time to work on this and her grandfather.

Thanks to Ganimoth, Dia, ImCoKeMaN and kloristech for contributing fixes, advice and testing.

Also thanks to the PortMaster team for the work they do - porting is a lot of work!

## Compile
In src/ use this command 
`docker buildx build --platform linux/arm64 --progress=plain -t wargus-build . && docker run --platform=linux/arm64 -it --rm --name wargusbuild wargus-build bash`

If you get issues running a multiplatform build on linux try install qemu manually
https://docs.docker.com/build/building/multi-platform/#install-qemu-manually

when it starts up in another shell run docker cp to copy the file out of the container
`docker cp wargusbuild:/wargus-portmaster.zip wargus-portmaster.zip`



## Controls

| Button | Action |
|--|--|
| A | Mouse Left Click |
| B | Mouse Right Click |
| X | **B** – Build |
| Y | **P** – Patrol |
| D-Pad | Mouse Movement |
| Left Analog | Mouse Movement |
| Right Analog | Screen Scroll |
| R2 | **Shift** – Queue Commands |
| L1 | **Ctrl** – Add Control Group |
| R1 | Select Control Group |
| Select | **Esc** – Menu / Cancel |
| Start | Menu / Chat |


### Control Groups

| Button | Action |
|--|--|
| X | **1** – Control Group 1 |
| A | **2** – Control Group 2 |
| B | **3** – Control Group 3 |
| Y | **4** – Control Group 4 |


### Hotkey Layer (Hold L2)

| Button | Action |
|--|--|
| A | **F** – Farm |
| B | **H** – Harvest / Town Hall |
| X | **B** – Build Menu / Barracks |
| Y | **P** – Patrol / Polymorph |
| Up | **S** – Stop |
| Down | **T** – Tower / Stand Ground |
| Left | **L** – Lumber Mill / Lightning |
| Right | **A** – Attack |


### Hotkey Extra Layer (Hold L2 + R2)

| Button | Action |
|--|--|
| A | **C** – Cancel |
| B | **U** – Upgrade |
| X | **D** – Death Coil |
| Y | **R** – Research / Repair |
| Up | **O** – Oil |
| Down | **Z** – Stop (Alt) |
| Left | **E** – Eye of Kilrogg |
| Right | **R** – Repair / Raise Dead |


### Text Input


Press Start + D-Pad Down to get into Text Input mode - press Start again to exit Text Input mode


| Button | Action |
|--|--|
| Up / Down | Cycle Letters |
| Right | Add Letter |
| Left / B | **Backspace** – Delete |
| A | **Enter** – Confirm |
| Select | **Tab** – Switch |
| Start | Exit Text Input |
