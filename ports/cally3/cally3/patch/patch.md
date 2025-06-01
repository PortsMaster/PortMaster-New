# Cally's Caves 3 – Patch Notes

## 📦 Patch Overview

This patch updates **Cally's Caves 3** by modifying its `data.win` file through a series of patches applied using **Undertale Mod Tool (UTMT)**.

The game was originally at version **0.15**, and has been upgraded using a combination of `.csx` scripts to integrate visual, compatibility, or content fixes from later versions.

## 🛠️ Patch Sequence

Using UTMT, the following `.csx` patch files were applied **in this specific order**:

1. `15.csx` – Base patch for version 0.15
2. `17.csx` – Jump forward to version 0.17
3. `16.csx` – Backported or merged with elements of 0.16

This multi-version patch sequence was necessary to achieve full compatibility and ensure all required features or optimizations were included.

## 🔄 Applying the Final Patch

Once patched using UTMT, the resulting `data.win` file was used to generate an `xdelta3` patch file, allowing users to upgrade from the original game version.

To apply:

```sh
xdelta3 -d -s ./data.win1/data.win ./patch.xdelta ./data.win
```

- `data.win1/data.win` = Original unmodified version (0.15)
- `patch.xdelta` = This patch
- `data.win` = Output file with updates from 0.15 → 0.17 → 0.16

## ✅ Result

- Final version is a custom hybrid of v0.17 features with necessary rollbacks or enhancements from v0.16.
- Confirmed compatible with the existing runner/launcher.
- Recommended for PortMaster use or direct APK modding setups.

---

**Created by MadShmupper** using UTMT, xdelta3.
