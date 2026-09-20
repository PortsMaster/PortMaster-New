// #define CHOWDREN_USE_CRASHDUMP

#if !defined(_WIN32) || !defined(CHOWDREN_USE_CRASHDUMP)

void install_crash_handler()
{
}

#else

#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include <windows.h>
#include <dbghelp.h>
#include <cstdlib>
#include <strsafe.h>
#include <cstdarg>
#include <cstdio>
#include <intrin.h>     // rdtsc
#include <algorithm>    // sort

namespace CrashHandler {

namespace BlackBox
{
#if ENABLE_BLACKBOX
void AddMessage(const char* message);
void AddMessagef(const char* fmt, ...);
#else
inline void AddMessage(const char*) {}
inline void AddMessagef(const char *, ...) {}
#endif
long GetNumMessages();
const char* GetMessage(long index, int& threadId);
}

struct MemoryStatus
{
    MemoryStatus();

    static MemoryStatus GetCurrent();

    size_t  totalFree;
    size_t  largestFree;
    size_t  totalReserved;
    size_t  totalCommited;
};

namespace StackTrace
{
#if defined (_MSC_VER)
    typedef const void* Address;
#else
#   error "StackTrace not implemented for this platform!"
#endif

    bool InitSymbols();

    int GetCallStack(Address* callStack, int maxDepth, int entriesToSkip = 0);
    int GetCallStack(void* context, Address* callStack, int maxDepth, 
        int entriesToSkip = 0);
    // Faster than other versions, but may be less reliable (no FPO).
    int GetCallStack_Fast(Address* callStack, int maxDepth, int entriesToSkip = 0);

