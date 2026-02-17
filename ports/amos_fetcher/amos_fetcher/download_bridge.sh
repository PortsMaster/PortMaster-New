#!/bin/bash
# Bridge script to handle downloads from the UI

PLATFORM=$1
PLATFORM_FOLDER=$2
REPO_PATH=$3

echo "Starting download for $PLATFORM..."
echo "Target folder: /storage/roms/$PLATFORM_FOLDER"
echo "Source: https://github.com/username/file-repository/tree/main/$REPO_PATH/"
echo ""

# Create target directory
mkdir -p "/storage/roms/$PLATFORM_FOLDER"

# Launch Python downloader with platform pre-selected
cd /storage/roms/ports/amos_fetcher
export PYTHONPATH="./lib:$PYTHONPATH"

# Create a simple file list fetcher
python3 -c "
import urllib.request
import urllib.parse
from bs4 import BeautifulSoup
import os

platform = '$PLATFORM'
folder = '$PLATFORM_FOLDER'  
url = 'https://github.com/username/file-repository/tree/main/$REPO_PATH/'

print(f'Fetching file list for {platform}...')
try:
    response = urllib.request.urlopen(url, timeout=10)
    html = response.read().decode('utf-8')
    soup = BeautifulSoup(html, 'html.parser')
    
    files = []
    for link in soup.find_all('a', href=True):
        href = link['href']
        if href.endswith('.zip'):
            files.append(href)
    
    print(f'Found {len(files)} files available for download')
    print('First 10 files:')
    for i, file in enumerate(files[:10]):
        print(f'{i+1:2d}. {file}')
    
    if len(files) > 10:
        print(f'... and {len(files)-10} more')
        
    print('')
    print('Use SSH to download specific files:')
    print('ssh root@192.168.0.159')
    print('cd /storage/files/ports/amos_fetcher') 
    print('python3 download.py')
    
except Exception as e:
    print(f'Error fetching file list: {e}')
    print('Check your internet connection and try again.')
"

echo ""
echo "Download preparation completed!"
