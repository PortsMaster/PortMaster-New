#!/bin/bash
# Extract the user's legal Bully: Anniversary Edition 1.4.311 files.

GAMEDIR=${1:-$(cd -- "$(dirname -- "$0")" && pwd)}
GAMEDATA="$GAMEDIR/gamedata"
STAGE="$GAMEDIR/.setup"
EXPECTED_MD5=47468f5ce23ad05dc2a855b2801133b5

mkdir -p "$GAMEDATA"

data_present() {
  [ -s "$GAMEDIR/libGame.so" ] && [ -s "$GAMEDIR/libc++_shared.so" ] || return 1
  for number in 0 1 2 3 4; do
    [ -s "$GAMEDIR/assets/data_${number}.zip" ] || return 1
    [ -s "$GAMEDIR/assets/data_${number}.zip.idx" ] || return 1
  done
  [ "$(md5sum "$GAMEDIR/libGame.so" 2>/dev/null | awk '{print $1}')" = "$EXPECTED_MD5" ]
}

# Remove the obsolete settings patch from older community builds.
rm -f "$GAMEDIR/assets/bully2_patch.zip"

data_present && exit 0

for tool in awk md5sum unzip; do
  command -v "$tool" >/dev/null 2>&1 || {
    echo "Bully setup: missing required tool: $tool" >&2
    exit 1
  }
done

rm -rf "$STAGE"
mkdir -p "$STAGE/assets" "$STAGE/splits" || exit 1

sources=()
for file in "$GAMEDATA"/* "$GAMEDIR"/*; do
  [ -f "$file" ] || continue
  case "${file,,}" in
    *.apk|*.apks|*.apkm|*.xapk|*.obb|*.zip) sources+=("$file") ;;
  esac
done

[ ${#sources[@]} -gt 0 ] || {
  echo "Bully setup: copy the complete legal 1.4.311 ARM64 APK to $GAMEDATA" >&2
  rm -rf "$STAGE"
  exit 1
}

bundle_number=0
for bundle in "${sources[@]}"; do
  while IFS= read -r entry; do
    bundle_number=$((bundle_number + 1))
    split="$STAGE/splits/${bundle_number}-${entry##*/}"
    if unzip -p "$bundle" "$entry" > "$split" 2>/dev/null && [ -s "$split" ]; then
      sources+=("$split")
    else
      rm -f "$split"
    fi
  done < <(unzip -l "$bundle" 2>/dev/null | awk '$1 ~ /^[0-9]+$/ && $4 ~ /[.]apk$/ {print $4}')
done

extract_entry() {
  destination=$1
  shift
  for source in "${sources[@]}"; do
    for entry in "$@"; do
      if unzip -p "$source" "$entry" > "$destination" 2>/dev/null \
          && [ -s "$destination" ]; then
        echo "Bully setup: extracted ${destination##*/}"
        return 0
      fi
      rm -f "$destination"
    done
  done
  return 1
}

library_source=
for source in "${sources[@]}"; do
  unzip -p "$source" lib/arm64-v8a/libGame.so > "$STAGE/libGame.so" 2>/dev/null || continue
  [ "$(md5sum "$STAGE/libGame.so" | awk '{print $1}')" = "$EXPECTED_MD5" ] || continue
  unzip -p "$source" lib/arm64-v8a/libc++_shared.so > "$STAGE/libc++_shared.so" 2>/dev/null || continue
  [ -s "$STAGE/libc++_shared.so" ] || continue
  library_source=$source
  break
done

[ -n "$library_source" ] || {
  echo "Bully setup: Bully 1.4.311 ARM64 libGame.so was not found" >&2
  rm -rf "$STAGE"
  exit 1
}

for number in 0 1 2 3 4; do
  extract_entry "$STAGE/assets/data_${number}.zip" \
    "assets/data_${number}.zip" "data_${number}.zip" \
    "com.rockstargames.bully/assets/data_${number}.zip" || exit 1
  extract_entry "$STAGE/assets/data_${number}.zip.idx" \
    "assets/data_${number}.zip.idx" "data_${number}.zip.idx" \
    "com.rockstargames.bully/assets/data_${number}.zip.idx" || exit 1
done

mkdir -p "$GAMEDIR/assets"
mv "$STAGE/libGame.so" "$STAGE/libc++_shared.so" "$GAMEDIR/"
for number in 0 1 2 3 4; do
  mv "$STAGE/assets/data_${number}.zip" "$STAGE/assets/data_${number}.zip.idx" "$GAMEDIR/assets/"
done
rm -rf "$STAGE"

data_present || {
  echo "Bully setup: extracted data is incomplete" >&2
  exit 1
}

echo "Bully setup: game data ready"
exit 0
