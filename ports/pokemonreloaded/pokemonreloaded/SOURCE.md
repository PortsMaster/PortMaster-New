# Source code

The `gm8emulator` binary is a build of OpenGMK with the changes from Klisee's Android port and
the small R36S packaging changes used by this port.

- Upstream engine: <https://github.com/OpenGMK/OpenGMK> (GPL-2.0)
- Android/OpenGMK base: <https://github.com/Klisee/pokemon-reloaded-android> (GPL-2.0)
- Corresponding source snapshot: `source/opengmk-r36s-source.tar.gz`

## Build

The binary was cross-compiled for `aarch64-unknown-linux-gnu` with Rust and Zig's C compiler.
See `source/build-r36s.sh` inside the source archive. The build uses the `sdl` feature and no
default features:

```bash
cd src/OpenGMK
cargo build --release -p gm8emulator --bin gm8emulator \
  --no-default-features --features sdl \
  --target aarch64-unknown-linux-gnu
```

The centred build is the one published in this repository
(md5 `a4a026902dfc4f4584670759791d73c9`). The later `rightalign` experiment is not published.

If you redistribute the binary, comply with GPL-2.0 and make the corresponding source available.
