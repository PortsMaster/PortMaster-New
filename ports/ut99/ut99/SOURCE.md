# Source and binary provenance

- OldUnreal Tournament patch 469e, Linux ARM64: `OldUnreal-UTPatch469e-Linux-arm64.tar.bz2`
  - Release: https://github.com/OldUnreal/UnrealTournamentPatches/releases/tag/v469e
  - SHA-256: `4c3978073b12b049c3ffdeb4d275cfc7a2313650f3eb5b94db06fbfee77c3e3b`
- OldUnreal Tournament 469e public SDK: `OldUnreal-UTPatch469e-SDK.zip`
  - Release: https://github.com/OldUnreal/UnrealTournamentPatches/releases/tag/v469e
  - SHA-256: `b213789a18d736beacdf8bc2740bcc6e031789b806823b9f7eb3a75b2dacedcc`
- OpenAL Soft ARM64 library and license: copied from the official PortMaster RVGL port at the same PortMaster-New commit.
- Renderer lineage and control-layout reference:
  - Maxim Kaxd's original ut99dc project: https://github.com/maximqaxd/ut99dc
  - Andiweli's UT99-Android fork, pinned commit: https://github.com/Andiweli/UT99-Android/tree/85b1a9ada6ae28c422570d4603e57e4e4cef6eb1
- TrimUI/CrossMix gconv compatibility modules (`ISO8859-1.so`, `UTF-16.so`): https://github.com/cizia64/CrossMix-OS/issues/566
  - Attachment SHA-256: `cf948299eec5ccc8a1f498f4dcfe0916ce77389746a61fb55fd9f2c66235a4f4`
- `CP1252.so`: Ubuntu glibc 2.33 ARM64 package `libc6_2.33-0ubuntu5_arm64.deb`.
  - Package SHA-256: `05fbb121343e1161b1abe85367f09cea93b046e83a7f6ac15edb061ec8fbfee3`
  - Source: https://old-releases.ubuntu.com/ubuntu/pool/main/g/glibc/libc6_2.33-0ubuntu5_arm64.deb
- `NOpenGLESDrv.so`: native ARM64 OpenGL ES 2 renderer built from
  UT99-Android's `third_party/ut99dc/Source/NOpenGLESDrv` source at commit
  `85b1a9ada6ae28c422570d4603e57e4e4cef6eb1`, using the public OldUnreal 469e
  SDK headers. The local compatibility changes use 469e's render-device base
  class and SDL window lifecycle, force masked font uploads for 469e Canvas
  text, use UWindow's software cursor for consistent handheld pointer bounds,
  and retain the Android renderer's GLES2 texture and shader path.
  - Packaged binary SHA-256: `c6d8411e94fe8a279eb5664174243de5a2986a425e365604a113fb8dcf8bd161`
  - Exact compatibility patch: `source/NOpenGLESDrv469.patch`
  - Reproducible build project and instructions: `source/CMakeLists.txt`,
    `source/aarch64-linux.cmake`, `source/RenderPrivate.h`, and `source/BUILD.md`

The package intentionally excludes the original game's maps, music, sounds, and general textures. Supply those from a legal installation.

The upstream UT99-Android/ut99dc tree does not contain a standalone open-source
license covering the renderer at the pinned commit. Copyright and other rights
remain with their respective owners. See `licenses/LICENSE.NOpenGLESDrv.txt`;
redistribution approval should be confirmed with the upstream authors and the
PortMaster reviewers before an official release.
