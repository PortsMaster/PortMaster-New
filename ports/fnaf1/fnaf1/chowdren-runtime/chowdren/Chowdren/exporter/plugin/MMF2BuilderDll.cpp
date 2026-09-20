// Copyright (c) Mathias Kaerlev 2014.

// This file is part of Chowdren.

// Chowdren is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// Chowdren is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with Chowdren.  If not, see <http://www.gnu.org/licenses/>.

#include "stdafx.h"
#include "MMF2BuilderDll.h"
#include <stdio.h>
#include <string>

#define BUILDER_ID 0x30000000

LPCWSTR BUILD_NAMES[] = {
    L"Chowdren (Windows)",
    L"Chowdren (Windows + Source)",
    L"Chowdren (Source)",
    L"Chowdren (CCN)"
};

LPCWSTR BUILD_FILTERS[] = {
    L"Executable|*.exe|All files|*.*||",
    L"Executable|*.exe|All files|*.*||",
    L"CMake config|CMakeLists.txt||",
    L"Sub-application|*.ccn|All files|*.*||"
};

LPCWSTR SELECTOR_TITLES[] = {
    L"Save as Chowdren (Windows)",
    L"Save as Chowdren (Windows + Source)",
    L"Save as Chowdren (Source)",
    L"Save as Chowdren (CCN)"
};

LPCWSTR DEFAULT_EXTENSIONS[] = {
    L".exe",
    L".exe",
    L".txt",
    L".ccn"
};

BOOL APIENTRY DllMain( HANDLE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
					 )
{
    switch (ul_reason_for_call)
	{
		case DLL_PROCESS_ATTACH:
		case DLL_THREAD_ATTACH:
		case DLL_THREAD_DETACH:
		case DLL_PROCESS_DETACH:
			break;
    }
    return TRUE;
}

// Return the number of build types added by the dll
int WINAPI GetNumberOfBuildTypes()
{
	return 4;
}

// Return the name of a given build type
LPCWSTR WINAPI GetBuildTypeName(int idx)
{
    return BUILD_NAMES[idx];
}

// Return the ID of a given build type, must be a DWORD greater than 0x10000000
DWORD WINAPI GetBuildType(int idx)
{
	return BUILDER_ID + idx;
}

// Return the options required for a given build type
// Refer to the .h file for more info
DWORD WINAPI GetBuildOptions(int idx)
{
		// return BUILDEROPTION_ZIP_CHUNKS | BUILDEROPTION_SAVE_IMAGES_AS_FILES | BUILDEROPTION_SAVE_SOUNDS_AS_FILES | BUILDEROPTION_SAVE_MUSICS_AS_FILES | BUILDEROPTION_PNG_WITH_ALPHA_ALWAYS;
    return BUILDEROPTION_ZIP_CHUNKS;
}

// Return the file filter to display in the file selector for a given build type when the user builds an application
LPCWSTR WINAPI GetFileSelectorFilter(int idx)
{
    return BUILD_FILTERS[idx];
}

// Return the title of the file selector for a given build type when the user builds an application
LPCWSTR WINAPI GetFileSelectorTitle(int idx)
{
	return SELECTOR_TITLES[idx];
}

// Return the default file extension for a given build type (only letters, no '.')
LPCWSTR WINAPI GetFileSelectorDefExt(int idx)
{
    return DEFAULT_EXTENSIONS[idx];
}

// Builds the application
//
// pTargetPathname = target name, e.g. c:\myApplication\release\app.exe
// pCCNPathname = CCN name, usually application.ccn in a Bldxxx sub-directory of the Windows temp folder.
//				  Image and/or sound and/or music files are saved in sub-directories of the directory of the CCN file
// idx = build type index
// buildFlags = nothing really interesting currently, only internal flags for mmf2 - passed just in case we need to pass specific flags later
//
BOOL WINAPI Build (LPCWSTR pTargetPathname, LPCWSTR pCCNPathname, int idx, DWORD buildFlags)
{
	// Test : just copy ccn file
	// return CopyFileW(pCCNPathname, pTargetPathname, FALSE);
    STARTUPINFOW         siStartupInfo;
    PROCESS_INFORMATION piProcessInfo;

    memset(&siStartupInfo, 0, sizeof(siStartupInfo));
    memset(&piProcessInfo, 0, sizeof(piProcessInfo));
    siStartupInfo.dwFlags = STARTF_USESTDHANDLES;
    siStartupInfo.hStdInput = GetStdHandle(STD_INPUT_HANDLE);
    siStartupInfo.hStdOutput =  GetStdHandle(STD_OUTPUT_HANDLE);
    siStartupInfo.hStdError = GetStdHandle(STD_ERROR_HANDLE);

    siStartupInfo.cb = sizeof(siStartupInfo);

    wchar_t commandline[MAX_PATH * 2 + 2];
    swprintf_s(commandline, L" %d \"%s\" \"%s\"", idx, pCCNPathname, pTargetPathname);

    wchar_t szAppPath[MAX_PATH];
    std::wstring strAppDirectory;
    ::GetModuleFileNameW(0, szAppPath, sizeof(szAppPath) - 1);
    strAppDirectory = szAppPath;
    strAppDirectory = strAppDirectory.substr(0, strAppDirectory.rfind(L"\\"));
    const wchar_t * tempdirectory = strAppDirectory.c_str();
    wchar_t directory[MAX_PATH];
    swprintf(directory, MAX_PATH, L"%s%s", tempdirectory, L"\\Data\\Runtime\\Chowdren\\");
    wchar_t exe_path[MAX_PATH];
    swprintf(exe_path, MAX_PATH, L"%s%s", directory, L"run.exe");
    // setting error mode to prevent "no disk" errors
    unsigned int error_mode = SetErrorMode(SEM_NOOPENFILEERRORBOX | SEM_FAILCRITICALERRORS);
    bool status = CreateProcessW(exe_path, commandline, 0, 0, FALSE,
        CREATE_DEFAULT_ERROR_MODE | CREATE_NO_WINDOW, 0, directory,
        &siStartupInfo, &piProcessInfo) == TRUE;
    bool ret;
    if (status)
    {
        // Wait until application has terminated
        WaitForSingleObject(piProcessInfo.hProcess, INFINITE);

        // Close process and thread handles
        ::CloseHandle(piProcessInfo.hThread);
        ::CloseHandle(piProcessInfo.hProcess);
        ret = true;
    }
    else
    {
        // Get last error.
        DWORD err = GetLastError();

        // Translate ErrorCode to String.
        LPTSTR Error = 0;
        if(::FormatMessage( FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM,
                            NULL,
                            err,
                            0,
                            (LPTSTR)&Error,
                            0,
                            NULL) == 0)
        {
           // Failed in translating.
        }

        // Display message.
        MessageBox(NULL, Error, "Couldn't open Chowdren build process", MB_OK|MB_ICONWARNING );

        // Free the buffer.
        if( Error )
        {
           ::LocalFree( Error );
           Error = 0;
        }

        ret = false;
    }
    SetErrorMode(error_mode);
    return ret;
}
