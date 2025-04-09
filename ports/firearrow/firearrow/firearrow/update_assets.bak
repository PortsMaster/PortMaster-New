#!/bin/bash 

GAMEDIR="/$directory/ports/firearrow"
 
cd "$GAMEDIR"
$ESUDO mkdir -p firearrowpatch/assets/

for ogg_file in gamedata/*.ogg; do
    $ESUDO mv "$ogg_file" firearrowpatch/assets/
done


# Needed libs for the tools used to patch

# Running these commands as SUDO is terrible, but if you don't, it fails on ArkOS
# On other supported platforms you're sudo by default so eh
# Unzip and Structure files
$ESUDO utils/unzip "firearrowrapper.apk" -d firearrowpatch/ 
export LD_LIBRARY_PATH=$(pwd)/utils/lib::$LD_LIBRARY_PATH

# Create final archive
cd firearrowpatch
$ESUDO ../utils/zip -r -0 ../firearrowpatch.zip *
cd ..
mv firearrowpatch.zip firearrowrapper.apk

$ESUDO rm -r firearrowpatch
