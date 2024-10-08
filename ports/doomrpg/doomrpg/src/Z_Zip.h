#ifndef Z_ZIP_H__
#define Z_ZIP_H__

#include <SDL.h>

#define ZIP_LOCAL_FILE_SIG 0x04034b50
#define ZIP_CENTRAL_DIRECTORY_SIG 0x02014b50
#define ZIP_END_OF_CENTRAL_DIRECTORY_SIG 0x06054b50
#define ZIP_ENCRYPTED_FLAG 0x1

typedef struct zip_entry_s
{
	char* name;
	int offset;
	int csize, usize;
}zip_entry_t;

typedef struct zip_file_s
{
	SDL_RWops* file;
	int entry_count;
	zip_entry_t* entry;
	int page_count;
	int* page;
}zip_file_t;

extern zip_file_t zipFile;

void findAndReadZipDir(zip_file_t* zipFile, int startoffset);
int openZipFile(const char* name, zip_file_t* zipFile);
void closeZipFile(zip_file_t* zipFile);
unsigned char* readZipFileEntry(const char* name, zip_file_t* zipFile, int* sizep);

#endif
