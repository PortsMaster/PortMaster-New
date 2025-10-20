Max Payne Mobile Android version ported to ARM64 Linux devices.

A fugitive undercover cop framed for murder, hunted by cops and the mob, Max is a man with his back against the wall, fighting a battle he cannot hope to win. Max Payne is a relentless story-driven game about a man on the edge, fighting to clear his name while struggling to uncover the truth about his slain family amongst a myriad of plot-twists.

## Controls

| Button            | Description      |
|-------------------|------------------|
| A                 | Jump             |
| B                 | Crouch           |
| X                 | Reload           |
| Y                 | Use/Zoom         |
| L1                | Bullet time      |
| R1                | Shoot            |
| L2                | Previous Weapon  |
| R2                | Next Weapon      |
| D-Up              | Pain Killer      |
| D-Down            | Reload           |
| D-Left            | Previous Weapon  |
| D-Right           | Next Weapon      |
| Select+R1         | Quicksave        |
| Start             | Menu             |
| Left Stick        | Move             |
| Right Stick.      | Look/Aim         |
| Select+UP/DOWN    | Adjust Camera Y  |
| Select+LEFT/RIGHT | Adjust Camera X  |
## Compiling

```sh
$ git clone git@github.com:orktes/max_amd64.git
$ cd max_r36s
$ cmake .
$ make build # Builds just the maxpayne_arm64 binary
$ make package # Creates a PortMaster compliant package in the `package/` directory. This also creates a proper port.json and README.md for the distribution.
$ make archive # Same as above but creates an archive under `archive/`
```

For convenience, it's recommended to use the devcontainer under `.devcontainer/`. If using VSCode (or other IDEs with support for [devcontainers](https://containers.dev/)), the IDE should automatically detect the container and offer to reopen the project inside it. This provides a consistent development environment and simplifies the setup process.

Alternatively, you can use the provided `./scripts/build_with_docker.sh` (run from root of the repo) script to build the project inside a Docker container. This script will handle all the necessary steps and dependencies for you.