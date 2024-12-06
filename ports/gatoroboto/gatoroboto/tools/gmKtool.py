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
    parser.add_argument('-v', '--verbose', action='count', default=0, help='Verbose level (cumulative option)')
    parser.add_argument('-m', '--minsize', default=MIN_SIZE, type=int, help='Minimum WAV/OGG size in bytes to target (default 1MB)')
    parser.add_argument('-a', '--audiogroup', nargs='?',action='append',type=int, help='Audiogroup ID to process (option can repeat). By default any.')
    parser.add_argument('-N', '--no-write', nargs="?",action='append', type=int, help='Don\'t write the updated file for this audiogroup number (option can repeat). By default none.')
    parser.add_argument('-O', '--only-write', nargs="?",action='append', type=int, help='Only write the updated file for this audiogroup number (option can repeat). By default write all.')
    parser.add_argument('-b', '--bitrate', default=0, type=int, help='nominal bitrate (in kbps) to encode at (oggenc -b option). 0 for auto (default)')
    parser.add_argument('-D', '--downmix', default=False, action='store_true', help='Downmix stereo to mono (oggenc --downmix option)')
    parser.add_argument('-R', '--resample', default=0, type=int, help='Resample input data to sampling rate n (Hz) (oggenc --resample option). Supported values: 8000, 11025, 22050, 32000, 44100, 48000')
    parser.add_argument('-B', '--buffered', default=False, action='store_true', help='Don\'t flush stdout after each line (incompatible with the patcher screen)')
    parser.add_argument('-r', '--recompress', default=False, action='store_true', help='Allow ogg recompression')
    parser.add_argument('-y', '--yes', default=False, action='store_true', help='Overwrite the files if already present without asking (DANGEROUS, use with caution)')
    parser.add_argument('-d', '--destdirpath', default="./Ktool.out",help='Destination directory path (default ./Ktool.out)')

    parser.add_argument('infilepath', help='Input file path (eg: data.win)')

    args = parser.parse_args()

    if args.no_write != None and args.only_write != None:
        print("-N and -O are incompatible together, use only one")
        exit(1)

    if not args.resample in [ 0, 8000, 11025, 22050, 32000, 44100, 48000 ]:
        print("-R supported values are 8000, 11025, 22050, 32000, 44100, 48000")
        exit(1)

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

    audiosettings = {}
    audiosettings["bitrate"] = args.bitrate
    audiosettings["downmix"] = args.downmix
    audiosettings["resample"] = args.resample

    myiffdata = GMdata(INFILE_PATH, args.verbose, audiosettings, audiogroup_filter)

    if  args.no_write != None:
        myiffdata.no_write(args.no_write)
    elif args.only_write != None:
        myiffdata.only_write(args.only_write)

    myiffdata.set_buffered(args.buffered)

    myiffdata.audio_enable_compress(args.minsize,args.recompress)
    myiffdata.write_changes(OUT_DIR)

    exit(0)

if __name__ == '__main__':
    main()