from pathlib import Path
import os
from subprocess import Popen, PIPE, DEVNULL
from struct import pack, unpack
from time import sleep
import sys
from multiprocessing import Pool
import tempfile
import multiprocessing

MIN_SIZE = 1024*1024 # 1 MB

# Helper function for parallel compression
def compress_audio(args):
    """Compress a single audio entry to OGG using oggenc/oggdec."""
    audiogroup_id, audo_entry, input_path, compress, oggenc_options, output_path, verbose = args
    try:
        with open(input_path, 'rb') as temp_in:
            input_data = temp_in.read()
        with open(output_path, 'wb') as temp_out:
            oggenc_process = Popen(
                ["oggenc", "-Q", *oggenc_options, "-o", "-", "-"],
                stdin=PIPE,
                stdout=temp_out,
                stderr=DEVNULL
            )
            if compress > 1:  # Recompress OGG
                oggdec_process = Popen(
                    ["oggdec", "-Q", "-o", "-", "-"],
                    stdin=PIPE,
                    stdout=PIPE,
                    stderr=DEVNULL
                )
                wavdata, _ = oggdec_process.communicate(input_data)
                oggenc_process.communicate(wavdata)
                oggdec_process.terminate()
            else:  # Compress WAV
                oggenc_process.communicate(input_data)
            oggenc_process.terminate()
        if verbose > 1:
            print(f"[AGRP {audiogroup_id}] Compressed AUDO entry {audo_entry} to {output_path}")
            sys.stdout.flush()
        with open(output_path, 'rb') as temp_out:
            return audiogroup_id, audo_entry, temp_out.read()
    except Exception as e:
        if verbose > 0:
            print(f"[AGRP {audiogroup_id}] Error compressing AUDO entry {audo_entry}: {str(e)}")
            sys.stdout.flush()
        return audiogroup_id, audo_entry, None
    finally:
        try:
            os.remove(input_path)
            os.remove(output_path)
        except OSError:
            pass

class IFFdata:

    def __init__(self, fin_path, verbose=0):
        self.filein_path = Path(fin_path)
        self.filein = None
        self.filein_size = 0 # includes FORM (4B) and size (4B)

        self.fileout_path = None
        self.fileout = None
        self.fileout_size = 0 # includes FORM (4B) and size (4B)

        self.verbose = verbose
        self.buffered = False
        self.chunk_list = None

        self.__init_chunk_list()

    def _vprint(self, msg):
        if self.verbose > 0:
            print(msg)
            if not self.buffered:
                sys.stdout.flush()

    def _vvprint(self, msg):
        if self.verbose > 1:
            print(msg)
            if not self.buffered:
                sys.stdout.flush()

    def _vvvprint(self, msg):
        if self.verbose > 2:
            print(msg)
            if not self.buffered:
                sys.stdout.flush()

    def _pretty_size(self,size):

        units = ['B ','KB','MB','GB']

        n = size

        while n > 1024:
            n = n / 1024
            units = units[1:]

        return f"{int(n):#4} {units[0]}"

    def _open_filein(self):

        try:
            self.filein = open(self.filein_path,'rb')
            self.filein.seek(0, os.SEEK_END)
            self.filein_size = self.filein.tell()
            self.filein.seek(0)

        except (FileNotFoundError, PermissionError, OSError, IOError):
            self._vprint(f"Error opening file {self.filein_path}")
            exit(1)
    
    def _open_fileout(self):

        try:
            self.fileout = open(self.fileout_path,'wb')
            self.filout_size = 0

        except (FileNotFoundError, PermissionError, OSError, IOError):
            self._vprint("Error opening file")
            exit(1)
    
    def __find_next_chunk(self):
        # Save chunk begin offset
        offset = self.filein.tell()

        # Read chunk token
        token = self.filein.read(4).decode('ascii')

        # Read chunk size (this doesn't include token (4B) and size (4B))
        size = unpack('<I', self.filein.read(4))[0]

        # Add chunk to chunk list
        self.chunk_list[token]={ "offset" : offset, "size": size, "rebuild": 0 }

        self._vvprint(f"Found {token} at offset {offset:#010x} with size {size:#010x}")

        # Except for FORM we want to go at the end of the chunk
        if token != 'FORM':
            self.filein.seek(size,1)

    def __init_chunk_list(self):
        # Open file if needed
        if self.filein == None:
            self._open_filein()

        # Generate chunk list if needed
        if self.chunk_list == None:
            # Seek for begin of the file
            self.filein.seek(0)
            self.chunk_list = {}

            # While we haven't reached this end of the file
            while ( self.filein.tell() < self.filein_size):
                # Find next chunk
                self.__find_next_chunk()

    def _get_padding(self, alignement = 16):
        misalignement =  self.fileout_size % alignement
        padding = 0

        if misalignement > 0:
            padding =  alignement - misalignement
        
        return padding

    def _write_to_file_otherchunk(self,token):
        self.filein.seek(self.chunk_list[token]["offset"])
        size = self.chunk_list[token]["size"]
        self._vvprint(f"Writing {token}")

        if self.chunk_list[token]["rebuild"] == 0:
            self._vvprint("Direct copy")

            self.fileout.write(self.filein.read(size + 8)) # We copy also  token (4B) and size(4B)
            self.fileout_size += size + 8

        else:
            self._vvprint("Rebuild needed")
            self.fileout.write(token.encode('ascii'))
            self.fileout.write(pack('<I', 0xffffffff))  # we don't know yet the final size
            self.filein.seek(8,1) # we already have written token (4B) and size(4B)
            self.fileout_size += 8

            if token != "FORM":
                self._vprint(f"Not implemented but there is something to do to rebuild {token}")

    def get_chunk_list(self):
        return self.chunk_list
    
    def set_buffered(self, buffered):
        self.buffered = buffered

