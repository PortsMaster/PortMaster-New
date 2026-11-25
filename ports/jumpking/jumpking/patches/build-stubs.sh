#!/bin/bash
# Rebuild the two headless DLL stubs shipped in dlls/ from patches/*.stub.cs.
# Requires a .NET SDK (Roslyn csc.dll) and Mono 4.5 reference assemblies.
# The .snk files hold only the public keys of the shipped assemblies, so the
# rebuilt DLLs keep the same strong-name identity as the ones in the port.
set -euo pipefail

PORTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PATCHES="$PORTDIR/patches"
DOTNET="${DOTNET:-dotnet}"
CSCDLL="${CSCDLL:-$(ls -1 "$HOME"/.dotnet/sdk/*/Roslyn/bincore/csc.dll 2>/dev/null | sort -V | tail -n 1)}"
MONOREF="${MONOREF:-${MONODIR:-$HOME/mono}/lib/mono/4.5}"

[ -f "$CSCDLL" ] || { echo "csc.dll not found: set CSCDLL to a Roslyn csc.dll path" >&2; exit 1; }
[ -d "$MONOREF" ] || { echo "Mono 4.5 reference assemblies not found: set MONOREF" >&2; exit 1; }

build_stub() {
  local source="$1" output="$2" key="$3"
  "$DOTNET" exec "$CSCDLL" -nologo -noconfig -nostdlib+ \
    -target:library -out:"$output" -delaysign+ -keyfile:"$PATCHES/$key" \
    -r:"$MONOREF/mscorlib.dll" -r:"$MONOREF/System.dll" -r:"$MONOREF/System.Core.dll" \
    "$PATCHES/$source"
}

build_stub SlimDX.stub.cs "$PORTDIR/dlls/SlimDX.dll" slimdx.pub.snk
build_stub System.Windows.Forms.stub.cs "$PORTDIR/dlls/System.Windows.Forms.dll" ms.pub.snk
