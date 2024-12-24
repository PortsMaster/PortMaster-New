local ffi = require "ffi"
local comdlg32 = ffi.load("comdlg32")

local Dialogue = {}
ffi.cdef [[
    typedef void* HWND;
    typedef const char* LPCSTR;
    typedef char* LPSTR;
    typedef int BOOL;
    typedef unsigned int DWORD;
    typedef void* HINSTANCE;
    typedef unsigned short WORD;
    typedef long long LPARAM;
    typedef const void* LPCVOID;

    typedef struct {
        DWORD     lStructSize;
        HWND      hwndOwner;
        HINSTANCE hInstance;
        LPCSTR    lpstrFilter;
        LPSTR     lpstrCustomFilter;
        DWORD     nMaxCustFilter;
        DWORD     nFilterIndex;
        LPSTR     lpstrFile;
        DWORD     nMaxFile;
        LPSTR     lpstrFileTitle;
        DWORD     nMaxFileTitle;
        LPCSTR    lpstrInitialDir;
        LPCSTR    lpstrTitle;
        DWORD     Flags;
        WORD      nFileOffset;
        WORD      nFileExtension;
        LPCSTR    lpstrDefExt;
        LPARAM    lCustData;
        LPCVOID   lpfnHook;
        LPCSTR    lpTemplateName;
        void*     pvReserved;
        DWORD     dwReserved;
        DWORD     FlagsEx;
    } WINDOWDIALOGUE;

    BOOL GetSaveFileNameA(WINDOWDIALOGUE *lpofn);
    BOOL GetOpenFileNameA(WINDOWDIALOGUE *lpofn);
]]

function Dialogue.askOpenFile(title, fileType)
	if title == nil then title = "Save As" end
	if fileType == nil then fileType = {{"All Files", "*.*"}} end

	local ofn = ffi.new("WINDOWDIALOGUE")
	ofn.lStructSize = ffi.sizeof("WINDOWDIALOGUE")

	local strFilter = ""
	for _, daType in ipairs(fileType) do
		local lmfao = daType[1] .. "\0" .. daType[2] .. "\0"
		strFilter = strFilter .. lmfao
	end
	ofn.lpstrFilter = strFilter

	ofn.lpstrFile = ffi.new("char[260]")
	ofn.nMaxFile = 260
	ofn.lpstrFileTitle = ffi.new("char[260]")
	ofn.nMaxFileTitle = 260
	ofn.lpstrTitle = title
	ofn.Flags = 0x00000002

	if comdlg32.GetOpenFileNameA(ofn) == 1 then
		return ffi.string(ofn.lpstrFile)
	end
	return nil
end

function Dialogue.askSaveAsFile(title, fileType, initialFile)
	if title == nil then title = "Save As" end
	if fileType == nil then fileType = {{"All Files", "*.*"}} end
	if initialFile == nil then initialFile = "" end

	local ofn = ffi.new("WINDOWDIALOGUE")
	ofn.lStructSize = ffi.sizeof("WINDOWDIALOGUE")

	local strFilter = ""
	for _, daType in ipairs(fileType) do
		local lmfao = daType[1] .. "\0" .. daType[2] .. "\0"
		strFilter = strFilter .. lmfao
	end
	ofn.lpstrFilter = strFilter

	ofn.lpstrFile = ffi.new("char[260]", initialFile)
	ofn.nMaxFile = 260
	ofn.lpstrFileTitle = ffi.new("char[260]")
	ofn.nMaxFileTitle = 260
	ofn.lpstrTitle = title
	ofn.Flags = 0x00000002

	if comdlg32.GetSaveFileNameA(ofn) == 1 then
		return ffi.string(ofn.lpstrFile)
	end
end

return Dialogue