class GMIFFDdata(IFFdata):

    def __init__(self, fin_path, verbose, audiosettings={"bitrate": 0, "downmix": False, "resample": 0}, audiogroup_id=0, cores=0):
        super().__init__(fin_path, verbose)
        
        self.audo = None
        self.audiogroup_dat = {}
        self.audiogroup_id = audiogroup_id
        self.audiosettings = audiosettings
        self.updated_entries = 0
        self.no_write = False

        self.cores = cores if cores > 0 else multiprocessing.cpu_count()
        
        self.__init_audo()
    
    def __init_audo(self):
        self.filein.seek(self.chunk_list["AUDO"]["offset"] + 8)
        nb_entries = unpack('<I', self.filein.read(4))[0]
        self._vvprint(f"AUDO with {nb_entries} entries")

        offset_table = []
        for i in range(nb_entries):
            offset_table.append(unpack('<I',self.filein.read(4))[0])
        
        self.audo = {}

        for i,offset in enumerate(offset_table):
            self.filein.seek(offset)
            size = unpack('<I', self.filein.read(4))[0]
            audokey = f"{i:#04}"
            self.audo[audokey] = { "offset": offset, "size": size, "compress": 0, "source": "infile"}

            self._vvvprint(f"AUDO entry {i:#04}: {self.audo[audokey]}")

    def _audo_get_size(self, audiogroup_id, audiofile):
        if audiogroup_id == self.audiogroup_id:
            return self.audo[audiofile]["size"]
        else:
            return self.audiogroup_dat[f"{audiogroup_id}"]._audo_get_size(audiogroup_id, audiofile)

    def _audo_set_compress(self, audiogroup_id, audiofile):

        if audiogroup_id == self.audiogroup_id:
            self.audo[audiofile]["compress"] = 1
            self.updated_entries += 1
            self.chunk_list["FORM"]["rebuild"] = 1
            self.chunk_list["AUDO"]["rebuild"] = 1
        else:
            return self.audiogroup_dat[f"{audiogroup_id}"]._audo_set_compress(audiogroup_id, audiofile)
        
    def _audo_set_recompress(self, audiogroup_id, audiofile):

        if audiogroup_id == self.audiogroup_id:
            self.audo[audiofile]["compress"] = 2
            self.updated_entries += 1
            self.chunk_list["FORM"]["rebuild"] = 1
            self.chunk_list["AUDO"]["rebuild"] = 1
        else:
            return self.audiogroup_dat[f"{audiogroup_id}"]._audo_set_recompress(audiogroup_id, audiofile)
        
    def get_updated_entries(self):
        return self.updated_entries
    
    def get_total_updated_entries(self):
        total = self.updated_entries
        for _,key in enumerate(self.audiogroup_dat.keys()):
            total += self.audiogroup_dat[key].get_total_updated_entries()
        
        return total

    def _write_to_file_audo(self, compressed_data=None):
        self.filein.seek(self.chunk_list["AUDO"]["offset"])
        size = self.chunk_list["AUDO"]["size"]
        self._vvprint(f"[AGRP {self.audiogroup_id}] Writing AUDO")

        audo_offset = self.fileout.tell()

        if self.chunk_list["AUDO"]["rebuild"] == 0:
            self._vvprint(f"[AGRP {self.audiogroup_id}] Direct copy AUDO")

            self.fileout.write(self.filein.read(size + 8))
            self.fileout_size += size + 8

        else:
            self._vvprint(f"[AGRP {self.audiogroup_id}] Rebuild AUDO")
            self.fileout.write(self.filein.read(4))  # Token
            self.fileout_size += 4
            self.fileout.write(pack('<I', 0xffffffff))  # Unknown size yet
            self.fileout_size += 4

            self.fileout.write(pack('<I', len(self.audo.keys())))  # Number of entries
            self.fileout_size += 4

            table_offset = self.fileout.tell()

            self.fileout.write(pack('<I', 0xffffffff) * len(self.audo.keys()))  # Placeholder offsets
            self.fileout_size += 4 * len(self.audo.keys())
                                         
            padding = self._get_padding(16)
            
            self.fileout.write(b'\x00' * padding)
            self.fileout_size += padding

            for n, key in enumerate(self.audo.keys()):
                current_offset = self.fileout.tell()
                self.fileout.seek(table_offset + 4 * n)
                self.fileout.write(pack('<I', current_offset))
                self.fileout.seek(current_offset)


                if self.audo[key]["compress"] == 0 and self.audo[key]["source"] == "infile":
                    self._vvvprint(f"[AGRP {self.audiogroup_id}] Direct copy AUDO entry {key}")
                    self.filein.seek(self.audo[key]["offset"])


                    # We copy the entry from the input file
                    self.fileout.write(self.filein.read(4 + self.audo[key]["size"]))  # same entry (4B size + audio size)
                    self.fileout_size += 4 + self.audo[key]["size"]
                elif self.audo[key]["compress"] > 0 and self.audo[key]["source"] == "infile":
                    self._vvprint(f"[AGRP {self.audiogroup_id}] Writing compressed AUDO entry {key}")
                    compressed = compressed_data.get((self.audiogroup_id, key))
                    if compressed is None:
                        self._vprint(f"[AGRP {self.audiogroup_id}] Skipping AUDO entry {key} due to compression error")
                        self.fileout.write(pack('<I', 0))  # Write zero size
                        self.fileout_size += 4
                    else:
                        entrysize = len(compressed)
                        self.fileout.write(pack('<I', entrysize))
                        self.fileout.write(compressed)
                        self.fileout_size += 4 + entrysize
                elif self.audo[key]["compress"] > 0 and self.audo[key]["source"] == "txtp":
                    self._vvprint(f"[AGRP {self.audiogroup_id}] Compress TXTP external sound {key}")
                    self.fileout.write(pack('<I', 0xffffffff))  # Unknown size
                    self.fileout_size += 4

                    entrysize = self._write_to_file_txtp_ogg(key)
                    self.fileout_size += entrysize
                    self.fileout.seek(-entrysize - 4, 1)
                    self.fileout.write(pack('<I', entrysize))
                    self.fileout.seek(entrysize, 1)

                padding = self._get_padding(16)
                self.fileout.write(b'\x00' * padding)
                self.fileout_size += padding

            audo_size = self.fileout_size - audo_offset - 8
            self.fileout.seek(audo_offset + 4)          # jump to audo size entry
            self.fileout.write(pack('<I', audo_size))   # write audo size
            self.fileout.seek(audo_size, 1)             # jump at the end of audo chunk

    def _get_oggenc_options(self):
        options = []
        if self.audiosettings["bitrate"] != 0:
            options.append("-b")
            options.append(f"{self.audiosettings['bitrate']}")

        if self.audiosettings["downmix"]:
            options.append("--downmix")
        
        if self.audiosettings["resample"] != 0:
            options.append("--resample")
            options.append(f"{self.audiosettings['resample']}")
        
        return options

    def _write_to_file_txtp_ogg(self, audo_entry):

        offset_start = self.fileout.tell()
        self.fileout.seek(offset_start)                 # Can't find out why, but if I don't do this
                                                        # it writes with -4 bytes offset...

        oggenc_process = Popen(["oggenc","-Q", *self._get_oggenc_options(), "-o", "-", "-"],stdin=PIPE, stdout=self.fileout, stderr=DEVNULL )
        
        vgmstream_process = Popen(["vgmstream-cli",f"{self.audo[audo_entry]['txtp']}", "-p"], stdout=oggenc_process.stdin, stderr=DEVNULL )

        oggenc_process.communicate()

        oggenc_process.terminate()
        vgmstream_process.terminate()

        return self.fileout.tell() - offset_start

    def _write_to_file_audo_ogg(self, audo_entry, compress):
        # Deprecated: Replaced by parallel compress_audio
        raise NotImplementedError("Use parallel compression in _write_to_file_audo")

        if compress > 1:
            # audio is already compressed, we need to uncompress it before can compress it
            oggdec_process = Popen(["oggdec", "-Q", "-o", "-", "-"], stdin=PIPE, stdout=PIPE, stderr=DEVNULL)
            wavdata, _ = oggdec_process.communicate(self.filein.read(self.audo[audo_entry]["size"]))
            oggenc_process.communicate(wavdata)
            oggdec_process.terminate()

        else:
            oggenc_process.communicate(self.filein.read(self.audo[audo_entry]["size"]))

        oggenc_process.terminate()

        return self.fileout.tell() - offset_start
        
    def get_audo(self):
        return self.audo
    
    def no_write(self, no_write):
        if self.audiogroup_id in no_write:
            self.no_write = True
            self._vprint(f"[AGRP {self.audiogroup_id}] NO_WRITE")
        else:
            self._vprint("[AGRP {self.audiogroup_id}] ONLY_WRITE")


        # also no_write audiogroupN.dat files
        for _,key in enumerate(self.audiogroup_dat.keys()):
            self.audiogroup_dat[key].no_write(no_write)

    def only_write(self, only_write):
        if not self.audiogroup_id in only_write:
            self.no_write = True
            self._vprint(f"[AGRP {self.audiogroup_id}] NO_WRITE")
        else:
            self._vprint(f"[AGRP {self.audiogroup_id}] ONLY_WRITE")

        # also only_write audiogroupN.dat files
        for _,key in enumerate(self.audiogroup_dat.keys()):
            self.audiogroup_dat[key].only_write(only_write)

    def audo_get_entry(self,n,filein_path):
        with open(filein_path, 'wb') as fout:
            self.filein.seek(self.audo[n]["offset"] + 4)
            fout.write(self.filein.read(self.audo[n]["size"]))

