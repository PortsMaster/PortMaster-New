# OpenJKDF2 — Multiplayer guide

This port supports **JKDF2 LAN multiplayer** on **aarch64 handhelds** and **x86_64 Linux** (RetroDECK, desktop, VPS). Networking uses **Valve GameNetworkingSockets (GNS)** — the multiplayer menu should show provider **Valve GNS**.

There is **no Steam matchmaking**, **no server browser**, and **no automatic Internet NAT traversal** in this build. Players connect by **IP address and port** (or via a VPN such as **Tailscale**).

---

## What you need

| Requirement | Notes |
|-------------|--------|
| **Legal game files** | You must own JKDF2. Copy GOG/Steam data into `jk1/`. |
| **`JK1MP.gob`** | Under `jk1/episode/` — required for multiplayer maps. |
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

Applied when you open **Multiplayer → Join Game**.

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
3. **Client:** set `mp.conf` `[join] host=` to that IP, launch → **Join Game**.

### Handheld vs handheld / PC vs PC

Any combination works if all devices are on the **same LAN** and the host’s UDP port is reachable.

### Verify GNS loaded

Open `openjkdf2/log.txt` and look for:

```text
Loaded libGameNetworkingSockets.so successfully.
```

In the multiplayer UI, provider should be **Valve GNS**.

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

- Linux **x86_64** or **aarch64** (`ARCH` from `$ARCH` or `uname -m`)
- `jk1/` with `JK1MP.gob`
- `openjkdf2.$ARCH` + `libs.$ARCH/` present
- Firewall allows **UDP 27020** (or configured port)

The script:

- Picks `openjkdf2.${ARCH}` and `libs.${ARCH}/` (`ARCH` defaults to `uname -m`)
- Sets `LD_LIBRARY_PATH` to the matching `libs.*` folder
- Sets `OPENJKDF2_ROOT` and `XDG_DATA_HOME=conf/`
- Reads `[host] episode` / `map` from `conf/mp.conf` if present
- Launches: `-dedicatedServer -autostart -mp -headless -verboseNetworking`

**Logs:** `openjkdf2/log.txt`

**Overrides:**

```bash
./run-dedicated.sh --episode JK1MP --map m2
OPENJKDF2_MP_MAP=m3 ./run-dedicated.sh
```

### From the in-game menu

1. Set `dedicated=1` in `mp.conf` `[host]`, or toggle **Dedicated** in **Start Game**.
2. Launch normally and start the match.

The host machine still runs the full game binary (video, menus). On a VPS without a display, prefer `run-dedicated.sh`.

### Dedicated server implications

| Topic | Detail |
|-------|--------|
| **Slots** | Dedicated mode reserves the server slot; max human players is effectively `max_players - 1`. |
| **No graphics on VPS** | `-headless` skips rendering; the sim still runs. |
| **Not a system service** | `run-dedicated.sh` is a foreground process — use `screen`, `tmux`, or systemd if you want 24/7. |
| **Security** | Exposing UDP to the Internet carries risk; use `password` in `[host]` and firewall allowlists when possible. |
| **Game files on server** | The VPS must legally hold a copy of JKDF2 data in `jk1/`. |
| **CLI vs `mp.conf`** | `run-dedicated.sh` reads **episode/map** from `mp.conf`. Port, password, and player limits from `[host]` are fully applied via the **Start Game** menu; hosting once from the menu saves settings under `conf/openjkdf2/`. |
| **MOTS multiplayer** | Not documented or tested for this port; use JKDF2 / `JK1MP.gob`. |

### Example: systemd unit (optional)

```ini
[Unit]
Description=OpenJKDF2 dedicated server
After=network-online.target

[Service]
Type=simple
WorkingDirectory=/opt/openjkdf2
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
| **Couldn't connect to host** | Wrong IP/port, firewall, host not started, or not same network/VPN. |
| **JK1MP / episode error** | Copy `JK1MP.gob` to `jk1/episode/`. |
| Join works on LAN but not Internet | Use Tailscale or forward UDP; GNS has no built-in relay. |
| Provider **Valve GNS** | Networking OK. |

Always check **`openjkdf2/log.txt`** on the device SD card or next to the binary on PC/VPS.

---

## What this port does *not* provide

- Steam friends / invites
- Public server list / LAN browser (broadcast code exists but is disabled)
- Automatic NAT hole punching (WebRTC/ICE is off in this build)
- Official LucasArts / Valve hosted infrastructure
- Guaranteed MOTS multiplayer

For most users: **LAN** or **Tailscale + `mp.conf`** is the intended experience. For 24/7 public servers: **VPS + `run-dedicated.sh` + firewall + `mp.conf` on clients**.
