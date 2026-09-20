import sys
sys.path.append('..')

from chowdren.converter import Converter
import argparse

def main():
    parser = argparse.ArgumentParser(
        description='Chowdren - MMF to C++ converter')
    parser.add_argument('filenames', type=str,
        help='input files to convert (should be an EXE or CCN file)',
        nargs='+')
    parser.add_argument('outdir', type=str, help='destination directory')
    parser.add_argument('--assets', type=str, action='store',
        default='Assets.dat', help='destination file for assets')
    parser.add_argument('--skipassets', action='store_true',
        help='do not generate an assets file')
    parser.add_argument('--ico', type=str, action='store', default=None,
        help='icon to use for Windows')
    parser.add_argument('--icns', type=str, action='store', default=None,
        help='icon to use for OS X')
    parser.add_argument('--version', type=str, action='store',
        default=None, help='version to set in executable')
    parser.add_argument('--company', type=str, action='store',
        default=None, help='company to set in executable')
    parser.add_argument('--copyright', type=str, action='store',
        default=None, help='copyright to set in executable')
    parser.add_argument('--dlls', action='store_true',
                        help='use DLL architecture')
    parser.add_argument('--platform', type=str, action='store',
        default=None, help='platform for which to generate')
    parser.add_argument('--config', type=str, action='store', default=None,
                        help='game-specific configuration file')
    parser.add_argument('--copy_base', action='store_true',
                        help='copy base runtime')
    args = parser.parse_args()
    Converter(args)

if __name__ == '__main__':
    main()