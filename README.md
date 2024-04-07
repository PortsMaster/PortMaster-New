## PortMaster

PortMaster is a simple tool that allows easy installation of Ports for devices running AmberELEC, ArkOS, JelOS, RetroOZ, TheRA, and EmuELEC for various handheld linux based devices. 

One of the goals of PortMaster is to not install or upgrade any existing OS libraries for any ports. Any of the ports that need a particular non standard library are maintained within the ports' folder and made available specifically to that port during execution.

To learn more visit [portmaster.games](https://portmaster.games/).


## Nitty gritty details

PortMaster used to be a collection of zips inside of a git repo, this got unwieldy, especially now that we have 300+ ports. It was impossible to tell from one release to the next what files were actually changed. It made checking scripts incredibly hard, and even harder to learn from other ports.

The PortMaster-New repo now has all the ports unzipped, this makes the repo slightly larger initially, however changes will no longer greatly increase the size. The release system intelligently 

## Submitting a PR

To submit a PR you will have to fork the repo. After forking the repo, go into the settings for the fork and disable github actions for your fork.

Afterwards you can clone the repo, and you should run the newly made `tools/prepare_repo.sh` from the root of repo. This will download the latest files from the release system.

```bash
tools/prepare_repo.sh
```

From there you can create a new directory in `ports/` for your new port, be sure to check the below `New Port Structure` section to make sure your port has all the required files.

After your port has been added and you are ready to submit it, you can run the `build_release.py` script to check if your port adheres to the port standards.

```bash
python3 tools/build_release.py --do-check
```

This will check your port to make sure it has all the required files, and will warn of any issues.

If you add a file that is larger than 90+ MB, you will have to run the script `tools/build_data.py`. It will split the file into 50mb chunks suitable for committing to github. If you edit the large-file just rerun the above script and it will update the chunks. This also adds the file to `.gitginore` in the ports directory so that the large file will not be committed to the repo.

From there you can do a PR and it will be checked again, portmaster crew members will double check it once again.

You can use the build_release.py to build the zips of any ports that have changed.

```bash
python3 tools/build_release.py
```

Your port zips will then be in `releases/`, these are suitable for posting to discord for testing.

---------------------------------------------

### Portname requirements

The **portname** must start with either a lowercase letter (a-z) or a number (0-9).

You can then have a combination of lowercase letters (a-z), numbers (0-9), periods (.), or underscores (\_).

There is no limit on the length of the name, but keep it short.

This name must not clash with any other existing ports.

### New Port Structure:

Ports are now contained within the `port` top level directory, each port has its own sub-directory named after the port itself. Each port must adhere to the `portname` rules stated above. Each port must have a `port.json`, `screenshot.{jpg,png}`, `README.md`, a port script and a port directory. It may optionally include a `cover.{jpg,png}` and a `gameinfo.xml`.

The script should have capital letters (like `Port Name.sh`) and must end in `.sh`, the port directory should be the same as the containing directory. Some legacy ports have different names, new ports won't be accepted unless they follow the new convention.

Scripts and port directories must be unique across the whole project, checks will be run to ensure this is right.

A port directory might look like the following:

```
- portname/
  - port.json
  - README.md
  - screenshot.jpg
  - cover.jpg
  - gameinfo.xml
  - Port Name.sh
  - portname/
    - <portfiles here>
```

The above file structure would create a `portname.zip` file.

#### README.md

This adds additional info for the port on the wiki, [we have a handy README.md generator here](http://portmaster.games/port-markdown.html).

```markdown
## Notes

{ADDITIONAL NOTES HERE}

Thanks to {THANKS INFO HERE} for the source code. Also thanks to {PORTER NAME} for the packaging for portmaster.

```

#### port.json

This is used by portmaster, this should include all the pertinent info for the port, [we have a handy port.json generator here](http://portmaster.games/port-json.html).

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
        "reqs": [],
        "arch": [
            "aarch64",
            "armhf"
        ]
    }
}
```


## TODO:

- [x] Load port data
- [x] Check port has reqired files
- [ ] Check for common errors in ports.
- [ ] Check for gameinfo.xml errors.
- [x] Check if port clashes with other ports
- [x] Run port.spec before zipping port
- [x] Create portname.zip only if port is changed
- [x] Run in `--do-check` for PR pre-check
- [x] Create ports.json
- [x] Create markdown.zip
- [x] Create images.zip
