# SteamLink - Linux Arm64
This SteamLink wrapper automatically checks for a SteamLink binary and, if one is found, it checks a `version.txt` file and compares the contents to the latest available. If there is no `version.txt` file or there is a new version, SteamLink is downloaded automatically with wget.

Don't have wget or curl? Go here: http://cdn.origin.steamstatic.com/steamlink/rpi/bookworm/arm64/public_build.txt and use the URL from that file to download the latest SteamLink binary. Perform the following manually:
- Extract `steamlink/bin/shell` to `ports/steamlink/bin/shell`
- Extract `steamlink/lib/` contents to `ports/steamlink/libs.aarch64`
- Extract folder `Qt-x.xx.x/` to `ports/steamlink/`

## Disclaimers
SteamLink requires a display manager to set up its overlay and stream. You can get the application to boot and adjust some settings, but it won't work on kmsdrm yet. Please use Panfrost if available.

## Thanks
A million thanks to [Noxwell](https://github.com/beebono/SLink-RPCompat) for their work on this, where the previous version of this wrapper was not functioning.