#!/bin/bash 

GAMEDIR="/$directory/ports/SuperXYX"
 
cd "$GAMEDIR"
$SUDO mkdir -p SuperXYXpatch/assets/

for ogg_file in gamedata/*.ogg; do
    $SUDO mv "$ogg_file" SuperXYXpatch/assets/
done


# Needed libs for the tools used to patch

# Running these commands as SUDO is terrible, but if you don't, it fails on ArkOS
# On other supported platforms you're sudo by default so eh
# Unzip and Structure files
$SUDO utils/unzip "SuperXYXwrapper.apk" -d SuperXYXpatch/ 
LD_LIBRARY_PATH=$(pwd)/utils/lib 

# Create final archive
cd SuperXYXpatch
$SUDO ../utils/zip -r -0 ../SuperXYXpatch.zip *
cd ..
mv SuperXYXpatch.zip SuperXYXwrapper.apk

$SUDO rm -r SuperXYXpatch
