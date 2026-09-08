### Installation

You need a legally owned Unreal Tournament or Unreal Tournament GOTY installation. Copy these folders into `ports/ut99/gamedata/`:

- `Maps`
- `Music`
- `Sounds`

Merge the contents of the original `Textures` folder into `gamedata/Textures`. Keep the included 469e versions of `LadderFonts.utx` and `UWindowFonts.utx` when prompted. **Do not copy the original `System` folder**; doing so replaces the Linux patch files and prevents the port from starting.

### Controls

| Button | Action |
| :-- | :-- |
| Left stick | Move / strafe |
| Right stick | Aim |
| R1 / R2 | Primary / alternate fire |
| L1 / L2 | Next / previous weapon |
| L3 | Precision aim |
| R3 | Center view |
| A | Jump |
| B | Crouch |
| X | Activate / select |
| Y | Translocator |
| Start | Menu |
| Select | Scores |
| D-pad | Weapons 1–4 |

### Port details

This build uses the ARM64 engine from the Epic-approved [OldUnreal 469e patch](https://github.com/OldUnreal/UnrealTournamentPatches/releases/tag/v469e). Its native OpenGL ES 2 renderer is ported from [UT99-Android](https://github.com/Andiweli/UT99-Android) and rebuilt against the 469e ARM64 engine ABI. The Android APK itself is not used because PortMaster runs native Linux applications.

The launcher uses the current PortMaster display resolution and selects a matching GUI scale for 640x480 through 1280x720 handhelds. Configuration is saved under `ports/ut99/conf`. The package supports AArch64 PortMaster devices with two analog sticks, including the TrimUI Smart Pro and R36S-class RK3326 devices.

The package includes minimal glibc conversion modules for the Windows-1252 and UTF-16LE conversions required by UT469. The launcher supplies these modules on every firmware so systems with incomplete conversion tables, including tested TrimUI/CrossMix and ROCKNIX installations, start consistently.

The renderer requests a native GLES 2.0 context from the firmware SDL/EGL stack, avoiding the gl4es/XOpenGL texture-conversion path that corrupts this engine on some handheld drivers. Its 469e adaptation forces masked alpha for Canvas font draws and uses UWindow's software menu cursor so controller navigation does not depend on firmware pointer bounds. BGRA uploads, vertex-array objects, and detail textures are disabled for a conservative PowerVR, Mali, and Mesa-compatible GLES2 path.

### Source and build

The exact PortMaster renderer changes are included under `ut99/source`. Apply `NOpenGLESDrv469.patch` to [Andiweli/UT99-Android](https://github.com/Andiweli/UT99-Android) commit `85b1a9ada6ae28c422570d4603e57e4e4cef6eb1`, then follow `BUILD.md`. The build uses the public OldUnreal 469e SDK and links against the official 469e ARM64 engine modules. Binary hashes and third-party provenance are recorded in `ut99/SOURCE.md`.

### Testing

Community testing is documented in the [PortMaster testing thread](https://discord.com/channels/1122861252088172575/1544732545047068692). Confirmed reports cover TrimUI/CrossMix at 1280x720, ROCKNIX on Retroid Pocket 5, muOS on an RG34XXSP-class H700 device, and dARKOS/dARKOSRE on RK3326 at 640x480. Launcher and display detection were also logged on dARKOS at the optional 480x320 resolution. Official ArkOS and AmberELEC results should be added to the pull-request matrix if received; Knulli remains optional.

### Acknowledgements

Unreal Tournament is by Epic Games and Digital Extremes. Linux ARM64 support is maintained by the OldUnreal team. The GLES renderer descends from Maxim Kaxd's [ut99dc](https://github.com/maximqaxd/ut99dc) work and Andiweli's [UT99-Android](https://github.com/Andiweli/UT99-Android) fork. Thanks also to the OpenAL Soft contributors, the PortMaster team, and everyone who tested this port. PortMaster packaging and compatibility work is by ToastedFrog.
