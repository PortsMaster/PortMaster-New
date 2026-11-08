# Third-party notices

| file | covers | licence |
|---|---|---|
| `LICENSE-slipstream.txt` | the port's own files: `Slipstream.sh`, `patches/` but for the Mono.Cecil libraries (`patches/aspect/` built from [slipstream-handheld](https://github.com/mxmgorin/slipstream-handheld)), `defaults/`, `screen.cfg`, `slipstream.runtimeconfig.json` | MIT |
| `LICENSE-FNA3D.txt` | `libs/libFNA3D.so.0`, [FNA3D](https://github.com/FNA-XNA/FNA3D) 23.10 from the Mute Crimson DX port, altered by the port's `patches/fna3d-highp.py` | zlib |
| `LICENSE-MojoShader.txt` | [MojoShader](https://github.com/icculus/mojoshader), built into `libFNA3D.so.0`, altered by the port's `patches/fna3d-highp.py` | zlib |
| `LICENSE-FAudio.txt` | `libs/libFAudio.so.0`, [FAudio](https://github.com/FNA-XNA/FAudio) 23.10, altered by the port's `patches/faudio-sdl-2.0.patch`, `patches/faudio-1024-quantum.patch` and `patches/faudio-song-no-device.patch` | zlib |
| `LICENSE-stb_vorbis.txt` | stb_vorbis, built into `libFAudio.so.0` | MIT or public domain |
| `LICENSE-Theorafile.txt` | `libs/libtheorafile.so`, [Theorafile](https://github.com/FNA-XNA/Theorafile), taken unmodified from the Mute Crimson DX port | zlib |
| `LICENSE-libogg.txt`, `LICENSE-libtheora.txt`, `LICENSE-libvorbis.txt` | libogg, libtheora and libvorbis, built into `libtheorafile.so` | BSD-3-Clause |
| `LICENSE-Mono.Cecil.txt` | `patches/aspect/Mono.Cecil.dll` and `Mono.Cecil.Rocks.dll`, [Mono.Cecil](https://github.com/jbevain/cecil) 0.11.6, unmodified from NuGet | MIT |
| `LICENSE-steamstub.txt` | `libs/libsteam_api.so`, the Steam API stub from the The Swapper port (its `LICENSE.Port.txt`) | MIT |

The scripts and programs in `patches/` work on the player's copy of
the game on the device and carry none of its bytes. The MIT above covers the
port's files only.
