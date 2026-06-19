# OpenJKDF2 — Multiplayer guide

This port supports **JKDF2 LAN multiplayer** on **aarch64 handhelds** and **x86_64 Linux** (RetroDECK, desktop, VPS). Networking uses **Valve GameNetworkingSockets (GNS)** — the multiplayer menu should show provider **Valve GNS**.

There is **no Steam matchmaking**, **no server browser**, and **no automatic Internet NAT traversal** in this build. Players connect by typing **IP:port** in **Join Game** (or via `mp.conf` `[join] host=`), optionally over a VPN such as **Tailscale**.

---

## What you need

| Requirement | Notes |
|-------------|--------|
| **Legal game files** | You must own JKDF2. Copy GOG/Steam data into `jk1/`. MOTS also needs `mots/` (see `mots/README.txt`). |
| **`JK1MP.gob`** | Under `jk1/episode/` — required for JKDF2 multiplayer maps. |
| **`JKM_MP.goo`** | Under `mots/episode/` — required for MOTS multiplayer (`run-dedicated.sh --mots`). |
| **Port zip libs** | Do not delete bundled networking libraries (see below). |
| **Same reachable network** | LAN, Tailscale tailnet, or public IP + open UDP port. |

### Bundled libraries (do not remove)

Most Linux systems ship **OpenSSL 3** (`libcrypto.so.3`). GNS was built against **OpenSSL 1.1**, so the port ships:

| Architecture | Path |
|--------------|------|
| Handheld | `libs.aarch64/libGameNetworkingSockets.so`, `libcrypto.so.1.1`, `libssl.so.1.1`, `libopenal.so` |
| PC / VPS | `libs.x86_64/libGameNetworkingSockets.so`, `libcrypto.so.1.1`, `libssl.so.1.1` |

If `libcrypto.so.1.1` is missing, `log.txt` shows:

```text
Failed to dlopen libGameNetworkingSockets.so.  libcrypto.so.1.1: cannot open shared object file
```

and the provider becomes **Screaming Into The Void (GNS Failed)**.

**Default game port:** UDP **27020** (configurable in `mp.conf` when hosting from the menu).

---

## Quick install (from zip)

1. Download / unzip the port to your `ports/` folder (PortMaster) or any directory (VPS).
2. Copy JKDF2 files into `openjkdf2/jk1/` (`episode/`, `resource/`, etc.).
3. Confirm `openjkdf2/jk1/episode/JK1MP.gob` exists.
4. (Optional) Copy `conf/mp.conf.example` → `conf/mp.conf` and edit on a PC.

On handhelds, launch **Star Wars Jedi Knight - Dark Forces II** from PortMaster.  
On PC, use the PortMaster `.sh` launcher or `./openjkdf2.x86_64` from this folder with `LD_LIBRARY_PATH=libs.x86_64`.

---

## `mp.conf` — multiplayer defaults

**Path:** `openjkdf2/conf/mp.conf` (create from `mp.conf.example`).

The engine reads this file so handheld users can avoid typing IPs and character names. Edit on a PC; the SD card path on device is the same relative to `openjkdf2/`.

### `[join]` — client / Join Game

| Key | Description |
|-----|-------------|
| `host` | Server IP or `IP:port` (e.g. `192.168.1.42:27020` or Tailscale `100.64.12.34:27020`) |
| `password` | Optional match password |

Applied when you open **Multiplayer → Join Game** (prefills the IP text field on the join screen).

**Important:** there is **no server browser**. **Join Game** does not discover LAN games by itself. You type a server **IP:port**, wait a few seconds, and the engine **queries that address**; if a match is running, it appears in the list below. You must **select the game** and press OK.

| Address | Use when |
|---------|----------|
| `127.0.0.1:27020` | Server and client on the **same PC** (testing) |
| `192.168.x.x:27020` | **LAN** (IP of the hosting machine) |
| `100.x.x.x:27020` | **Tailscale** (tailnet IP of the host) |