class GMaudiogroup(GMIFFDdata):

    def __init__(self, fin_path, verbose, audiosettings, audiogroup_id, cores=0):
        super().__init__(fin_path, verbose, audiosettings, audiogroup_id, cores)
    
    def import_sound_txtp(self, filetxtp_path, compress=0 ):
        last = len(self.audo)
        self.audo[f"{last:#04}"] = { "offset": -1, "size": -1, "compress": compress, "source": "txtp", "txtp": filetxtp_path }
        self.chunk_list["FORM"]["rebuild"] = 1
        self.chunk_list["AUDO"]["rebuild"] = 1

    def write_changes(self, OUT_DIR, compressed_data=None):
        if self.no_write:
            self._vprint(f"No write set for AGRP {self.audiogroup_id}: Will not write {self.filein_path.name}")
        else:
            self._vprint(f"Writing {self.filein_path.name}")
            self.fileout_path = OUT_DIR / self.filein_path.name
            self._open_fileout()

            if self.chunk_list["FORM"]["rebuild"] == 1:

                for _, token in enumerate(self.chunk_list):
                    if token == "AUDO":
                        self._write_to_file_audo(compressed_data)
                    else:
                        self._write_to_file_otherchunk(token)

                self.fileout.seek(4)
                self.fileout.write(pack('<I', self.fileout_size - 8))  # Update size
            else:
                self._write_to_file_otherchunk("FORM")

