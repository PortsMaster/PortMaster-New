----------------------------------------------
-- Pickle.lua
-- An table serialization utility for lua 5
-- Steve Dekorte, http://www.dekorte.com, April 2000
-- Public Domain
-- Lua 5.0 update by Daan Nusman July 2003
----------------------------------------------

function pickle(t)
  return Pickle:clone():pickle_(t)
end

Pickle = {
  clone = function (t) local nt={}; for i, v in pairs(t) do nt[i]=v end return nt end
}

function Pickle:pickle_(root)
  if type(root) ~= "table" then 
    error("can only pickle tables, not ".. type(root).."s")
  end
  self._tableToRef = {}
  self._refToTable = {}
  local savecount = 0
  self:ref_(root)
  local s = {"{"}

  while table.getn(self._refToTable) > savecount do
    savecount = savecount + 1
    local t = self._refToTable[savecount]
    table.insert(s, "{\n")
    for i, v in pairs(t) do
        if type(v) ~= "function" then
            table.insert(s, "[")
            table.insert(s, self:value_(i))
            table.insert(s, "]=")
            table.insert(s, self:value_(v))
            table.insert(s, ",\n")
        end
    end
    table.insert(s, "},\n")
  end

  table.insert(s, "}")
  return table.concat(s)
end

function Pickle:value_(v)
  local vtype = type(v)
  if     vtype == "string" then return string.format("%q", v)
  elseif vtype == "number" then return v
  elseif vtype == "boolean" then return tostring(v)
  elseif vtype == "table" then return "{"..self:ref_(v).."}"
  else error("pickle a "..type(v).." is not supported")
  end
end

function Pickle:ref_(t)
  local ref = self._tableToRef[t]
  if not ref then 
    if t == self then error("can't pickle the pickle class") end
    table.insert(self._refToTable, t)
    ref = table.getn(self._refToTable)
    self._tableToRef[t] = ref
  end
  return ref
end

----------------------------------------------
-- unpickle
----------------------------------------------

function unpickle_string(s)
  if type(s) ~= "string" then
    error("can't unpickle a "..type(s)..", only strings")
  end
  local tables = loadstring("return "..s)()
  return unpickle_table(tables)
end
  
function unpickle_table(tables)
  if type(tables) ~= "table" then
    error("can't unpickle a "..type(tables)..", only tables")
  end
  for tnum = 1, table.getn(tables) do
    local t = tables[tnum]
    local tcopy = {}; for i, v in pairs(t) do tcopy[i] = v end
    for i, v in pairs(tcopy) do
      local ni, nv
      if type(i) == "table" then ni = tables[i[1]] else ni = i end
      if type(v) == "table" then nv = tables[v[1]] else nv = v end
      t[ni] = nv
    end
  end
  return tables[1]
end