**Do not use `localhost` for local testing.** On many Linux systems `localhost` resolves to IPv6 `::1` first, while the dedicated server listens on IPv4. Use **`127.0.0.1:27020`** instead.

Format is always **`IP:port`** (colon), e.g. `192.168.1.42:27020`. If you omit the port, the client defaults to **27020**.

### `[character]` — New Character / auto-load

| Key | Description |
|-----|-------------|
| `name` | Multiplayer character name (prefills **New Character**) |
| `rank` | Jedi rank `0`–`8` |

- **New Character:** name and rank are prefilled — confirm to create the `.mpc` without a keyboard.
- **Join / host:** if a matching `.mpc` already exists, it is loaded automatically.

### `[host]` — Start Game defaults

| Key | Description |
|-----|-------------|
| `game_name` | Lobby name |
| `max_players` | Player slots |
| `port` | UDP port (default `27020`) |
| `episode` | e.g. `JK1MP.gob` |
| `map` | e.g. `m2.jkl` |
| `max_rank` | Max Jedi rank `0`–`8` |
| `score_limit` | Score limit (0 = off) |
| `time_limit` | Minutes (0 = off) |
| `teams` | `0` / `1` |
| `single_level` | `0` / `1` |
| `tick_rate` | Sim tick rate (e.g. `20`) |
| `password` | Optional password |
| `dedicated` | `1` = dedicated server (host does not play) |
| `coop` | `0` / `1` coop episode mode |

Applied when you open **Multiplayer → Start Game** (after loading saved host settings from `conf/openjkdf2/`).

### Example: handheld joins to game on LAN

```ini
[join]
host=192.168.1.42:27020
password=

[character]
name=Kyle
rank=0
```

### Example: dedicated-style host defaults (menu)

```ini
[host]
game_name=Friday FFA
max_players=8
port=27020
episode=JK1MP.gob
map=m2.jkl
max_rank=8
score_limit=10
time_limit=10
password=secret
dedicated=1
```

---

## LAN multiplayer

### PC hosts, handheld joins (typical)

1. **Host:** launch game → **Multiplayer → Start Game** → configure → start.
2. Note host **LAN IP** (`ip addr`, router DHCP list, etc.).
3. **Client:** set `mp.conf` `[join] host=` to that IP (or type it in the **Join Game** IP field), launch → **Join Game** → wait for the game in the list → OK.

### Handheld vs handheld / PC vs PC

Any combination works if all devices are on the **same LAN** and the host’s UDP port is reachable.

### Verify GNS loaded

Open `openjkdf2/log.txt` and look for:

```text
Loaded libGameNetworkingSockets.so successfully.
```

In the multiplayer UI, provider should be **Valve GNS**.

### Join Game (step by step)

1. Start the server (`./run-dedicated.sh`, **Start Game**, or Docker — see below).
2. Launch the client → **Multiplayer → Join Game**.
3. Choose provider **Valve GNS** → OK.
4. Type the server address in the **IP field** (e.g. `127.0.0.1:27020`), or rely on `mp.conf` `[join] host=`.
5. Wait a few seconds — the match should appear in **Choose a game**.
6. Select it, enter the password if required, press OK, pick/load your character.