    // @return  Number of chars taken by symbol info.
    int GetSymbolInfo(Address address, char* symbol, int maxSymbolLen);
    // Retrieves whole callstack (using given context), optionally with 4 first function
    // arguments, in readable form.
    // @pre context != 0
    void GetCallStack(void* context, bool includeArguments, char* callStackStr, int maxBufferLen);
}

#pragma comment(lib, "dbghelp.lib")

void GetFileFromPath(const char* path, char* file, int fileNameSize)
{
    char ext[_MAX_EXT] = { 0 };
    _splitpath_s(path, 0, 0, 0, 0, file, fileNameSize, ext, _MAX_EXT);
    strncat_s(file, fileNameSize, ext, _MAX_EXT);
}

void InitStackFrameFromContext(PCONTEXT context, STACKFRAME64& stackFrame)
{
    stackFrame.AddrPC.Offset    = context->Eip;
    stackFrame.AddrFrame.Offset = context->Ebp;
    stackFrame.AddrStack.Offset = context->Esp;
}

void** GetNextStackFrame(void** prevSP)
{
    void** newSP = (void**)(*prevSP);
    if (newSP == prevSP)
        return 0;
    // Difference between stack pointers has to be sane.
    if (newSP > prevSP && ((uintptr_t)newSP - (uintptr_t)prevSP) > 1000000)
        return 0;
    if ((uintptr_t)newSP & (sizeof(void*) - 1))
        return 0;

    return newSP;
}

bool StackTrace::InitSymbols()
{
    static bool ls_initialized(false);
    if (!ls_initialized)
    {
        DWORD options = SYMOPT_FAIL_CRITICAL_ERRORS |
                        SYMOPT_DEFERRED_LOADS |
                        SYMOPT_LOAD_LINES |
                        SYMOPT_UNDNAME;
        SymSetOptions(options);
        const char* dir = NULL;
        if (!SymInitialize(GetCurrentProcess(), dir, options & SYMOPT_DEFERRED_LOADS))
        {
            OutputDebugString("Cannot initialize symbol engine");
            return false;
        }

        ls_initialized = true;
    }
    return true;
}

int StackTrace::GetCallStack(Address* callStack, int maxDepth, int entriesToSkip)
{
    PCONTEXT pContext(0);
    HMODULE hKernel32Dll = GetModuleHandle("kernel32.dll");
    void (WINAPI *pRtlCaptureContext)(PCONTEXT);
    *(void**)&pRtlCaptureContext = GetProcAddress(hKernel32Dll, "RtlCaptureContext");
    CONTEXT context;
    if (pRtlCaptureContext)
    {
        memset(&context, 0, sizeof(context));
        context.ContextFlags = CONTEXT_FULL;
        pRtlCaptureContext(&context);
        pContext = &context;
    }
    // +1 -> skip over "us"
    return GetCallStack(pContext, callStack,  maxDepth, entriesToSkip + 1);
}

int StackTrace::GetCallStack(void* vcontext, Address* callStack, int maxDepth, 
                             int entriesToSkip)
{
    uintptr_t* ebpReg;
    uintptr_t espReg;
    __asm mov [ebpReg], ebp
    __asm mov [espReg], esp

    InitSymbols();

    STACKFRAME64 stackFrame;
    memset(&stackFrame, 0, sizeof(stackFrame));

    PCONTEXT context = (PCONTEXT)vcontext;
    if (context == 0)
    {
        stackFrame.AddrPC.Offset    = ebpReg[1];
        stackFrame.AddrFrame.Offset = ebpReg[0];
        stackFrame.AddrStack.Offset = espReg;
    }
    else
    {
        InitStackFrameFromContext(context, stackFrame);
    }
    stackFrame.AddrPC.Mode      = AddrModeFlat;
    stackFrame.AddrFrame.Mode   = AddrModeFlat;
    stackFrame.AddrStack.Mode   = AddrModeFlat;

    HANDLE process  = GetCurrentProcess();
    HANDLE thread   = GetCurrentThread(); 

    int numEntries(0);
    while (::StackWalk64(IMAGE_FILE_MACHINE_I386, process, thread, 
        &stackFrame, context, 0, SymFunctionTableAccess64, SymGetModuleBase64, NULL) &&
        stackFrame.AddrFrame.Offset != 0 && numEntries < maxDepth)
    {
        if (entriesToSkip > 0)
            --entriesToSkip;
        else
            callStack[numEntries++] = reinterpret_cast<Address>(stackFrame.AddrPC.Offset);
    }
    return numEntries;
}

int StackTrace::GetCallStack_Fast(Address* callStack, int maxDepth, int entriesToSkip)
{
    uintptr_t ebpReg;
    __asm mov [ebpReg], ebp
    void** sp = (void**)ebpReg;
    int numEntries(0);
    while (sp && numEntries < maxDepth)
    {
        if (entriesToSkip > 0)
            --entriesToSkip;
        else
            callStack[numEntries++] = sp[1];

        sp = GetNextStackFrame(sp);
    }
    return numEntries;
}

int StackTrace::GetSymbolInfo(Address address, char* symbol, int maxSymbolLen)
{
    if (!InitSymbols())
        return 0;

    // Start with address.
    int charsAdded = 
        _snprintf_s(symbol, maxSymbolLen, _TRUNCATE, "%p ", address);
    symbol += charsAdded;
    maxSymbolLen -= charsAdded;
    if (maxSymbolLen < 0)
        return charsAdded;

    const DWORD64 address64 = (DWORD64)address;
    // Module name
    IMAGEHLP_MODULE64 moduleInfo;
    ZeroMemory(&moduleInfo, sizeof(moduleInfo));
    moduleInfo.SizeOfStruct = sizeof(moduleInfo);
    const HANDLE hCurrentProcess = GetCurrentProcess();
    if (SymGetModuleInfo64(hCurrentProcess, address64, &moduleInfo))
    {
        char moduleName[_MAX_PATH + 1];
        GetFileFromPath(moduleInfo.ImageName, moduleName, _MAX_PATH);
        const int moduleLen = (int)strlen(moduleName);
        strncpy_s(symbol, maxSymbolLen, moduleName, _TRUNCATE);
        symbol += moduleLen;
        charsAdded += moduleLen;
        maxSymbolLen -= moduleLen;
    }
    if (maxSymbolLen <= 0)
        return charsAdded;

    // Symbol name
    ULONG64 symbolBuffer[(sizeof(SYMBOL_INFO) + MAX_SYM_NAME*sizeof(TCHAR) +
            sizeof(ULONG64) - 1) / sizeof(ULONG64)] = { 0 };
    IMAGEHLP_SYMBOL64* symbolInfo = reinterpret_cast<IMAGEHLP_SYMBOL64*>(symbolBuffer);
    symbolInfo->SizeOfStruct = sizeof(IMAGEHLP_SYMBOL64);
    symbolInfo->MaxNameLength = MAX_SYM_NAME;
    DWORD64 disp(0);
    if (SymGetSymFromAddr64(hCurrentProcess, address64, &disp, symbolInfo))
    {
        const int symbolChars =
            _snprintf_s(symbol, maxSymbolLen, _TRUNCATE, " %s + 0x%X", symbolInfo->Name, disp);
        symbol += symbolChars;
        maxSymbolLen -= symbolChars;
        charsAdded += symbolChars;
    }
    if (maxSymbolLen <= 0)
        return charsAdded;

    // File + line
    DWORD displacementLine;
    IMAGEHLP_LINE64 lineInfo;
    ZeroMemory(&lineInfo, sizeof(lineInfo));
    lineInfo.SizeOfStruct = sizeof(lineInfo);
    if (SymGetLineFromAddr64(hCurrentProcess, address64, &displacementLine, &lineInfo))
    {
        char fileName[_MAX_PATH + 1];
        GetFileFromPath(lineInfo.FileName, fileName, _MAX_PATH);
        int fileLineChars(0);
        if (displacementLine > 0)
        {
            fileLineChars = _snprintf_s(symbol, maxSymbolLen, _TRUNCATE, 
                " %s(%d+%04d byte(s))", fileName, lineInfo.LineNumber, displacementLine);
        }
        else
        {
            fileLineChars = _snprintf_s(symbol, maxSymbolLen, _TRUNCATE,
                " %s(%d)", fileName, lineInfo.LineNumber);
        }
        symbol += fileLineChars;
        maxSymbolLen -= fileLineChars;
        charsAdded += fileLineChars;
    }
    return charsAdded;
}

void StackTrace::GetCallStack(void* vcontext, bool includeArguments, 
                              char* symbol, int maxSymbolLen)
{
    PCONTEXT context = (PCONTEXT)vcontext;
    if (context == 0)
        return;

    InitSymbols();

    STACKFRAME64 stackFrame;
    memset(&stackFrame, 0, sizeof(stackFrame));

    InitStackFrameFromContext(context, stackFrame);
    stackFrame.AddrPC.Mode      = AddrModeFlat;
    stackFrame.AddrFrame.Mode   = AddrModeFlat;
    stackFrame.AddrStack.Mode   = AddrModeFlat;

    while (maxSymbolLen > 0 &&
        ::StackWalk64(IMAGE_FILE_MACHINE_I386,
            ::GetCurrentProcess(), ::GetCurrentThread(), &stackFrame,
            context, NULL, /*Internal_ReadProcessMemory,*/
            SymFunctionTableAccess64, SymGetModuleBase64, NULL) != FALSE &&
        stackFrame.AddrFrame.Offset != 0)
    {
        Address addr = reinterpret_cast<Address>(stackFrame.AddrPC.Offset);
        int charsAdded = GetSymbolInfo(addr, symbol, maxSymbolLen);
        maxSymbolLen -= charsAdded;
        symbol += charsAdded;
        if (maxSymbolLen > 0 && includeArguments)
        {
            charsAdded = _snprintf_s(symbol, maxSymbolLen, _TRUNCATE, 
                " (0x%08X 0x%08X 0x%08X 0x%08x)\n", stackFrame.Params[0],
                stackFrame.Params[1], stackFrame.Params[2], stackFrame.Params[3]);
            maxSymbolLen -= charsAdded;
            symbol += charsAdded;
        }
    }
}

MemoryStatus::MemoryStatus()
:   totalFree(0),
    largestFree(0),
    totalReserved(0),
    totalCommited(0)
{
}

MemoryStatus MemoryStatus::GetCurrent()
{
    MemoryStatus status;

    MEMORY_BASIC_INFORMATION info;
    unsigned char* address(0);
    SIZE_T bytesInfo = ::VirtualQuery(address, &info, sizeof(info));
    while (bytesInfo != 0)
    {
        if (info.State & MEM_FREE)
        {
            status.totalFree += info.RegionSize;
            if (info.RegionSize > status.largestFree)
                status.largestFree = info.RegionSize;
        }
        else
        {
            if (info.State & MEM_RESERVE)
                status.totalReserved += info.RegionSize;
            if (info.State & MEM_COMMIT)
                status.totalCommited += info.RegionSize;
        }
        address += info.RegionSize;
        memset(&info, 0, sizeof(info));
        bytesInfo = ::VirtualQuery(address, &info, sizeof(info));
    }

    return status;
}


char s_miniDumpFileName[MAX_PATH] = "crash.dmp";
char s_reportFileName[MAX_PATH] = "crash.txt";

void WriteProcessName(FILE* f)
{
    fprintf(f, "Process: ");
    char buffer[MAX_PATH + 1];
    HMODULE hModule = NULL; 
    GetModuleFileName(hModule, buffer, MAX_PATH);
    const char* lastSeparatorPos = strrchr(buffer, '\\');
    if (lastSeparatorPos != 0)
        fprintf(f, lastSeparatorPos + 1); // +1 -> skip over separator
    else
        fprintf(f, buffer);
}
void WriteSystemInfo(FILE* f)
{
    OSVERSIONINFOEX sysInfo;
    memset(&sysInfo, 0, sizeof(sysInfo));
    sysInfo.dwOSVersionInfoSize = sizeof(sysInfo);
    ::GetVersionEx((OSVERSIONINFO*)&sysInfo);

    // We're mainly interested in rough info and latest
    // systems.
    fprintf(f, "System: ");
    if (sysInfo.dwMajorVersion == 6 && sysInfo.dwMinorVersion == 0)
    {
        if (sysInfo.wProductType != VER_NT_WORKSTATION)
            fprintf(f, "Windows Server 2008\n");
        else
            fprintf(f, "Windows Vista\n");
    }
    else if (sysInfo.dwMajorVersion == 6 && sysInfo.dwMinorVersion == 1)
    {
        fprintf(f, "Windows 7\n");
    }
    else if (sysInfo.dwMajorVersion == 5)
    {
        if (sysInfo.dwMinorVersion == 2)
            fprintf(f, "Windows Server 2003\n");
        else if (sysInfo.dwMinorVersion == 1)
            fprintf(f, "Windows XP\n");
        else if (sysInfo.dwMinorVersion == 0)
            fprintf(f, "Windows 2000\n");
    }
    else
    {
        fprintf(f, "Unknown Windows version - %d.%d (%s)\n",
            sysInfo.dwMajorVersion, sysInfo.dwMinorVersion,
            sysInfo.szCSDVersion);
    }
}
void WriteProcessorInfo(FILE* f)
{
    SYSTEM_INFO sysInfo;
    memset(&sysInfo, 0, sizeof(sysInfo));
    GetSystemInfo(&sysInfo);
    fprintf(f, "Number of CPUs: %d\nProcessor type: %d\n",
        sysInfo.dwNumberOfProcessors, sysInfo.dwProcessorType);
}
void WriteDateTime(FILE* f)
{
    SYSTEMTIME st;
    ::GetLocalTime(&st);
    fprintf(f, "Date/time: %d/%d/%d, %02d:%02d:%02d:%d\n", 
        st.wDay, st.wMonth, st.wYear, st.wHour, st.wMinute, 
        st.wSecond, st.wMilliseconds);
}

void WriteHeader(FILE* f)
{
    fprintf(f, "Crash report\n============\n");
}

const char* GetExceptionString(DWORD exc)
{
#define EXC_CASE(EXC)   case EXCEPTION_##EXC : return "EXCEPTION_" #EXC
    switch (exc)
    {
        EXC_CASE(ACCESS_VIOLATION);
        EXC_CASE(DATATYPE_MISALIGNMENT);
        EXC_CASE(BREAKPOINT);
        EXC_CASE(SINGLE_STEP);
        EXC_CASE(ARRAY_BOUNDS_EXCEEDED);
        EXC_CASE(FLT_DENORMAL_OPERAND);
        EXC_CASE(FLT_DIVIDE_BY_ZERO);
        EXC_CASE(FLT_INEXACT_RESULT);
        EXC_CASE(FLT_INVALID_OPERATION);
        EXC_CASE(FLT_OVERFLOW);
        EXC_CASE(FLT_STACK_CHECK);
        EXC_CASE(FLT_UNDERFLOW);
        EXC_CASE(INT_DIVIDE_BY_ZERO);
        EXC_CASE(INT_OVERFLOW);
        EXC_CASE(PRIV_INSTRUCTION);
        EXC_CASE(IN_PAGE_ERROR);
        EXC_CASE(ILLEGAL_INSTRUCTION);
        EXC_CASE(NONCONTINUABLE_EXCEPTION);
        EXC_CASE(STACK_OVERFLOW);
        EXC_CASE(INVALID_DISPOSITION);
        EXC_CASE(GUARD_PAGE);
        EXC_CASE(INVALID_HANDLE);
    default:
        return "UNKNOWN";
    }
#undef EXC_CASE
}

void WriteExceptionInfo(FILE* f, EXCEPTION_POINTERS* exceptionPtrs)
{
    WriteProcessName(f);
    fprintf(f, "\n");

    fprintf(f, "Reason: 0x%X - %s", exceptionPtrs->ExceptionRecord->ExceptionCode,
            GetExceptionString(exceptionPtrs->ExceptionRecord->ExceptionCode));
    fprintf(f, " at %04X:%p\n", exceptionPtrs->ContextRecord->SegCs,
            exceptionPtrs->ExceptionRecord->ExceptionAddress);

    if (exceptionPtrs->ExceptionRecord->ExceptionCode == EXCEPTION_ACCESS_VIOLATION)
    {
        fprintf(f, "Attempt to %s 0x%08X\n", 
            (exceptionPtrs->ExceptionRecord->ExceptionInformation[0] == 1 ? 
            "write to" : "read from"), exceptionPtrs->ExceptionRecord->ExceptionInformation[1]);
    }
    const DWORD threadId = ::GetCurrentThreadId();
    fprintf(f, "Thread ID: 0x%X [%d]\n\n", threadId, threadId);
}
void WriteEnvironmentInfo(FILE* f)
{
    fprintf(f, "Environment\n===========\n");
    WriteDateTime(f);
    WriteProcessorInfo(f);
    WriteSystemInfo(f);
    fprintf(f, "\n");
}

bool WriteMiniDump(EXCEPTION_POINTERS* exceptionPtrs, const char* fileName)
{
    HANDLE hDump = ::CreateFile(fileName, GENERIC_WRITE, FILE_SHARE_READ, 0,
        CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
    if (hDump != INVALID_HANDLE_VALUE)
    {
        MINIDUMP_EXCEPTION_INFORMATION dumpInfo = { 0 };
        dumpInfo.ClientPointers     = TRUE;
        dumpInfo.ExceptionPointers  = exceptionPtrs;
        dumpInfo.ThreadId           = ::GetCurrentThreadId();

        MINIDUMP_TYPE dumpType = (MINIDUMP_TYPE)(MiniDumpWithPrivateReadWriteMemory | 
            MiniDumpWithThreadInfo | MiniDumpWithUnloadedModules); 

        const BOOL success = ::MiniDumpWriteDump(
            ::GetCurrentProcess(), ::GetCurrentProcessId(), hDump,
            dumpType, &dumpInfo, 0, 0);
        ::CloseHandle(hDump);
        return success == TRUE;
    }
    return false;
}

void WriteBlackBoxMessages(FILE* f)
{
#if ENABLE_BLACKBOX
    const int numMessages = BlackBox::GetNumMessages();
    if (numMessages <= 0)
        return;

    fprintf(f, "BlackBox messages\n=================\n");
    for (int i = 0; i < numMessages; ++i)
    {
        int threadId;
        const char* message = BlackBox::GetMessage(i, threadId);
        fprintf(f, "%d: Thread 0x%X: %s\n", i, threadId, message);
    }
#endif
}
void WriteMemoryStatus(FILE* f, const MemoryStatus& status)
{
    fprintf(f, "Memory status\n=============\n");
    fprintf(f, "Total Reserved: %dK (%dM) bytes\n", status.totalReserved >> 10,
        status.totalReserved >> 20);
    fprintf(f, "Total Commited: %dK (%dM) bytes\n", status.totalCommited >> 10,
        status.totalCommited >> 20);
    fprintf(f, "Total Free: %dK (%dM) bytes\n", status.totalFree >> 10,
        status.totalFree >> 20);
    fprintf(f, "Largest Free: %dK (%dM) bytes\n\n", status.largestFree >> 10,
        status.largestFree >> 20);
}

void WriteRegisters(FILE* f, EXCEPTION_POINTERS* exceptionPtrs)
{
    if (IsBadReadPtr(exceptionPtrs, sizeof(EXCEPTION_POINTERS)))
        return;

    const CONTEXT* ctx = exceptionPtrs->ContextRecord;
    fprintf(f, "Registers\n=========\n");
    fprintf(f, "EAX=%08X EBX=%08X ECX=%08X EDX=%08X\n" \
        "ESI=%08X EDI=%08X EBP=%08X ESP=%08X EIP=%08X\n" \
        "FLG=%08X CS=%04X DS=%04X SS=%04X ES=%04X FS=%04X GS=%04X\n\n",
        ctx->Eax, ctx->Ebx, ctx->Ecx, ctx->Edx, ctx->Esi, ctx->Edi,
        ctx->Ebp, ctx->Esp, ctx->Eip, ctx->EFlags, ctx->SegCs,
        ctx->SegDs, ctx->SegSs, ctx->SegEs, ctx->SegFs, ctx->SegGs);
}

void WriteCallStack(FILE* f, PCONTEXT context)
{
    char callStack[2048];
    memset(callStack, 0, sizeof(callStack));
    StackTrace::GetCallStack(context, true, callStack, sizeof(callStack) - 1);
    fprintf(f, "Call stack\n==========\n%s\n", callStack);
}

volatile unsigned long s_inFilter = 0;
LONG __stdcall exception_filter(EXCEPTION_POINTERS* exceptionPtrs)
{
    LONG returnCode = EXCEPTION_CONTINUE_SEARCH;
    
    // Ignore multiple calls.
    if (s_inFilter != 0)
        return EXCEPTION_CONTINUE_EXECUTION;
    s_inFilter = 1;
    
    // Cannot really do much in case of stack overflow, it'll probably bomb soon 
    // anyway.
    if (exceptionPtrs->ExceptionRecord->ExceptionCode == EXCEPTION_STACK_OVERFLOW)
    {
        OutputDebugString("*** FATAL ERROR: EXCEPTION_STACK_OVERFLOW detected!");
    }
    const bool miniDumpOK = WriteMiniDump(exceptionPtrs, s_miniDumpFileName);

    FILE* f = ::fopen(s_reportFileName, "wt");
    WriteHeader(f);
    WriteExceptionInfo(f, exceptionPtrs);
    WriteCallStack(f, exceptionPtrs->ContextRecord);

    WriteEnvironmentInfo(f);
    MemoryStatus memStatus = MemoryStatus::GetCurrent();
    WriteMemoryStatus(f, memStatus);
    WriteRegisters(f, exceptionPtrs);
    WriteBlackBoxMessages(f);

    fprintf(f, (miniDumpOK ? "\nMini dump saved successfully.\n" : "\nFailed to save minidump.\n"));
    ::fclose(f);

    return returnCode;
}

} // namespace CrashHandler

void install_crash_handler()
{
    SetUnhandledExceptionFilter(CrashHandler::exception_filter);
}

#endif
