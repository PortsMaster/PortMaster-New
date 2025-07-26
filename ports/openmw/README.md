## Install

Copy your `The Elder Scrolls III: Morrowind GOTY Edition` data from the `Data_Files` folder into `ports/openmw/data`.

## Default Controls

| Button | Action|
| -- | -- |
| A | Activate |
| B | Inventory |
| X | Ready weapon |
| Y | Ready magic |
| L1 | Journal |
| L2 | Jump |
| R1 | Rest |
| R2 | Use |
| L3 | Sneak |
| R3 | Toggle POV |
| Guide | Quick save |
| Start | Menu |
| Select + L2 | Toggle Mouse Mode |
| Select + R2 | Toggle text input mode. |

## Mods

OpenMW supports a wide variety of mods, depending on your hardware you'll have varing levels of success in installing the more demanding mods. Some mods however can ***greatly*** improve performance and or gameplay.

The PortMaster port will automatically handle the following mods, extracting them and installing them if they are placed into `ports/openmw/mods/` fully zipped. By default we list the versions we have tested with, other versions may work.

It is ***highly*** recommended you install all the mods at once and not adding them piecemeal, especially the , if an unsupported mod is detected it will be placed into `ports/openmw/mods_unused/`.

Recommended performance/patch mods:

- Project Atlas: `Project Atlas-45399-0-7-5-1747751438.7z`
- Morrowind Optimization Patch: `Morrowind Optimization Patch-45384-1-18-0-1751572864.7z`
- Patch for Purists: `Patch for Purists-45096-4-0-2-1593803721.7z`

Other Mods:

- Accurate Attack: `Accurate Attack -23746.rar`
- Better Bodies: `Better Bodies (Manual)-3880-2-2.7z` ***not currently working***
- Better Heads: `Better Heads-42226-1-1.rar`
- Graphic Herbalism MWSE - OpenMW: `Graphic Herbalism MWSE - OpenMW-46599-1-04-1558643353.7z`
- OpenMW Containers Animated: `OpenMW Containers Animated-46232-1-2-2-1574060105.zip`
- Real Signposts: `Real Signposts-3879.zip`
- Weapon Sheathing: `WeaponSheathing1.6-OpenMW-46069-1-6-1565439130.7z`


## Thanks
- Bethesda -- The game.  
- openmw team -- Compiling openmw for x86_64 and creating such an awesome project.
- kloptops -- Compiling openmw and packaging the game for aarch64.  
- saint -- Configuring the port to be very playable.
- BinaryCounter -- Helping out with `libcrusty.so` and a custom `gl4es` build with support for texture compression.

## Compiling

See [BUILDING.md](https://github.com/PortsMaster/PortMaster-New/blob/main/ports/openmw/openmw/BUILDING.md) for building instructions.
