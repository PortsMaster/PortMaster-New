/* Z_Zone.c */

//-----------------------------------------------------------------------------
//
// DESCRIPTION:
//      Zone Memory Allocation. Neat.
//
// Based on the doom64 Ex code by Samuel Villarreal
// https://github.com/svkaiser/Doom64EX/blob/master/src/engine/zone/z_zone.cc
//-----------------------------------------------------------------------------

#include <SDL.h>
#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <zlib.h>

#include "DoomRPG.h"
#include "Z_Zip.h"

zip_file_t zipFile;

static void* zip_alloc(void* ctx, unsigned int items, unsigned int size)
{
	return SDL_malloc(items * size);
}

static void zip_free(void* ctx, void* ptr)
{
	SDL_free(ptr);
}

void findAndReadZipDir(zip_file_t* zipFile, int startoffset)
{
    int sig, offset, count, disknum, diskwithcd, diskentries;
    int cdsize;
    int namesize, metasize, commentsize;
    int i;

    printf("findAndReadZipDir: Starting at offset %d\n", startoffset);

    SDL_RWseek(zipFile->file, startoffset, SEEK_SET);

    sig = File_readLong(zipFile->file);
    printf("Signature: 0x%x\n", sig);
    if (sig != ZIP_END_OF_CENTRAL_DIRECTORY_SIG) {
        printf("Error: Wrong zip end of central directory signature (0x%x)\n", sig);
        return;
    }

    disknum = File_readShort(zipFile->file);
    diskwithcd = File_readShort(zipFile->file);
    diskentries = File_readShort(zipFile->file);
    count = File_readShort(zipFile->file);
    cdsize = File_readLong(zipFile->file);
    offset = File_readLong(zipFile->file);

    printf("Disk number: %d\n", disknum);
    printf("Disk with central directory: %d\n", diskwithcd);
    printf("Entries on this disk: %d\n", diskentries);
    printf("Total entries: %d\n", count);
    printf("Central directory size: %d\n", cdsize);
    printf("Central directory offset: %d\n", offset);

    if (count == 0) {
        printf("Error: No entries found in zip file\n");
        return;
    }

    zipFile->entry = SDL_calloc(count, sizeof(zip_entry_t));
    if (zipFile->entry == NULL) {
        printf("Error: Failed to allocate memory for zip entries\n");
        return;
    }
    zipFile->entry_count = count;

    SDL_RWseek(zipFile->file, offset, SEEK_SET);

    for (i = 0; i < count; i++)
    {
        zip_entry_t* entry = zipFile->entry + i;

        sig = File_readLong(zipFile->file);
        if (sig != ZIP_CENTRAL_DIRECTORY_SIG) {
            printf("Error: Wrong zip central directory signature (0x%x) for entry %d\n", sig, i);
            continue;
        }

        File_readShort(zipFile->file); // version made by
        File_readShort(zipFile->file); // version to extract
        File_readShort(zipFile->file); // general
        File_readShort(zipFile->file); // method
        File_readShort(zipFile->file); // last mod file time
        File_readShort(zipFile->file); // last mod file date
        File_readLong(zipFile->file); // crc-32
        entry->csize = File_readLong(zipFile->file); // csize
        entry->usize = File_readLong(zipFile->file); // usize
        namesize = File_readShort(zipFile->file);
        metasize = File_readShort(zipFile->file);
        commentsize = File_readShort(zipFile->file);
        File_readShort(zipFile->file); // disk number start
        File_readShort(zipFile->file); // int file atts
        File_readLong(zipFile->file); // ext file atts
        entry->offset = File_readLong(zipFile->file);

        entry->name = SDL_malloc(namesize + 1);
        SDL_RWread(zipFile->file, (unsigned char*)entry->name, sizeof(byte), namesize);
        entry->name[namesize] = 0;

        SDL_RWseek(zipFile->file, metasize, SEEK_CUR);
        SDL_RWseek(zipFile->file, commentsize, SEEK_CUR);

        printf("Read entry %d: %s (compressed size: %d, uncompressed size: %d)\n", 
               i, entry->name, entry->csize, entry->usize);
    }
}

int openZipFile(const char* name, zip_file_t* zipFile)
{
    byte buf[65536];  // Increased buffer size
    int filesize, back, maxback;
    int i, n;

    zipFile->file = SDL_RWFromFile(name, "rb");
    if (zipFile->file == NULL) {
        printf("openZipFile: cannot open file %s. Error: %s\n", name, SDL_GetError());
        return 1;
    }

    filesize = (int)SDL_RWsize(zipFile->file);
    printf("Zip file size: %d bytes\n", filesize);

    maxback = MIN(filesize, 65536);
    back = MIN(maxback, sizeof(buf));

    SDL_RWseek(zipFile->file, filesize - back, SEEK_SET);
    n = SDL_RWread(zipFile->file, buf, sizeof(byte), back);
    if (n != back) {
        printf("Error: Failed to read %d bytes, only read %d\n", back, n);
        return 3;
    }

    for (i = n - 22; i >= 0; i--)  // Search for the End of Central Directory Record
    {
        if (buf[i] == 'P' && buf[i+1] == 'K' && buf[i+2] == 5 && buf[i+3] == 6) {
            findAndReadZipDir(zipFile, filesize - back + i);
            printf("Successfully found and read zip directory\n");
            if (zipFile->entry_count == 0) {
                printf("Error: No entries found in zip file\n");
                return 4;
            }
            return 0;
        }
    }

    printf("Error: Cannot find end of central directory\n");
    return 2;
}

