# Third-party notices

| file | covers | licence |
|---|---|---|
| `LICENSE-ftl.txt` | the port's own files: `FTL.sh`, `settings.ini`, `patches/` | MIT |
| `LICENSE-box64.txt` | `box64` v0.4.4 from [ptitSeb/box64](https://github.com/ptitSeb/box64), taken unmodified from the Ittle Dew port | MIT |
| `LICENSE-ftlhelm.txt`, `NOTICE-ftlhelm.txt` | `ftlhelm.so` and `ftlhelm.ini` from [mxmgorin/ftlhelm](https://github.com/mxmgorin/ftlhelm) | GPL-3.0-or-later with the additional terms in `NOTICE-ftlhelm.txt` |
| `TRADEMARKS-ftlhelm.md` | the ftlhelm name, logo and icon | trademarks, not under the GPL |
| `LICENSE-rust.txt` | the Rust standard library and the [libc](https://github.com/rust-lang/libc) crate, linked statically into `ftlhelm.so` | MIT (dual MIT / Apache-2.0 upstream) |

The source of `ftlhelm.so` is [v1.0.2](https://github.com/mxmgorin/ftlhelm/tree/v1.0.2) in the repository above; `make` there builds it.

`patches/fbo_patch.py` changes the game's binary in place on the device and
carries none of its code beyond the instruction pattern it searches for. The MIT above covers the port's files only.
