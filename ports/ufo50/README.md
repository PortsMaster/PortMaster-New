## Installation
Purchase the game on Steam and copy all the data to `ports/ufo50/gamedata`. On first run the game will be patched.

## Performance Notes
This port features audio compression and texture repacking in an attempt to reduce memory usage. This is necessary in order for the port to run on the linux arm handhelds targeted. These handhelds are equipped with low-end rockchip or allwinner processors
and usually 1-2GB of memory, alongside Mali blob drivers. Low processing power, low memory, and low VRAM are all major things to watch for when running ports on these devices. The following are known issues that are, again, **conditionally existent due to hardware and gmloader-next constraints**.

- Games that use large rooms will have lower fps (Ninpek, Velgress, Planet Zoldath, etc).

## Thanks
Mossmouth -- The absolutely amazing game  
JohnnyOnFlame -- GMLoader-Next and TextureRepacker via UTMT  
Cyril aka kotzebuedog -- GMTools audio patcher  
mavica -- Display patch  
Testers & Devs from the PortMaster Discord