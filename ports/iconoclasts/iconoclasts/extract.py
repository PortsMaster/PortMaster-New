#!/bin/python3
import sys
from zipfile import ZipFile

if len(sys.argv) < 2:
  sys.exit('Usage: extract.py filename.sh [ensure]')

with ZipFile(sys.argv[1], 'r') as z:
  # Perform ensure check
  if len(sys.argv) > 2:
    try:
      p = z.getinfo(sys.argv[2])
    except:
      sys.exit(f"Failure to install, {sys.argv[2]} not present in file.")

  prefix = 'data/noarch/game/'
  files = [info for info in z.infolist() if info.filename.startswith(prefix)]
  nfiles = len(files)
  for i, info in enumerate(files):
    if info.filename == prefix:
      continue
    sys.stdout.write(f'\rInstalling... {i+1}/{nfiles}')
    sys.stdout.flush()
    # print(info.filename)

    # remove path prefix
    info.filename = info.filename[len(prefix):]
    z.extract(info)

print(' Done!')
