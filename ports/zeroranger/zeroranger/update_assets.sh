#!/bin/bash 

GAMEDIR="/$directory/ports/zeroranger"
 
cd "$GAMEDIR"
$SUDO mkdir -p zerorangerpatch/assets/

for ogg_file in gamedata/*.ogg; do
    $SUDO mv "$ogg_file" zerorangerpatch/assets/
done


# Needed libs for the tools used to patch

# Running these commands as SUDO is terrible, but if you don't, it fails on ArkOS
# On other supported platforms you're sudo by default so eh
# Unzip and Structure files
$SUDO utils/unzip "zeroranger.apk" -d zerorangerpatch/ 
LD_LIBRARY_PATH=$(pwd)/utils/lib 

# Create final archive
cd zerorangerpatch
$SUDO ../utils/zip -r -0 ../zeroranger.zip *
cd ..
mv zeroranger.zip zeroranger.apk 

$SUDO rm -r zerorangerpatch
