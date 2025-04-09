#!/usr/bin/env python3

"""
    name: K-dog tool
    description: compress wav data into ogg data in Gamemaker data.win files
    author: kotzebuedog
    usage: ./gm-Ktool.py data.win -d ./repacked -a 0 -a 1 -m 524288
            Will compress all wav data > 512 KB in audiogroup 0 (data.win) and 1 (audiogroup1.dat)
            The updated files will be written in ./repacked
            -d, -a and -m are optionnal
"""
import argparse
from pathlib import Path
from Klib.GMblob import GMdata

MIN_SIZE = 1024*1024 # 1 MB

def main():


    parser = argparse.ArgumentParser(description='GameMaker K-dog tool: compress wav to ogg, recompress ogg, in Gamemaker data files')
    parser.add_argument('-v','--verbose', action='count', default=0, help='Verbose level (cumulative option)')
    parser.add_argument('-m','--minsize', default=MIN_SIZE, type=int, help='Minimum WAV/OGG size in bytes to target (default 1MB)')
    parser.add_argument('-a','--audiogroup', nargs='?',action='append',type=int, help='Audiogroup ID to process (option can repeat). By default any.')
    parser.add_argument('-b','--bitrate', default=0, help='nominal bitrate (in kbps) to encode at (oggenc -b option). 0 for auto (default)')
    parser.add_argument('-r', '--recompress', default=False, action='store_true', help='Allow ogg recompression')
    parser.add_argument('-y', '--yes', default=False, action='store_true', help='Overwrite the files if already present without asking (DANGEROUS, use with caution)')
    parser.add_argument('-d','--destdirpath', default="./Ktool.out",help='Destination directory path (default ./Ktool.out)')

    parser.add_argument('infilepath', help='Input file path (eg: data.win)')

    args = parser.parse_args()

    if args.audiogroup:
        audiogroup_filter = args.audiogroup
    else:
        audiogroup_filter = []

    INFILE_PATH=Path(args.infilepath)
    OUT_DIR=Path(args.destdirpath)

    if not INFILE_PATH.exists():
        print(f"{INFILE_PATH} not found")
        exit(1)

    if OUT_DIR.exists():
        if OUT_DIR.is_dir():
            if any(OUT_DIR.iterdir()) and not args.yes:
                answer=input(f"{OUT_DIR} already exists and contains file. Do you want to continue? (y/n)")
                if not answer in 'yY':
                    exit(0)
        else:
            print(f"{OUT_DIR} is not a directory")
            exit(1)
    else:
        OUT_DIR.mkdir()

    myiffdata = GMdata(INFILE_PATH, args.verbose, args.bitrate, audiogroup_filter)
    myiffdata.audio_enable_compress(args.minsize,args.recompress)
    myiffdata.write_changes(OUT_DIR)

    exit(0)

if __name__ == '__main__':
    main()