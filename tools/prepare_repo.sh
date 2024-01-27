#!/bin/bash

cd releases/
rm -f *.json
rm -f images.zip
wget "https://github.com/PortsMaster/PortMaster-New/releases/latest/download/ports.json"
wget "https://github.com/PortsMaster/PortMaster-New/releases/latest/download/ports_status.json"
wget "https://github.com/PortsMaster/PortMaster-New/releases/latest/download/manifest.json"
wget "https://github.com/PortsMaster/PortMaster-New/releases/latest/download/images.zip"
cd ..

python3 tools/build_data.py
