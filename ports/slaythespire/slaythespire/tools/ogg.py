#!/usr/bin/env python3
from pathlib import Path
from subprocess import Popen, PIPE, DEVNULL
import argparse
import sys

MIN_SIZE = 1024 * 1024  # 1 MB default

class OGGDownsampler:
    
    def __init__(self, input_dir, output_dir=None, verbose=0, 
                 bitrate=0, downmix=False, resample=0, min_size=0, 
                 in_place=False, recompress=False):
        self.input_dir = Path(input_dir)
        self.output_dir = Path(output_dir) if output_dir else None
        self.verbose = verbose
        self.bitrate = bitrate
        self.downmix = downmix
        self.resample = resample
        self.min_size = min_size
        self.in_place = in_place
        self.recompress = recompress
        
        self.processed = 0
        self.skipped = 0
        self.failed = 0
        
        # Find oggenc and oggdec executables
        self.oggenc = self._find_executable('oggenc')
        self.oggdec = self._find_executable('oggdec')
        
        if not self.oggenc or not self.oggdec:
            print("Error: oggenc and oggdec not found!")
            print("Please install vorbis-tools or place oggenc/oggdec in the script directory")
            sys.exit(1)
    
    def _find_executable(self, name):
        """Find executable in local directory first, then in PATH"""
        # Check local directory (same as script)
        script_dir = Path(__file__).parent
        local_exec = script_dir / name
        
        # Windows executable
        if sys.platform == 'win32':
            local_exec = script_dir / f"{name}.exe"
        
        if local_exec.exists():
            self._vvprint(f"Using local {name}: {local_exec}")
            return str(local_exec)
        
        # Check if in PATH
        import shutil
        path_exec = shutil.which(name)
        if path_exec:
            self._vvprint(f"Using system {name}: {path_exec}")
            return name
        
        return None
        
    def _vprint(self, msg):
        if self.verbose > 0:
            print(msg)
            sys.stdout.flush()
    
    def _vvprint(self, msg):
        if self.verbose > 1:
            print(msg)
            sys.stdout.flush()
    
    def _pretty_size(self, size):
        units = ['B ', 'KB', 'MB', 'GB']
        n = size
        while n > 1024 and len(units) > 1:
            n = n / 1024
            units = units[1:]
        return f"{int(n):>4} {units[0]}"
    
    def _get_oggenc_options(self):
        options = []
        if self.bitrate != 0:
            options.extend(["-b", str(self.bitrate)])
        if self.downmix:
            options.append("--downmix")
        if self.resample != 0:
            options.extend(["--resample", str(self.resample)])
        return options
    
    def _process_ogg(self, input_file, output_file):
        """Process a single OGG file using oggdec and oggenc"""
        
        self._vvprint(f"Processing: {input_file.name}")
        
        try:
            # Decode OGG to WAV (pipe to oggenc)
            oggdec_process = Popen(
                [self.oggdec, "-Q", "-o", "-", str(input_file)],
                stdout=PIPE,
                stderr=DEVNULL
            )
            
            # Encode WAV to OGG with new settings
            with open(output_file, 'wb') as fout:
                oggenc_process = Popen(
                    [self.oggenc, "-Q", *self._get_oggenc_options(), "-o", "-", "-"],
                    stdin=oggdec_process.stdout,
                    stdout=fout,
                    stderr=DEVNULL
                )
                
                oggdec_process.stdout.close()
                oggenc_process.communicate()
            
            oggdec_process.wait()
            oggenc_process.wait()
            
            if oggenc_process.returncode == 0:
                old_size = input_file.stat().st_size
                new_size = output_file.stat().st_size
                self._vprint(f"✓ {input_file.name}: {self._pretty_size(old_size)} → {self._pretty_size(new_size)}")
                return True
            else:
                self._vprint(f"✗ Failed to encode: {input_file.name}")
                return False
                
        except Exception as e:
            self._vprint(f"✗ Error processing {input_file.name}: {e}")
            return False
    
    def _recompress_ogg(self, input_file, output_file):
        """Recompress an already compressed OGG file"""
        
        self._vvprint(f"Recompressing: {input_file.name}")
        
        try:
            # Decode OGG to WAV
            oggdec_process = Popen(
                [self.oggdec, "-Q", "-o", "-", str(input_file)],
                stdout=PIPE,
                stderr=DEVNULL
            )
            
            wavdata, _ = oggdec_process.communicate()
            
            # Encode WAV back to OGG with new settings
            with open(output_file, 'wb') as fout:
                oggenc_process = Popen(
                    [self.oggenc, "-Q", *self._get_oggenc_options(), "-o", "-", "-"],
                    stdin=PIPE,
                    stdout=fout,
                    stderr=DEVNULL
                )
                
                oggenc_process.communicate(wavdata)
            
            if oggenc_process.returncode == 0:
                old_size = input_file.stat().st_size
                new_size = output_file.stat().st_size
                self._vprint(f"✓ {input_file.name}: {self._pretty_size(old_size)} → {self._pretty_size(new_size)}")
                return True
            else:
                self._vprint(f"✗ Failed to recompress: {input_file.name}")
                return False
                
        except Exception as e:
            self._vprint(f"✗ Error recompressing {input_file.name}: {e}")
            return False
    
    def process_directory(self):
        """Process all OGG files in directory and subdirectories"""
        
        if not self.input_dir.exists():
            print(f"Error: Input directory '{self.input_dir}' does not exist")
            return
        
        # Find all OGG files
        ogg_files = list(self.input_dir.rglob('*.ogg'))
        
        if not ogg_files:
            print(f"No .ogg files found in {self.input_dir}")
            return
        
        self._vprint(f"Found {len(ogg_files)} .ogg file(s)")
        
        if self.bitrate:
            self._vprint(f"Bitrate: {self.bitrate} kbps")
        if self.resample:
            self._vprint(f"Resample: {self.resample} Hz")
        if self.downmix:
            self._vprint("Downmix: enabled")
        if self.min_size:
            self._vprint(f"Min size: {self._pretty_size(self.min_size)}")
        
        self._vprint("-" * 60)
        
        for ogg_file in ogg_files:
            file_size = ogg_file.stat().st_size
            
            # Skip files smaller than minimum size
            if self.min_size > 0 and file_size < self.min_size:
                self._vvprint(f"Skipping {ogg_file.name} (too small: {self._pretty_size(file_size)})")
                self.skipped += 1
                continue
            
            # Determine output path
            if self.in_place:
                temp_output = ogg_file.with_suffix('.tmp.ogg')
                final_output = ogg_file
            else:
                if self.output_dir:
                    rel_path = ogg_file.relative_to(self.input_dir)
                    final_output = self.output_dir / rel_path
                    final_output.parent.mkdir(parents=True, exist_ok=True)
                else:
                    final_output = ogg_file.with_stem(f"{ogg_file.stem}_compressed")
                temp_output = final_output
            
            # Process the file
            if self.recompress:
                success = self._recompress_ogg(ogg_file, temp_output)
            else:
                success = self._process_ogg(ogg_file, temp_output)
            
            if success:
                # If in-place, replace original
                if self.in_place:
                    ogg_file.unlink()
                    temp_output.rename(ogg_file)
                self.processed += 1
            else:
                if temp_output.exists():
                    temp_output.unlink()
                self.failed += 1
        
        self._vprint("-" * 60)
        self._vprint(f"Processed: {self.processed}")
        self._vprint(f"Skipped: {self.skipped}")
        self._vprint(f"Failed: {self.failed}")