void closeZipFile(zip_file_t* zipFile)
{
	if (zipFile->entry) {
		SDL_free(zipFile->entry);
	}
	if (zipFile->file) {
		SDL_RWclose(zipFile->file);
	}
}

unsigned char* readZipFileEntry(const char* name, zip_file_t* zipFile, int* sizep)
{
    zip_entry_t* entry = NULL;
    int i, sig, general, method, namelength, extralength;
    byte* cdata;
    int code;

    printf("Searching for file: %s\n", name);
    printf("Total entries in zip: %d\n", zipFile->entry_count);

    // Print all entries in the zip file
    for (i = 0; i < zipFile->entry_count; i++)
    {
        printf("Entry %d: %s\n", i, zipFile->entry[i].name);
        if (!SDL_strcasecmp(name, zipFile->entry[i].name)) {
            entry = &zipFile->entry[i];
            break;
        }
    }

    if (entry == NULL) {
        printf("Error: File '%s' not found in the zip archive.\n", name);
        *sizep = 0;
        return NULL;
    }

    printf("Found file: %s at offset %d\n", entry->name, entry->offset);

    if (SDL_RWseek(zipFile->file, entry->offset, SEEK_SET) < 0) {
        printf("Error: Unable to seek to file offset. SDL Error: %s\n", SDL_GetError());
        return NULL;
    }

    sig = File_readLong(zipFile->file);
    if (sig != ZIP_LOCAL_FILE_SIG) {
        printf("Error: Wrong zip local file signature (0x%x)\n", sig);
        return NULL;
    }

    File_readShort(zipFile->file); // version
    general = File_readShort(zipFile->file); // general
    if (general & ZIP_ENCRYPTED_FLAG) {
        printf("Error: Zipfile content is encrypted\n");
        return NULL;
    }

    method = File_readShort(zipFile->file);
    File_readShort(zipFile->file); // file time
    File_readShort(zipFile->file); // file date
    File_readLong(zipFile->file); // crc-32
    File_readLong(zipFile->file); // csize
    File_readLong(zipFile->file); // usize
    namelength = File_readShort(zipFile->file);
    extralength = File_readShort(zipFile->file);

    SDL_RWseek(zipFile->file, namelength + extralength, SEEK_CUR);

    cdata = SDL_malloc(entry->csize);
    if (cdata == NULL) {
        printf("Error: Failed to allocate memory for compressed data\n");
        return NULL;
    }

    if (SDL_RWread(zipFile->file, cdata, sizeof(byte), entry->csize) != entry->csize) {
        printf("Error: Failed to read compressed data. SDL Error: %s\n", SDL_GetError());
        SDL_free(cdata);
        return NULL;
    }

    if (method == 0)
    {
        *sizep = entry->usize;
        return cdata;
    }
    else if (method == 8)
    {
        byte* udata = SDL_malloc(entry->usize);
        if (udata == NULL) {
            printf("Error: Failed to allocate memory for uncompressed data\n");
            SDL_free(cdata);
            return NULL;
        }

        z_stream stream;
        SDL_memset(&stream, 0, sizeof stream);
        stream.zalloc = zip_alloc;
        stream.zfree = zip_free;
        stream.opaque = Z_NULL;
        stream.next_in = cdata;
        stream.avail_in = entry->csize;
        stream.next_out = udata;
        stream.avail_out = entry->usize;

        code = inflateInit2(&stream, -15);
        if (code != Z_OK) {
            printf("Error: zlib inflateInit2 error: %s\n", stream.msg);
            SDL_free(cdata);
            SDL_free(udata);
            return NULL;
        }

        code = inflate(&stream, Z_FINISH);
        if (code != Z_STREAM_END) {
            printf("Error: zlib inflate error: %s\n", stream.msg);
            inflateEnd(&stream);
            SDL_free(cdata);
            SDL_free(udata);
            return NULL;
        }

        code = inflateEnd(&stream);
        if (code != Z_OK) {
            printf("Error: zlib inflateEnd error: %s\n", stream.msg);
            SDL_free(cdata);
            SDL_free(udata);
            return NULL;
        }

        SDL_free(cdata);

        *sizep = entry->usize;
        return udata;
    }
    else {
        printf("Error: Unknown zip method: %d\n", method);
        SDL_free(cdata);
        return NULL;
    }
}