class GMdata(GMIFFDdata):

    GM_DEFAULT = 0x0000
    GM_2024_6 = 0x1806

    def __init__(self, fin_path, verbose, audiosettings, audiogroup_filter=[], cores=0):
        super().__init__(fin_path, verbose, audiosettings, 0, cores)
        self.gm_version = GMdata.GM_DEFAULT

        self.sond = None
        self.audiogroup_filter = audiogroup_filter

        self.__init_sond()
    
    def get_str(self, str_offset):

        if str_offset == 0:
            return ''
        self.filein.seek(str_offset - 4)
        size = unpack('<I', self.filein.read(4))[0]

        return self.filein.read(size).decode('utf-8')

    def __init_sond(self):
        self.filein.seek(self.chunk_list["SOND"]["offset"] + 8)
        nb_entries = unpack('<I', self.filein.read(4))[0]
        self._vvprint(f"SOND with {nb_entries} entries")

        offset_table = []
        for i in range(nb_entries):
            offset_table.append(unpack('<I',self.filein.read(4))[0])
        
        if offset_table[1] - offset_table[0] == 40 and len(offset_table) > 1:
                self.set_gm_version(GMdata.GM_2024_6)

        elif len(offset_table) == 1:
            self.filein.seek(offset_table[0] + 32)
            if unpack('<I', self.filein.read(4))[0] > 0:
                self.set_gm_version(GMdata.GM_2024_6)

        self.sond = {}
        
        for i,offset in enumerate(offset_table):
            self.filein.seek(offset)

            name_offset = unpack('<I',self.filein.read(4))[0]
            flags_raw = unpack('<I',self.filein.read(4))[0]
            type_offset = unpack('<I',self.filein.read(4))[0]
            file_offset = unpack('<I',self.filein.read(4))[0]
            [ effect, volume, pitch, audiogroup, audiofile ] = \
                unpack('<IffII', self.filein.read(20))
            
            if self.gm_version == GMdata.GM_2024_6:
                audiolength = unpack('<f',self.filein.read(4))[0]
            else:
                audiolength = 0
            
            name = self.get_str(name_offset)
            type = self.get_str(type_offset)
            file = self.get_str(file_offset)
            flags = { "isRegular" : (flags_raw & 0x64) >> 6,
                      "isCompressed" : (flags_raw & 0x02) >> 1,
                       "isEmbedeed" : flags_raw & 0x01 }

            sondkey = f"{i:#04}"
            self.sond[sondkey] = {
                                    "name_offset": name_offset,
                                    "name" : name,
                                    "flags_raw" : flags_raw,
                                    "flags" : flags,
                                    "type_offset": type_offset,
                                    "type" : type,
                                    "file_offset": file_offset,
                                    "file" : file,
                                    "effect" : effect,
                                    "volume" : volume,
                                    "pitch" : pitch,
                                    "audiogroup" : audiogroup,
                                    "audiofile" : audiofile,
                                    "audiolength": audiolength,
                                    "rebuild" : 0
                                }
            self._vvvprint(f"SOND entry {i:#04}: {self.sond[sondkey]}")

            self.__init_audiogroup_dat(audiogroup)
    
    def __init_audiogroup_dat(self, audiogroup):
        if audiogroup > 0 and not f"{audiogroup}" in self.audiogroup_dat.keys():
            self.audiogroup_dat[f"{audiogroup}"] = GMaudiogroup(
                self.filein_path.parents[0] / f"audiogroup{audiogroup}.dat",
                self.verbose,
                self.audiosettings,
                audiogroup,
                self.cores
            )
 
    def __sond_get_raw_entry(self,key):

        if self.gm_version == GMdata.GM_2024_6:
            return pack('<IIIIIffIIf',   self.sond[key]["name_offset"], \
                                self.sond[key]["flags_raw"], \
                                self.sond[key]["type_offset"], \
                                self.sond[key]["file_offset"], \
                                self.sond[key]["effect"], \
                                self.sond[key]["volume"], \
                                self.sond[key]["pitch"], \
                                self.sond[key]["audiogroup"], \
                                self.sond[key]["audiofile"], \
                                self.sond[key]["audiolength"]
                        )
        else:
            return pack('<IIIIIffII',   self.sond[key]["name_offset"], \
                                        self.sond[key]["flags_raw"], \
                                        self.sond[key]["type_offset"], \
                                        self.sond[key]["file_offset"], \
                                        self.sond[key]["effect"], \
                                        self.sond[key]["volume"], \
                                        self.sond[key]["pitch"], \
                                        self.sond[key]["audiogroup"], \
                                        self.sond[key]["audiofile"]
                        )
    
    def __sond_update_flags_raw(self, key):
        self.sond[key]["flags_raw"] =   self.sond[key]["flags"]["isRegular"] * 0x64 | \
                                        self.sond[key]["flags"]["isCompressed"] * 0x02 | \
                                        self.sond[key]["flags"]["isEmbedded"] * 0x01
    
    def __sond_set_compress(self, sond_key):

        self.chunk_list["FORM"]["rebuild"] = 1
        self.chunk_list["SOND"]["rebuild"] = 1

        # update flags (uncompressed -> compressed)
        self.sond[sond_key]["flags"]["isCompressed"] = 1
        self.sond[sond_key]["flags"]["isEmbedded"] = 0
        self.__sond_update_flags_raw(sond_key)

        # toggle rebuild and compress because we will update data
        self.sond[sond_key]["rebuild"] = 1

    def __write_to_file_sond(self):
        self.filein.seek(self.chunk_list["SOND"]["offset"])
        size = self.chunk_list["SOND"]["size"]
        self._vvprint("Writing SOND")

        if self.chunk_list["SOND"]["rebuild"] == 0:
            self._vvprint("Direct copy SOND")
            self.fileout.write(self.filein.read(size + 8))
            self.fileout_size += size + 8

        else:
            self._vvprint("Rebuild SOND")
            self.fileout.write(self.filein.read(12)) # Token, size, nb entries should be the same
            self.fileout_size += 12
            self.fileout.write(self.filein.read(len(self.sond.keys()) * 4)) # offsets don't change
            self.fileout_size += len(self.sond.keys()) * 4
            
            if self.gm_version == GMdata.GM_2024_6:
                sond_entry_size = 40
            else:
                sond_entry_size = 36

            for n, key in enumerate(self.sond.keys()):
                if self.sond[key]["rebuild"] == 0:
                    self._vvvprint(f"Direct copy SOND entry {key}")
                    # We copy the entry from the input file
                    self.fileout.write(self.filein.read(sond_entry_size)) # same entry (36 / 40B)
                else:
                    self._vvvprint(f"Rebuild SOND entry {key}")
                    self.filein.seek(sond_entry_size,1) # we jump this chunk on the input file (36 / 40B)

                    self.fileout.write(self.__sond_get_raw_entry(key))

                self.fileout_size += sond_entry_size

            padding = self._get_padding(16)
            
            self.fileout.write(b'\x00' * padding )
            self.fileout_size += padding

    def get_sond(self):
        return self.sond

    def set_gm_version(self, version):
        self.gm_version = version
        if self.gm_version == GMdata.GM_2024_6:
            self._vprint("GM 2024.6 detected")
    
    def audio_enable_compress(self, minsize, recompress=False):
        tasks = []
        temp_files = []

        # Prepare tasks for all audiogroups
        for _, sond_key in enumerate(self.sond):
            audiogroup_id = self.sond[sond_key]["audiogroup"]           # it is an audiogroup ID (eg 0 or 1)
            audiofile_id = self.sond[sond_key]["audiofile"]

            if audiofile_id == 0xffffffff:
                # AUDO entry doesn't exist
                continue

            audiofile = f"{audiofile_id:#04}"    # it is a file number (eg 0001)

            if (audiogroup_id in self.audiogroup_filter or len(self.audiogroup_filter) == 0):
                size = self._audo_get_size(audiogroup_id, audiofile)
                if size >= minsize:
                    if self.sond[sond_key]["flags"]["isCompressed"] == 0:
                        self.__sond_set_compress(sond_key)
                        self._audo_set_compress(audiogroup_id, audiofile)
                        input_path = tempfile.mktemp()
                        output_path = tempfile.mktemp()
                        with open(input_path, 'wb') as temp_in:
                            if audiogroup_id == 0:
                                self.filein.seek(4 + self.audo[audiofile]["offset"])
                                temp_in.write(self.filein.read(self.audo[audiofile]["size"]))
                            else:
                                ag = self.audiogroup_dat[f"{audiogroup_id}"]
                                ag.filein.seek(4 + ag.audo[audiofile]["offset"])
                                temp_in.write(ag.filein.read(ag.audo[audiofile]["size"]))
                        tasks.append((
                            audiogroup_id,
                            audiofile,
                            input_path,
                            1,  # Compress WAV
                            self._get_oggenc_options(),
                            output_path,
                            self.verbose
                        ))
                        temp_files.extend([input_path, output_path])
                        self._vvprint(f"audo {audiofile} in audiogroup {audiogroup_id} ({self.sond[sond_key]['name']}) with size {self._pretty_size(size)} will be compressed")
                    elif recompress and size >= minsize:
                        self._audo_set_recompress(audiogroup_id, audiofile)
                        input_path = tempfile.mktemp()
                        output_path = tempfile.mktemp()
                        with open(input_path, 'wb') as temp_in:
                            if audiogroup_id == 0:
                                self.filein.seek(4 + self.audo[audiofile]["offset"])
                                temp_in.write(self.filein.read(self.audo[audiofile]["size"]))
                            else:
                                ag = self.audiogroup_dat[f"{audiogroup_id}"]
                                ag.filein.seek(4 + ag.audo[audiofile]["offset"])
                                temp_in.write(ag.filein.read(ag.audo[audiofile]["size"]))
                        tasks.append((
                            audiogroup_id,
                            audiofile,
                            input_path,
                            2,  # Recompress OGG
                            self._get_oggenc_options(),
                            output_path,
                            self.verbose
                        ))
                        temp_files.extend([input_path, output_path])
                        self._vvprint(f"audo {audiofile} in audiogroup {audiogroup_id} ({self.sond[sond_key]['name']}) with size {self._pretty_size(size)} will be recompressed")

        # Execute compression tasks in parallel
        compressed_data = {}
        if tasks:
            self._vprint(f"Compressing {len(tasks)} audio entries across all audiogroups using {self.cores} cores")
            with Pool(processes=self.cores) as pool:
                results = pool.map(compress_audio, tasks)
            for audiogroup_id, audiofile, data in results:
                if data is not None:
                    compressed_data[(audiogroup_id, audiofile)] = data

        if self.get_total_updated_entries() > 0:
            # toggle rebuild because we will update data
            self._vprint(f"{self.get_total_updated_entries()} audo entrie(s) will be compressed")

        self.compressed_data = compressed_data

    def write_changes(self, OUT_DIR):
        if self.no_write:
            self._vprint(f"No write set for AGRP {self.audiogroup_id}: Will not write {self.filein_path.name}")
        else:
            self._vprint(f"Writing {self.filein_path.name}")

            self.fileout_path = OUT_DIR / self.filein_path.name
            self._open_fileout()

            if self.chunk_list["FORM"]["rebuild"] == 1:
                for _, token in enumerate(self.chunk_list):
                    if token == "SOND":
                        self.__write_to_file_sond()
                    elif token == "AUDO":
                        self._write_to_file_audo(self.compressed_data)
                    else:
                        self._write_to_file_otherchunk(token)
                self.fileout.seek(4)
                self.fileout.write(pack('<I', self.fileout_size - 8))  # Update size
            else:
                self._write_to_file_otherchunk("FORM")
        
        # also write audiogroupN.dat files
        for _, key in enumerate(self.audiogroup_dat.keys()):
            self.audiogroup_dat[key].write_changes(OUT_DIR, self.compressed_data)