def main():
    parser = argparse.ArgumentParser(
        description='Downsample/compress OGG audio files recursively using oggdec and oggenc',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Basic compression with bitrate limit
  python %(prog)s /path/to/sounds -b 96
  
  # Resample to 22050 Hz and downmix to mono
  python %(prog)s /path/to/sounds --resample 22050 --downmix
  
  # Only process files larger than 1 MB
  python %(prog)s /path/to/sounds -b 96 --min-size 1048576
  
  # Process in-place (replaces original files)
  python %(prog)s /path/to/sounds -b 96 --in-place
  
  # Recompress already compressed OGG files
  python %(prog)s /path/to/sounds -b 64 --recompress
        """
    )
    
    parser.add_argument('input_dir', help='Directory containing .ogg files')
    parser.add_argument('-o', '--output', help='Output directory (maintains directory structure)')
    parser.add_argument('-b', '--bitrate', type=int, default=0,
                       help='Target bitrate in kbps (e.g., 96, 128)')
    parser.add_argument('--resample', type=int, default=0,
                       help='Resample to target sample rate in Hz (e.g., 22050, 44100)')
    parser.add_argument('--downmix', action='store_true',
                       help='Downmix to mono')
    parser.add_argument('--min-size', type=int, default=0,
                       help='Minimum file size in bytes to process (default: 0, process all)')
    parser.add_argument('--in-place', action='store_true',
                       help='Replace original files (use with caution!)')
    parser.add_argument('--recompress', action='store_true',
                       help='Recompress already compressed OGG files')
    parser.add_argument('-v', '--verbose', action='count', default=0,
                       help='Increase verbosity (-v, -vv, -vvv)')
    
    args = parser.parse_args()
    
    downsampler = OGGDownsampler(
        input_dir=args.input_dir,
        output_dir=args.output,
        verbose=args.verbose,
        bitrate=args.bitrate,
        downmix=args.downmix,
        resample=args.resample,
        min_size=args.min_size,
        in_place=args.in_place,
        recompress=args.recompress
    )
    
    downsampler.process_directory()

if __name__ == '__main__':
    main()
