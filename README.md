## PortMaster

PortMaster is a simple tool that allows easy installation of Ports for devices running AmberELEC, ArkOS, JelOS, RetroOZ, TheRA, and EmuELEC for various handheld linux based devices. 

One of the goals of PortMaster is to not install or upgrade any existing OS libraries for any ports. Any of the ports that need a particular non standard library are maintained within the ports' folder and made available specifically to that port during execution.

To learn more visit [portmaster.games](https://portmaster.games/).


## Nitty gritty details

PortMaster used to be a collection of zips inside of a git repo, this got unwieldy, especially now that we have 300+ ports. It was impossible to tell from one release to the next what files were actually changed. It made checking scripts incredibly hard, and even harder to learn from other ports.

The PortMaster-New repo now has all the ports unzipped, this makes the repo slightly larger initally, however changes will no longer greatly increase the size. Upon release we download the previous release and only create a new zip when the ports files actually change.

### Portname requirements

The portname must start with either a lowercase letter (a-z) or a number (0-9).

You can then have a combination of lowercase letters (a-z), numbers (0-9), periods (.), or underscores (\_).

There is no limit on the length of the name, but keep it short.

This name must not clash with any other existing ports.

### New Port Structure:

Ports are now contained within a top level directory, the directory `<portname>`, using the rules stated above. Each port must have a `port.json`, `screenshot.{jpg,png}`, `README.md`, a port script and a port directory. It may optionally include a `cover.{jpg,png}`.

The script should have capital letters (like `Port Name.sh`) and must end in `.sh`, the port directory should be the same as the containing directory. Some legacy ports have different names, new ports won't be accepted unless they follow the new convention.

Scripts and port directories must be unique across the whole project, checks will be run to ensure this is right.

A port directory might look like the following:

```
- portname/
  - port.json
  - README.md
  - screenshot.jpg
  - cover.jpg
  - Port Name.sh
  - portname/
    - <portfiles here>
```

The above file structure would create a `portname.zip` file.

#### README.md

This adds additional info for the port on the wiki.

```markdown
## Notes

{ADDITIONAL NOTES HERE}

Thanks to {THANKS INFO HERE} for the source code. Also thanks to {PORTER NAME} for the packaging for portmaster.

```

#### port.json

This is used by portmaster, this should include all the pertinent info for the port, [we have a handy port.json generator here](LINK HERE).

Example from 2048.

```json
{
    "version": 2,
    "name": "2048.zip",
    "items": [
        "2048.sh",
        "2048/"
    ],
    "items_opt": null,
    "attr": {
        "title": "2048",
        "desc": "The 2048 puzzle game",
        "inst": "Ready to run.",
        "genres": [
            "puzzle"
        ],
        "porter": [
            "Christian_Haitian"
        ],
        "image": {},
        "rtr": true,
        "runtime": null,
        "reqs": []
    }
}
```


## TODO:

- [x] Load port data
- [x] Check port has reqired files
- [ ] Check for common errors in ports.
- [x] Check if port clashes with other ports
- [x] Run port.spec before zipping port
- [x] Create portname.zip only if port is changed
- [ ] Run in `--do-check` for PR pre-check
- [ ] Create ports.json
- [x] Create markdown.zip
- [x] Create images.zip
