## PortMaster

PortMaster is a simple tool that allows easy installation of Ports for devices running AmberELEC, ArkOS, JelOS, RetroOZ, TheRA, and EmuELEC for various handheld linux based devices. 

One of the goals of PortMaster is to not install or upgrade any existing OS libraries for any ports. Any of the ports that need a particular non standard library are maintained within the ports' folder and made available specifically to that port during execution.

To learn more visit [portmaster.games](https://portmaster.games/).


## Nitty gritty details

PortMaster used to be a collection of zips inside of a git repo, this got unwieldy, especially now that we have 300 ports. It was impossible to tell from one release to the next what files were actually changed. It made checking scripts incredibly hard.

The PortMaster-New repo now has all the ports unzipped, this makes the repo slightly larger initally. Upon release we download the previous release and only creates a new zip when the files actually change.

### New Port Structure:

```
- <portname>/
    - port.spec
    - port.json
    - README.md
    - screenshot.jpg
    - cover.jpg
    - PortName.sh
    - <portname>/
        - <portfiles here>
```

#### port.spec

This is a simple bash script that will be run in the ports directory, only include it if you need to do something special before the port is zipped up.

```bash
#!/bin/bash

cd portname/

# Create a data.tar.gz file and remove the data/ directory.
tar -cjf data.tar.gz data/
rm -fR data/
```

#### README.md

This adds additional info for the port on the wiki.

```markdown
## Notes

{ADDITIONAL NOTES HERE}

Thanks to {THANKS INFO HERE} for the source code. Also thanks to {PORTER NAME} for the packaging for portmaster.

```

#### port.json

This is used by portmaster, this should include all the pertinent info for the port, [we have a handy port.json generator here](LINK HERE).

```json
{

}
```

