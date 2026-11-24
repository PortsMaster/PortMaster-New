#!/bin/bash
# First-launch setup for the DRM-free GOG 1.06 build: weaves the MonoMod patch into
# a copy of JumpKing.exe, converts the game's RGBA textures to ASTC 4x4, installs the
# port's DLLs and shader, and only then replaces JumpKing.exe as the very last step.
#
# The original exe is never modified until everything else has succeeded, so a
# failed run leaves it untouched and no backup or progress marker is needed: the
# launcher treats an exe without the MonoMod marker as "setup not done". The
# textures in Content are converted in place, so players must point the port at
# a copy of their GOG folder. The patch is woven first into
# MONOMODDED_JumpKing.exe so a wrong exe fails in seconds
# instead of after the texture conversion. Re-running is safe: converted textures
# are skipped.
#
# The launcher mounts the PortMaster Mono runtime before this runs and exports
# MONODIR, so MonoMod and the game use the same runtime.

GAMEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GAMEDATA="$GAMEDIR/gamedata"
CONTENT="$GAMEDATA/Content"
TOOLS="$GAMEDIR/tools"
PATCHLOG="$GAMEDIR/patchlog.txt"
PATCH_DLL="$GAMEDIR/patches/JumpKing.mm.dll"
MONOMOD="$GAMEDIR/monomod/MonoMod.exe"
MONODIR="${MONODIR:-$HOME/mono}"
MONO="${MONO:-$MONODIR/bin/mono}"
NEWEXE="$GAMEDATA/MONOMODDED_JumpKing.exe"

> "$PATCHLOG"
exec > >(tee -a "$PATCHLOG") 2>&1

log() { echo "[$(date '+%H:%M:%S')] $*"; }

cleanup() {
  rm -f "$NEWEXE" "$NEWEXE.mdb" "$GAMEDATA/MONOMODDED_JumpKing.pdb" "$GAMEDATA/JumpKing.mm.dll"
}
trap cleanup EXIT

fail() {
  log "FAILED: $1"
  echo "PATCH_FAIL_MSG:$1"
  echo "Patching process failed!"
  sleep 5
  exit 1
}

export PATH="$MONODIR/bin:$PATH"
export MONO_PATH="$GAMEDIR/dlls:$GAMEDATA:$GAMEDIR/monomod"
export LD_LIBRARY_PATH="$MONODIR/lib:/usr/lib:$LD_LIBRARY_PATH"
DEPDIRS="$GAMEDIR/dlls:$GAMEDATA:$GAMEDIR/monomod:$MONODIR/lib/mono/4.5:$MONODIR/lib/mono/4.5/Facades"

if [ ! -f "$GAMEDATA/JumpKing.exe" ] || [ ! -d "$CONTENT" ]; then
  fail "Jump King's game files were not found. Copy a spare copy of your DRM-free GOG Jump King 1.06 folder (JumpKing.exe and Content/) into ports/jumpking/gamedata and launch again."
fi
[ -x "$MONO" ] || fail "The Mono runtime is not mounted. Launch the port from PortMaster and try again."
for f in "$PATCH_DLL" "$MONOMOD" "$TOOLS/jk_astc_patch" "$TOOLS/astcenc"; do
  [ -f "$f" ] || fail "Missing $(basename "$f"). Try reinstalling the port."
done

# Weave the patch into a copy of the exe without touching the original. This checks
# the patch against the player's GOG 1.06 exe now; the swap happens at the end.
log "Checking JumpKing.exe with MonoMod..."
cp -f "$PATCH_DLL" "$GAMEDATA/JumpKing.mm.dll" || fail "Could not copy the patch assembly."
if ! ( cd "$GAMEDATA" && MONOMOD_DEPDIRS="$DEPDIRS" "$MONO" "$MONOMOD" JumpKing.exe ); then
  fail "The executable patch did not apply. Copy a clean, unmodified DRM-free GOG Jump King 1.06 game folder into gamedata and launch again. Steam copies are not supported."
fi
[ -f "$NEWEXE" ] || fail "MonoMod did not produce a patched executable. See patchlog.txt for details."
grep -aq MonoModAdded "$NEWEXE" || fail "The patched executable is missing the MonoMod marker. See patchlog.txt for details."

chmod +x "$TOOLS/jk_astc_patch" "$TOOLS/astcenc"

cores=$(nproc 2>/dev/null || echo 2)
maxjobs=$((cores - 1))
[ "$maxjobs" -lt 2 ] && maxjobs=2
[ "$maxjobs" -gt 4 ] && maxjobs=4

pids=()
fails=0

log "Converting textures with up to $maxjobs parallel jobs."
while IFS= read -r dir; do
  "$TOOLS/jk_astc_patch" "$dir" "$TOOLS/astcenc" -fastest 1 --maxdepth 0 &
  pids+=($!)
  if [ "${#pids[@]}" -ge "$maxjobs" ]; then
    wait "${pids[0]}" || fails=$((fails + 1))
    pids=("${pids[@]:1}")
  fi
done < <(find "$CONTENT" -type f -name '*.xnb' | sed 's|/[^/]*$||' | sort -u)

for pid in "${pids[@]}"; do
  wait "$pid" || fails=$((fails + 1))
done

[ "$fails" -eq 0 ] || fail "The texture conversion failed, see patchlog.txt for more info"

# The game folder's own Windows MonoGame.Framework.dll and SlimDX.dll are replaced with the port's
# DesktopGL build and stubs, and the DirectX-only Mask shader with the OpenGL replacement.
cp -f "$GAMEDIR"/dlls/* "$GAMEDATA/" || fail "Could not copy the port's libraries into gamedata."
cp -f "$TOOLS/Mask.xnb" "$CONTENT/shaders/" || fail "Could not install the OpenGL Mask shader. Check that gamedata/Content/shaders exists."

# Last step: replace the exe with the patched copy. This is also what marks setup as done.
log "Installing patched JumpKing.exe..."
mv -f "$NEWEXE" "$GAMEDATA/JumpKing.exe" || fail "Could not replace JumpKing.exe."
log "Jump King patch finished."
