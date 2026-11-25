# gmtoolkit licensing

gmtoolkit is mixed-licensed. The combined binary is GPL-3.0-or-later. Most individual source files are MIT, with subtrees that are MPL-2.0 or GPL-3.0-or-later. Every source file carries an SPDX-License-Identifier header; that header is authoritative.

## Per-tree licensing

| Path                                       | License              | Origin                                                                  |
| ------------------------------------------ | -------------------- | ----------------------------------------------------------------------- |
| `include/Underanalyzer/**`, `src/Underanalyzer/**` | `MPL-2.0`            | C++ port of UnderminersTeam/Underanalyzer (the GML compiler library).   |
| `include/GMSLib/**`, `src/GMSLib/**`       | `GPL-3.0-or-later`   | C++ port of UnderminersTeam/UndertaleModTool's `UndertaleModLib/` (data model, compile bridge, per-chunk `SetGMS2Version()` detection in `SaveBackend/VersionDetect.cpp`). |
| Everything else under `src/` and `include/`| `MIT`                | Original work.                                                          |

Each ported file's header records the upstream file it was derived from and the pinned upstream commit it was ported at.

## License combination

The `GMSLib/` tree is statically linked into the binary, which makes the combined work GPL-3.0-or-later. MPL-2.0 is per-file copyleft and does not alter the combined work's license. MIT-licensed files remain MIT at the source level regardless of how the binary is licensed.

## Distributing as a runtime

gmtoolkit is meant to ship as a self-contained runtime that other projects invoke via shell. Shipping the binary this way is a "mere aggregation" under GPLv3 §5 — the invoking scripts and the gmtoolkit binary stay independently licensed because they communicate over a process boundary (argv + JSON), not through linking.

When packaging the binary into a squashfs (or any other runtime container), include alongside it:

* the `LICENSE.md` from this repo,
* `docs/LICENSE-GPL-3.0.txt`, `docs/LICENSE-MIT.txt`, `docs/LICENSE-MPL-2.0.txt`,
* `NOTICE`,
* a `SOURCE.txt` based on `docs/SOURCE.txt.template`, filled in with the upstream URL and the commit the binary was built from.

That covers GPL-3 §6's source-availability requirement for the binary. Wrapper scripts that invoke the runtime keep whatever license their project uses; they aren't combined works.

## Bundled dependencies

Fetched by `CMakeLists.txt` at configure time and statically linked into the binary:

| Dependency              | Upstream                                          | License             |
| ----------------------- | ------------------------------------------------- | ------------------- |
| `astc-encoder` 4.8.0    | https://github.com/ARM-software/astc-encoder      | Apache-2.0          |
| `bzip2` 1.0.8           | https://sourceware.org/bzip2                      | bzip2 (BSD-like)    |
| `libogg` 1.3.5          | https://github.com/xiph/ogg                       | BSD-3-Clause        |
| `libvorbis` 1.3.7       | https://github.com/xiph/vorbis                    | BSD-3-Clause        |
| `stb_image.h` + `stb_image_write.h` | https://github.com/nothings/stb (pinned commit) | MIT / public domain |

All are GPL-3-compatible.

## License texts

Full text of each license:

* `docs/LICENSE-MIT.txt`
* `docs/LICENSE-GPL-3.0.txt`
* `docs/LICENSE-MPL-2.0.txt`
* `NOTICE` — upstream attributions.
