#!/usr/bin/env python3

"""
    name: K-dog tool
    description: compress wav data into ogg data in Gamemaker data.win files
    author: kotzebuedog
    usage: ./gm-Ktool.py data.win data-k.win -a 0 -m 524288
            will compress all wav data > 512 KB in audiogroup 0
            -a and -m are optionnal
"""

from pathlib import Path
import os
from subprocess import Popen, PIPE
import threading

import argparse

from struct import pack,unpack

MIN_SIZE = 1024*1024 # 1 MB

class IFFdata:

    def __init__(self, fin_path, verbose=0, bitrate=128):
        self.filein_path = fin_path
        self.filein = None
        self.filein_size = 0 # includes FORM (4B) and size (4B)
        self.fileout_path = None
        self.fileout = None
        self.fileout_size = 0 # includes FORM (4B) and size (4B)
        self.chunk_list = None
        self.sond = None
        self.audo = None

        self.verbose = verbose
        self.bitrate = bitrate

        self.__init_chunk_list()
        self.__init_sond()
        self.__init_audo()

    def __vprint(self, msg):
        if self.verbose > 0:
            print(msg)

    def __vvprint(self, msg):
        if self.verbose > 1:
            print(msg)

    def __vvvprint(self, msg):
        if self.verbose > 2:
            print(msg)

    def __pretty_size(self,size):

        units = ['B ','KB','MB','GB']

        n = size

        while n > 1024:
            n = n / 1024
            units = units[1:]

        return f"{int(n):#4} {units[0]}"

    def __open_filein(self):

        try:
            self.filein = open(self.filein_path,'rb')
            self.filein.seek(0, os.SEEK_END)
            self.filein_size = self.filein.tell()
            self.filein.seek(0)

        except (FileNotFoundError, PermissionError, OSError, IOError):
            self.__vprint("Error opening file")
            exit(1)
    
    def __open_fileout(self):

        try:
            self.fileout = open(self.fileout_path,'wb')
            self.filout_size = 0

        except (FileNotFoundError, PermissionError, OSError, IOError):
            self.__vprint("Error opening file")
            exit(1)

    def __find_next_chunk(self):
        offset = self.filein.tell()
        token = self.filein.read(4).decode('ascii')
        size = unpack('<I', self.filein.read(4))[0]

        self.chunk_list[token]={ "offset" : offset, "size": size, "rebuild": 0 }
        self.__vvprint(f"Found {token} at offset {offset:#010x} with size {size:#010x}")
        if token != 'FORM':
            self.filein.seek(size,1)

    def __init_chunk_list(self):
        if self.filein == None:
            self.__open_filein()

        if self.chunk_list == None:
            self.filein.seek(0)
            self.chunk_list = {}
            while ( self.filein.tell() < self.filein_size):
                self.__find_next_chunk()
    
    def get_str(self, str_offset):
        if str_offset == 0:
            return ''
        self.filein.seek(str_offset - 4)
        size = unpack('<I', self.filein.read(4))[0]

        return self.filein.read(size).decode('utf-8')


    def get_chunk_list(self):
        return self.chunk_list
    
    def __init_sond(self):
        self.filein.seek(self.chunk_list["SOND"]["offset"] + 8)
        nb_entries = unpack('<I', self.filein.read(4))[0]
        self.__vvprint(f"SOND with {nb_entries} entries")

        offset_table = []
        for i in range(nb_entries):
            offset_table.append(unpack('<I',self.filein.read(4))[0])

        self.sond = {}
        
        for i,offset in enumerate(offset_table):
            self.filein.seek(offset)

            name_offset = unpack('<I',self.filein.read(4))[0]
            flags_raw = unpack('<I',self.filein.read(4))[0]
            type_offset = unpack('<I',self.filein.read(4))[0]
            file_offset = unpack('<I',self.filein.read(4))[0]
            [ effect, volume, pitch, audiogroup, audiofile ] = \
                unpack('<IffII', self.filein.read(20))
            
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
                                    "rebuild" : 0
                                }
            self.__vvvprint(f"SOND entry {i:#04}: {self.sond[sondkey]}")


    def __init_audo(self):
        self.filein.seek(self.chunk_list["AUDO"]["offset"] + 8)
        nb_entries = unpack('<I', self.filein.read(4))[0]
        self.__vvprint(f"AUDO with {nb_entries} entries")

        offset_table = []
        for i in range(nb_entries):
            offset_table.append(unpack('<I',self.filein.read(4))[0])
        
        self.audo = {}

        for i,offset in enumerate(offset_table):
            self.filein.seek(offset)
            size = unpack('<I', self.filein.read(4))[0]
            audokey = f"{i:#04}"
            self.audo[audokey] = { "offset": offset, "size": size, "compress": 0}

            self.__vvvprint(f"AUDO entry {i:#04}: {self.audo[audokey]}")


    def __audo_get_raw_entry(self,key):

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

    def __get_padding(self, alignement = 16):
        misalignement =  self.fileout_size % alignement
        padding = 0

        if misalignement > 0:
            padding =  alignement - misalignement
        
        return padding
     
    def __write_to_file_sond(self):
        self.filein.seek(self.chunk_list["SOND"]["offset"])
        size = self.chunk_list["SOND"]["size"]
        self.__vvprint("Writing SOND")

        if self.chunk_list["SOND"]["rebuild"] == 0:
            self.__vvprint("Direct copy SOND")
            self.fileout.write(self.filein.read(size + 8))
            self.fileout_size += size + 8

        else:
            self.__vvprint("Rebuild SOND")
            self.fileout.write(self.filein.read(12)) # Token, size, nb entries should be the same
            self.fileout_size += 12
            self.fileout.write(self.filein.read(len(self.sond.keys()) * 4)) # offsets don't change
            self.fileout_size += len(self.sond.keys()) * 4

            for n, key in enumerate(self.sond.keys()):
                if self.sond[key]["rebuild"] == 0:
                    self.__vvvprint(f"Direct copy SOND entry {key}")
                    # We copy the entry from the input file
                    self.fileout.write(self.filein.read(36)) # same entry (36B)
                    
                else:
                    self.__vvvprint(f"Rebuild SOND entry {key}")
                    self.filein.seek(36,1) # we jump this chunk on the input file (36B)
                    self.fileout.write(self.__audo_get_raw_entry(key))

                self.fileout_size += 36

            padding = self.__get_padding(16)
            
            self.fileout.write(b'\x00' * padding )
            self.fileout_size += padding
    
    def __write_to_file_audo(self):
        self.filein.seek(self.chunk_list["AUDO"]["offset"])
        size = self.chunk_list["AUDO"]["size"]
        self.__vvprint("Writing AUDO")

        audo_offset = self.fileout.tell()

        if self.chunk_list["AUDO"]["rebuild"] == 0:
            self.__vvprint("Direct copy AUDO")

            self.fileout.write(self.filein.read(size + 8))
            self.fileout_size += size + 8

            padding = self.__get_padding(16)
            
            self.fileout.write(b'\x00' * padding )
            self.fileout_size += padding

        else:
            self.__vvprint("Rebuild AUDO")
            self.fileout.write(self.filein.read(4)) # Token should be the same
            self.fileout_size += 4
            self.fileout.write(pack('<I', 0xffffffff)) # Unknow size yet
            self.fileout_size += 4
            
            self.fileout.write(pack('<I', len(self.audo.keys()))) # Number of audo entries
            self.fileout_size += 4

            table_offset = self.fileout.tell()

            self.fileout.write(pack('<I', 0xffffffff) * len(self.audo.keys())) # offset entries are unknow yet
            self.fileout_size += 4 * len(self.audo.keys())
                                         
            padding = self.__get_padding(16)
            
            self.fileout.write(b'\x00' * padding )
            self.fileout_size += padding

            for n, key in enumerate(self.audo.keys()):
                self.filein.seek(self.audo[key]["offset"])
                entrysize = self.audo[key]["size"]

                # update entry table
                current_offset = self.fileout.tell()
                self.fileout.seek(table_offset + 4*n)
                self.fileout.write(pack('<I',current_offset))
                self.fileout.seek(current_offset)


                if self.audo[key]["compress"] == 0:
                    self.__vvvprint(f"Direct copy AUDO entry {key}")

                    # We copy the entry from the input file
                    self.fileout.write(self.filein.read(4 + entrysize )) # same entry (4B size + audio size)
                    self.fileout_size += 4 + entrysize

                else:
                    self.__vvvprint(f"Compress copy AUDO entry {key}")

                    self.fileout.write(pack('<I', 0xffffffff) ) # unknow size yet
                    self.fileout_size += 4

                    entrysize = self.__write_to_file_audo_ogg(key)
                    self.fileout_size += entrysize

                    self.fileout.seek( -entrysize - 4 , 1)
                    self.fileout.write(pack('<I', entrysize) )
                    self.fileout.seek( entrysize , 1)

                padding = self.__get_padding(16)
            
                self.fileout.write(b'\x00' * padding )
                self.fileout_size += padding

            padding = self.__get_padding(16)
            
            self.fileout.write(b'\x00' * padding )
            self.fileout_size += padding

            audo_size = self.fileout_size - audo_offset - 8
            self.fileout.seek(audo_offset + 4)          # jump to audo size entry
            self.fileout.write(pack('<I', audo_size))   # write audo size
            self.fileout.seek(audo_size, 1)             # jump at the end of audo chunk

    def __write_to_file_otherchunk(self,token):
        self.filein.seek(self.chunk_list[token]["offset"])
        size = self.chunk_list[token]["size"]
        self.__vvprint(f"Writing {token}")

        if self.chunk_list[token]["rebuild"] == 0:
            self.__vvprint("Direct copy")

            self.fileout.write(self.filein.read(size + 8)) # We copy also  token (4B) and size(4B)
            self.fileout_size += size + 8

        else:
            self.__vvprint("Rebuild needed")
            self.fileout.write(token.encode('ascii'))
            self.fileout.write(pack('<I', 0xffffffff))  # we don't know yet the final size
            self.filein.seek(8,1) # we already have written token (4B) and size(4B)
            self.fileout_size += 8

            if token != "FORM":
                self.__vprint(f"Not implemented but there is something to do to rebuild {token}")

    def __thread_writer(self, process, audo_entry):

        chunk_size = 1024  # Define chunk size to 1024 bytes (the exacts size is not important).

        n_chunks = self.audo[audo_entry]["size"] // chunk_size  # Number of chunks (without the remainder smaller chunk at the end).
        remainder_size = self.audo[audo_entry]["size"] % chunk_size  # Remainder bytes (assume total size is not a multiple of chunk_size).

        self.filein.seek(4 + self.audo[audo_entry]["offset"]) # jump to audio data (skip 4B length)

        for i in range(n_chunks):
            process.stdin.write(self.filein.read(chunk_size))  # Write chunk of data bytes to stdin pipe of oggenc sub-process.

        if (remainder_size > 0):
            process.stdin.write(self.filein.read(remainder_size))  # Write remainder bytes of data bytes to stdin pipe of oggenc sub-process.

        process.stdin.close()  # Close stdin pipe - closing stdin finish encoding the data, and closes FFmpeg sub-process.

    def __write_to_file_audo_ogg(self, audo_entry):
        chunksize = 0
        oggenc_process = (
            Popen(["oggenc","-b",f"{self.bitrate}","-"],bufsize=1024,stdin=PIPE, stdout=PIPE, stderr=PIPE )
        )

        thread = threading.Thread(target=self.__thread_writer, args=(oggenc_process,audo_entry))
        thread.start()

        while thread.is_alive():
            ogg_chunk = oggenc_process.stdout.read(1024)  # Read chunk with arbitrary size from stdout pipe
            chunksize += len(ogg_chunk)
            self.fileout.write(ogg_chunk)  # Write the encoded chunk to the "in-memory file".


        # Read the last encoded chunk.
        ogg_chunk = oggenc_process.stdout.read()  # Read chunk with arbitrary size from stdout pipe
        self.fileout.write(ogg_chunk)  # Write the encoded chunk to the "in-memory file".
        chunksize += len(ogg_chunk)

        oggenc_process.wait() # Wait for oggenc sub-process to end
        
        return chunksize

    def get_sond(self):
        return self.sond
    
    def get_audo(self):
        return self.audo
    
    def sond_replace_entry(self,n,sondentry):
        self.sond[n] = sondentry

    def audo_replace_entry(self,n,filein_path):
        self.audo[n]["data"] = filein_path

    def audo_get_entry(self,n,filein_path):
        with open(filein_path, 'wb+') as fout:
            self.filein.seek(self.audo[n]["offset"] + 4)
            fout.write(self.filein.read(self.audo[n]["size"]))
    
    def audio_set_compress(self, agrp_list ,minsize):

        updated_entries = 0
        for _,key in enumerate(self.sond):

            if (self.sond[key]["audiogroup"] in agrp_list or len(agrp_list) == 0) and self.sond[key]["flags"]["isCompressed"] == 0 :
                audiofile = f"{self.sond[key]['audiofile']:#04}"    # it is a file number (eg 0001)
                size = self.audo[audiofile]["size"]

                if size >= minsize:
 
                    self.sond[key]["flags"]["isCompressed"] = 1
                    self.sond[key]["flags"]["isEmbedded"] = 0
                    self.sond[key]["flags_raw"] =   self.sond[key]["flags"]["isRegular"] * 0x64 | \
                                                    self.sond[key]["flags"]["isCompressed"] * 0x02 | \
                                                    self.sond[key]["flags"]["isEmbedded"] * 0x01
                    
                    # toggle rebuild and compress because we will update data
                    self.sond[key]["rebuild"] = 1
                    self.audo[audiofile]["compress"] = 1

                    self.__vprint(f"audo {audiofile} ({self.sond[key]['name']}) with size {self.__pretty_size(size)} will be compressed")


                    updated_entries += 1

        # if we have updated one or more entries we need to rebuild AUDO and SOND chunks
        if updated_entries > 0:
            self.__vprint(f"{updated_entries} wav entrie(s) will be compressed")

            # toggle rebuild because we will update data
            self.chunk_list["FORM"]["rebuild"] = 1
            self.chunk_list["SOND"]["rebuild"] = 1
            self.chunk_list["AUDO"]["rebuild"] = 1

    def write_to_file(self, fout_path):
        self.fileout_path = fout_path
        self.__open_fileout()

        if self.chunk_list["FORM"]["rebuild"] == 1:

            for _,token in enumerate(self.chunk_list):
                if token == "SOND":
                    self.__write_to_file_sond()
                elif token == "AUDO":
                    self.__write_to_file_audo()
                else:
                    self.__write_to_file_otherchunk(token)

            self.fileout.seek(4)
            self.fileout.write(pack('<I', self.fileout_size - 8)) # update size
        else:
            self.__write_to_file_otherchunk("FORM")


def main():


    parser = argparse.ArgumentParser(description='GameMaker K-dog tool: compress wav to ogg in Gamemaker data files')
    parser.add_argument('-v','--verbose', action='count', default=0, help='Verbose level (cumulative option)')
    parser.add_argument('-m','--minsize', default=MIN_SIZE, help='Minimum WAV size in bytes to target (default 1MB)')
    parser.add_argument('-a','--audiogroup', nargs='?',action='append',type=int, help='Audiogroup ID to process (option can repeat). By default any.')
    parser.add_argument('-b','--bitrate', default=128, help='nominal bitrate (in kbps) to encode at (oggenc -b option). Default 128 kbps')

    parser.add_argument('infilepath', help='Input file path')
    parser.add_argument('outfilepath', help='Output file path')

    args = parser.parse_args()

    if args.audiogroup:
        agrp_list = args.audiogroup
    else:
        agrp_list = []

    myiffdata = IFFdata(args.infilepath, args.verbose, args.bitrate)
    myiffdata.audio_set_compress(agrp_list, args.minsize)
    myiffdata.write_to_file(args.outfilepath)

    exit(0)

if __name__ == '__main__':
    main()