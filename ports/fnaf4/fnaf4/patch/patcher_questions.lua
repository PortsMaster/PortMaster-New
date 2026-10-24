
local gd = os.getenv("GAMEDIR") or "."

local function has(name)
  local f = io.open(gd .. "/gamedata/" .. name, "rb")
  if f then f:close() return true end
  return false
end

local std = has("FiveNightsatFreddys4.exe") and not has(".patched_std")
local he  = has("FiveNightsatFreddys4 HalloweenEdition.exe") and not has(".patched_he")

if not std and not he then std, he = true, true end

local options = {}
if std then options[#options + 1] = { "std", "Five Nights at Freddy's 4" } end
if he  then options[#options + 1] = { "he",  "Five Nights at Freddy's 4 Halloween Edition" } end
if std and he then options[#options + 1] = { "both", "Both (May take several hours)" } end

return {
  { id = "FNAF4_VERSION",
    question = "Which version of FNaF would you like to patch?",
    options = options },
}
