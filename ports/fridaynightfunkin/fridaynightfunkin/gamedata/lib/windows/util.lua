local ffi = require "ffi"
local dwmapi = ffi.load("dwmapi")

local Util = {}
ffi.cdef [[
	typedef int BOOL;
	typedef long LONG;
	typedef uint32_t UINT;
	typedef int HRESULT;
	typedef unsigned int DWORD;
	typedef const void* PVOID;
	typedef const void* LPCVOID;
	typedef const char* LPCSTR;
	typedef DWORD HMENU;
	typedef struct HWND HWND;
	typedef void* HANDLE;
    typedef HANDLE HCURSOR;

	typedef struct tagRECT {
		union{
			struct{
				LONG left;
				LONG top;
				LONG right;
				LONG bottom;
			};
			struct{
				LONG x1;
				LONG y1;
				LONG x2;
				LONG y2;
			};
			struct{
				LONG x;
				LONG y;
			};
		};
	} RECT, *PRECT,  *NPRECT,  *LPRECT;

	HWND FindWindowA(LPCSTR lpClassName, LPCSTR lpWindowName);
	HWND FindWindowExA(HWND hwndParent, HWND hwndChildAfter, LPCSTR lpszClass, LPCSTR lpszWindow);
	HWND GetActiveWindow(void);
	LONG SetWindowLongA(HWND hWnd, int nIndex, LONG dwNewLong);
	BOOL ShowWindow(HWND hWnd, int nCmdShow);
	BOOL UpdateWindow(HWND hWnd);

	HRESULT DwmGetWindowAttribute(HWND hwnd, DWORD dwAttribute, PVOID pvAttribute, DWORD cbAttribute);
	HRESULT DwmSetWindowAttribute(HWND hwnd, DWORD dwAttribute, LPCVOID pvAttribute, DWORD cbAttribute);
	HRESULT DwmFlush();

	HCURSOR LoadCursorA(HANDLE hInstance, const char* lpCursorName);
    HCURSOR SetCursor(HCURSOR hCursor);
]]

local Rect = ffi.metatype("RECT", {})

local function toInt(v) return v and 1 or 0 end
local function ffiNew(type, v)
	v = ffi.new(type, v); return v, ffi.sizeof(v)
end

local function getWindowHandle(title)
	local window = ffi.C.FindWindowA(nil, title)
	if window == nil then
		window = ffi.C.GetActiveWindow()
		window = ffi.C.FindWindowExA(window, nil, nil, title)
	end
	return window
end

function Util.setDarkMode(enable)
	local window = ffi.C.GetActiveWindow() or getWindowHandle(love.window.getTitle())

	local darkMode, size = ffiNew("int[1]", toInt(enable))
	local result = dwmapi.DwmSetWindowAttribute(window, 19, darkMode, size)
	if result ~= 0 then
		dwmapi.DwmSetWindowAttribute(window, 20, darkMode, size)
	end
end

local currentCursor = "ARROW"
local CursorType = {
	ARROW = 32512,
	IBEAM = 32513,
	WAIT = 32514,
	CROSS = 32515,
	UPARROW = 32516,
	SIZENWSE = 32642,
	SIZENESW = 32643,
	SIZEWE = 32644,
	SIZENS = 32645,
	SIZEALL = 32646,
	NO = 32648,
	HAND = 32649,
	APPSTARTING = 32650,
	HELP = 32651,
	PIN = 32671,
	PERSON = 32672
}

---@param type string
function Util.setCursor(type)
	local selectedType = CursorType[type:upper()]
	if selectedType then
		local systemCursor = ffi.C.LoadCursorA(nil, ffi.cast("const char*", selectedType))
		ffi.C.SetCursor(systemCursor)
	end
end

return Util
