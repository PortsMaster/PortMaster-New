# Experimental update testing

| Firmware | Device | Result |
| --- | --- | --- |
| ArkOS | RX6H, 640×480 | Contributor reports working cutscenes, controls, barrels and display settings; full game completion not tested |
| ROCKNIX | Pending | Not tested |
| muOS | Pending | Not tested |
| dArkOS | Pending | Not tested |
| Knulli | Pending | Not tested |
| AmberELEC | Pending | Not tested |

Local automated checks cover options persistence/rebinding; barrel physics and PC asset references; MPEG decoding, audio/state restoration and presentation at 640×480, 720×720 and 1280×720. These are Windows SDL tests, not firmware/GPU tests. 1024×768 hardware testing is pending. Other supported CPUs are not tested.

The shortened PortMaster launcher differs from the RX6H launcher used in the device test. It requires a device retest. Existing screenshots/assets/game data and their licensing have not been re-audited; they remain from the original port. Additional menus are in Portuguese.

Before marking ready: rebuild with the standard PortMaster toolchain/shared C++ runtime, retest the revised launcher on device, complete the firmware/display matrix, review added menu labels and existing asset/font licensing. This is a draft for review, not a claim of compatibility or a release in the official catalog.