If the list stays empty, see [Testing connectivity](#testing-connectivity-udp) and [Troubleshooting](#troubleshooting).

---

## Testing connectivity (UDP)

Multiplayer uses **UDP port 27020** (GNS), **not TCP**. **Telnet will not work** — it only tests TCP.

With the server running:

```bash
# Is anything listening on UDP 27020?
ss -ulnp | grep 27020
# or: sudo lsof -i UDP:27020

# Compare IPv4 vs IPv6 (explains localhost vs 127.0.0.1)
getent ahosts localhost
nc -u -v -w 2 127.0.0.1 27020
nc -u -v -w 2 ::1 27020

# Optional scan (UDP often shows open|filtered even when the game works)
nmap -sU -p 27020 127.0.0.1
```

**Docker:** confirm the publish mapping:

```bash
docker ps
docker port openjkdf2-mpserver
```

Clients connect to the **host** IP (`127.0.0.1` from the same machine, or the VPS/LAN address). `0.0.0.0` is only the server **bind** side (“all interfaces”), not an address you type in the game.

---

## Dev console (dedicated / headless)

`run-dedicated.sh` passes **`-headless`**, which enables a **stdin dev console** on Linux (no window needed). The process prints a `>` prompt; type a command and press **Enter**.

**Native or Docker foreground:**

```bash
./run-dedicated.sh
# or
./run-dedicated.sh --docker run
```

Example:

```text
> help
> players
> ping
> session
```

Useful server commands include **`help`**, **`players`**, **`kick`**, **`boot`**, **`ping`**, **`session`**, **`tick`**, **`version`**. Output goes to the terminal and to **`openjkdf2/log.txt`**.

On a desktop build **with** a display, the tilde key opens the Quake-style overlay console instead; the headless stdin console is for VPS/Docker/SSH.

---

## Playing over the Internet (without classic LAN)

GNS in this port does **not** punch through home routers by itself. Use one of:

### Option A — Tailscale (recommended for friends)

1. Install [Tailscale](https://tailscale.com/) on host and all clients.
2. Host the game on one machine in the tailnet.
3. Clients use the host’s **Tailscale IP** (`100.x.x.x`) in `mp.conf`:

```ini
[join]
host=100.64.12.34:27020
```

No router port forwarding required.

### Option B — Public VPS dedicated server

1. Rent a Linux **x86_64** or **aarch64** VPS.
2. Unzip this port, copy `jk1/` game data.
3. Open **UDP 27020** (or your port) in the VPS firewall.
4. Run `./run-dedicated.sh` (see below).
5. Clients join with the VPS **public IP** in `mp.conf`.

### Option C — Home PC + port forwarding

Forward **UDP 27020** on your router to the hosting PC. Clients use your **public IP** (or dynamic DNS). Less reliable than Tailscale (CGNAT, changing IPs).

---

## Dedicated server (`run-dedicated.sh`)

A **dedicated** server simulates the match and accepts clients but **does not play as a human**. Useful for a VPS or a PC that only hosts.

### From the zip (VPS / headless Linux)

```bash
cd openjkdf2
chmod +x run-dedicated.sh
./run-dedicated.sh
```

**Prerequisites:**

- Linux **x86_64** or **aarch64**
- JKDF2 data with `JK1MP.gob` / `JK1MP.GOB` (in `jk1/`, `OPENJKDF2_ROOT`, or auto-detected Steam)
- `openjkdf2.$DEVICE_ARCH` + `libs.$DEVICE_ARCH/` present
- Firewall allows **UDP 27020** (or configured port)

**Steam note:** game files live under `Star Wars Jedi Knight/` (`Episode/JK1MP.GOB`), not the OpenJKDF2 config folder `Star Wars Jedi Knight - Dark Forces II/`. If `jk1/` is empty, `run-dedicated.sh` auto-detects Steam; or set:

```bash
OPENJKDF2_ROOT="$HOME/.local/share/Steam/steamapps/common/Star Wars Jedi Knight" ./run-dedicated.sh
```

The script:

- Picks `openjkdf2.${DEVICE_ARCH}` and `libs.${DEVICE_ARCH}/` (`DEVICE_ARCH` defaults to `uname -m`)
- Sets `LD_LIBRARY_PATH` to the matching `libs.*` folder
- Sets `OPENJKDF2_ROOT` and `XDG_DATA_HOME=conf/`
- Reads `[host] episode` / `map` from `conf/mp.conf` if present
- On VPS without `DISPLAY`, sets `SDL_VIDEODRIVER=offscreen` and `LIBGL_ALWAYS_SOFTWARE=1`
- Launches: `-dedicatedServer -autostart -mp -headless -verboseNetworking`
- **JKDF2 (default):** episode `JK1MP`, map `m2`
- **MOTS (`--mots`):** adds `-motsCompat`, episode `JKM_MP`, map `mdm02_freezer` (Carbon-freeze Chamber)

**Logs:** `openjkdf2/log.txt`

**Overrides:**

```bash
./run-dedicated.sh --episode JK1MP --map m2
OPENJKDF2_MP_MAP=m3 ./run-dedicated.sh
./run-dedicated.sh --mots
./run-dedicated.sh --mots --episode JKM_MP --map mdm15_homestead
OPENJKDF2_MOTS=1 ./run-dedicated.sh --map mdm10_gantry
```

### MOTS dedicated server

MOTS multiplayer is **less tested** than JKDF2. You need **both** `jk1/` (base JKDF2) and `mots/` (expansion). Clients must launch **Mysteries of the Sith** and join the same IP/port.

| Episode | Maps (examples) |
|---------|-----------------|
| `JKM_MP` | `mdm02_freezer`, `mdm15_homestead`, `mdm10_gantry`, `mdm14_throne`, … |
| `JKM_KFY` | Kill-the-Fool-with-the-Ysalamiri variants |
| `JKM_SABER` | Lightsaber-only duels |

Use `--episode` / `--map` or `[host]` in `mp.conf` (`.goo`/`.jkl` extensions are optional).

### VPS without a desktop (no X11 / Wayland)

You **do not** need Xorg, a window manager, or a physical display. The engine still creates a short-lived OpenGL context at startup (before `-headless` tears down rendering), so install basic Mesa userspace libraries:

```bash
# Debian / Ubuntu
sudo apt install libgl1 libegl1
```

`run-dedicated.sh` detects missing `DISPLAY` and `WAYLAND_DISPLAY` and sets:

| Variable | Value | Purpose |
|----------|-------|---------|
| `SDL_VIDEODRIVER` | `offscreen` | SDL GL context without X11/Wayland |
| `LIBGL_ALWAYS_SOFTWARE` | `1` | CPU rendering (llvmpipe) when there is no GPU |

Override if your VPS has a GPU and you prefer hardware GL:

```bash
LIBGL_ALWAYS_SOFTWARE=0 ./run-dedicated.sh
```

After startup, check `log.txt` for:

```text
Loaded libGameNetworkingSockets.so successfully.
Server listening on port 27020
```

If SDL fails with `x11 not available` or `wayland not available`, you are not in offscreen mode — confirm `DISPLAY` is unset and re-run the script (or set `SDL_VIDEODRIVER=offscreen` manually).

### Docker (`--docker` / `Dockerfile.mpserver`)

For VPS or homelab, the image uses the **same `openjkdf2/` tree as the PortMaster zip** (binaries, `libs.*`, `run-dedicated.sh`, …). The container installs **Mesa** and **SDL** from apt; **GNS** and **OpenSSL 1.1** come from `libs.*` in the port. Your game files stay on the host as **read-only** bind mounts (permissions unchanged).

**Prerequisites:** Docker, and a staged port tree (`./build.sh` from the repo, or unzip `openjkdf2.zip` on the server).

```bash
cd port/openjkdf2
export JKDF2_DATA="$HOME/.local/share/Steam/steamapps/common/Star Wars Jedi Knight"

./run-dedicated.sh --docker build
./run-dedicated.sh --docker up
docker logs -f openjkdf2-mpserver
```

**MOTS:**

```bash
export MOTS_DATA="$HOME/.local/share/Steam/steamapps/common/Jedi Knight Mysteries of the Sith"
./run-dedicated.sh --docker --mots
```

**Other commands:** `run` (foreground, interactive console), `down`, `restart`, `logs -f`, `ps` — after `--docker`:

```bash
./run-dedicated.sh --docker logs -f
./run-dedicated.sh --docker down
```

| Mount | Mode | Contents |
|-------|------|----------|
| `$JKDF2_DATA` → `/opt/openjkdf2/jk1` | read-only | Episode/, Resource/, … |
| `$MOTS_DATA` → `/opt/openjkdf2/mots` | read-only | MOTS data (optional) |
| volumen `openjkdf2-mp-conf` | read/write | `conf/mp.conf`, saves — not your Steam folder |
| tmpfs `/var/lib/openjkdf2` | in-container | If the bind mount is read-only, the entrypoint copies game data here once (host files never modified) |

**Variables:** `MP_DOCKER_IMAGE`, `MP_CONTAINER_NAME`, `MP_CONF_VOLUME`, `MP_PORT`.

#### Logs and console (background `up`)

Engine output goes to **stdout** and **`/opt/openjkdf2/log.txt`**.

**Safe — follow logs only** (Ctrl+C stops *following*, not the server):

```bash
docker logs -f openjkdf2-mpserver
```

**Interactive console** after `./run-dedicated.sh --docker up` (container must be started with a TTY — `run-dedicated.sh` uses `docker run -dit`):

```bash
docker attach --sig-proxy=false openjkdf2-mpserver
```

The game **turns off terminal echo** and redraws one line: `> yourcommand`. You will not see the usual double echo from the shell; the full line appears on the `>` prompt as you type. If typing looks broken (one stray character), recreate the container so it gets a TTY: `./run-dedicated.sh --docker down && ./run-dedicated.sh --docker up`.

Type commands at the `>` prompt. To leave without stopping the server:

| Keys | Effect |
|------|--------|
| **Ctrl+C** | Detach (safe with `--sig-proxy=false`) |
| **Ctrl+P**, then **Ctrl+Q** | Detach (classic Docker shortcut) |

**Do not** use plain `docker attach` without `--sig-proxy=false`: **Ctrl+C sends SIGINT to the game** and can shut down the server.

Read `log.txt` inside the container:

```bash
docker exec openjkdf2-mpserver tail -f /opt/openjkdf2/log.txt
```

Persistent settings live in the Docker volume **`openjkdf2-mp-conf`** → `/opt/openjkdf2/conf`. `log.txt` is not in that volume.

#### Dev console in Docker (summary)

| Mode | Command | Console |
|------|---------|---------|
| **Foreground** | `./run-dedicated.sh --docker run` | `>` prompt in your terminal. Ctrl+C stops the server (expected in foreground). |
| **Background** | `./run-dedicated.sh --docker up` | `docker logs -f` for output; `docker attach --sig-proxy=false …` to type commands. |

Example (foreground, local testing):

```bash
export JKDF2_DATA="$HOME/.local/share/Steam/steamapps/common/Star Wars Jedi Knight"
cd port/openjkdf2
./run-dedicated.sh --docker run
# wait for "Server listening on port 27020", then:
# > players
# > help
```

**Join from another client on the same host:** use **`127.0.0.1:27020`**, not `localhost`.

Edit `mp.conf` in the volume (once the container has run at least once):

```bash
docker run --rm -it -v openjkdf2-mp-conf:/conf alpine sh
# vi /conf/mp.conf
```

Or inspect the volume path: `docker volume inspect openjkdf2-mp-conf`.

### From the in-game menu

1. Set `dedicated=1` in `mp.conf` `[host]`, or toggle **Dedicated** in **Start Game**.
2. Launch normally and start the match.

The host machine still runs the full game binary (video, menus). On a VPS without a display, prefer `run-dedicated.sh`.

### Dedicated server implications

| Topic | Detail |
|-------|--------|
| **Slots** | Dedicated mode reserves the server slot; max human players is effectively `max_players - 1`. |
| **No graphics on VPS** | `-headless` skips rendering after startup; the sim still runs. Without a desktop, the script auto-sets `SDL_VIDEODRIVER=offscreen` and `LIBGL_ALWAYS_SOFTWARE=1` (needs `libgl1` / Mesa, not Xorg). |
| **Not a system service** | `run-dedicated.sh` is a foreground process — use `screen`, `tmux`, or systemd if you want 24/7. |
| **Security** | Exposing UDP to the Internet carries risk; use `password` in `[host]` and firewall allowlists when possible. |
| **Game files on server** | The VPS must legally hold a copy of JKDF2 data in `jk1/`. |
| **CLI vs `mp.conf`** | `run-dedicated.sh` reads **episode/map** from `mp.conf`. Port, password, and player limits from `[host]` are fully applied via the **Start Game** menu; hosting once from the menu saves settings under `conf/openjkdf2/` or `conf/openjkmots/`. |
| **MOTS multiplayer** | Use `./run-dedicated.sh --mots` on the server; clients launch MOTS. Less tested than JKDF2 — check `log.txt` if a map fails to load. |

### Example: systemd unit (optional)

```ini
[Unit]
Description=OpenJKDF2 dedicated server
After=network-online.target

[Service]
Type=simple
WorkingDirectory=/opt/openjkdf2
Environment=SDL_VIDEODRIVER=offscreen
Environment=LIBGL_ALWAYS_SOFTWARE=1
ExecStart=/opt/openjkdf2/run-dedicated.sh
Restart=on-failure
User=openjkdf2

[Install]
WantedBy=multi-user.target
```

Adjust paths and user. Open UDP in `iptables` / cloud firewall separately.

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| **GNS Failed** / **Screaming Into The Void** | Reinstall port zip; keep `libcrypto.so.1.1` + `libssl.so.1.1` in `libs.*`. |
| **Join Game list empty** | Server not running; wrong IP/port; used `localhost` instead of `127.0.0.1`; firewall blocks UDP; wait a few seconds after typing the IP. |
| **`localhost` fails, `127.0.0.1` works** | Expected on many Linux setups (IPv6 `::1` vs IPv4 listener). Always use `127.0.0.1:27020` locally. |
| **Couldn't connect to host** | Wrong IP/port, firewall, host not started, or not same network/VPN. |
| **JK1MP / episode error** | Copy `JK1MP.gob` to `jk1/episode/`. For MOTS: `JKM_MP.goo` in `mots/episode/`. |
| Join works on LAN but not Internet | Use Tailscale or forward UDP; GNS has no built-in relay. |
| Provider **Valve GNS** | Networking OK. |
| **Telnet to 27020 fails** | Normal — the game port is **UDP**, not TCP. Use `ss -ulnp` / `nc -u` (see [Testing connectivity](#testing-connectivity-udp)). |
| **No console in Docker `up` mode** | `docker attach --sig-proxy=false openjkdf2-mpserver`, or `./run-dedicated.sh --docker run` for foreground. |
| **Ctrl+C killed the server after `up`** | You used `docker attach` without `--sig-proxy=false`. Use `docker logs -f` for logs, or attach with `--sig-proxy=false`. |
| **Attach console shows one letter while typing** | Container was created without `-t`. Run `./run-dedicated.sh --docker down && ./run-dedicated.sh --docker up`, then attach again. Or use `./run-dedicated.sh --docker run` for a normal foreground console. |

Always check **`openjkdf2/log.txt`** on the device SD card or next to the binary on PC/VPS.

---

## What this port does *not* provide

- Steam friends / invites
- Public server list / LAN browser (broadcast code exists but is disabled)
- Automatic NAT hole punching (WebRTC/ICE is off in this build)
- Official LucasArts / Valve hosted infrastructure
- Guaranteed MOTS multiplayer (experimental; use `--mots` dedicated + MOTS client)

For most users: **LAN** or **Tailscale + `mp.conf`** is the intended experience. For 24/7 public servers: **VPS + `run-dedicated.sh` + firewall + `mp.conf` on clients**.
