#!/bin/bash

if [ ! -f "SOURCE_SETUP.txt" ]; then
    echo "run in root directory as tools/prepare_repo.sh"
    exit 255
fi

source SOURCE_SETUP.txt

cd releases/
rm -f *.json
rm -f images.zip
wget "https://github.com/${RELEASE_ORG}/${RELEASE_REPO}/releases/latest/download/ports.json"
wget "https://github.com/${RELEASE_ORG}/${RELEASE_REPO}/releases/latest/download/ports_status.json"
wget "https://github.com/${RELEASE_ORG}/${RELEASE_REPO}/releases/latest/download/manifest.json"
wget "https://github.com/${RELEASE_ORG}/${RELEASE_REPO}/releases/latest/download/images.zip"
wget "https://raw.githubusercontent.com/PortsMaster/PortMaster-Info/refs/heads/main/port_stats_raw.json"
cd ..

python3 tools/build_data.py
