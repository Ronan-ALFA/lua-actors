local Decoys = {}

local datas = {}
local weak = { __mode = "k" }
setmetatable(datas, weak)

local function is_decoy(table)
  local mt = getmetatable(table)
  return mt.index == index
end

local function newindex(orig)
  return function(decoy, key, value)
    datas[decoy].set_keys[key] = true
    rawset(decoy, key, value)
  end
end

local function index(orig)
  return function(decoy, key)
    local value = orig[key]
    local niled = datas[decoy].set_keys[key]
    if niled then
      return nil
    elseif type(value) == "table" then
      local decoy_table = Decoys.new(value)
      decoy[key] = decoy_table
      return decoy_table
    end
    return value
  end
end

function Decoys.new(orig)
  local decoy = {}
  setmetatable(decoy, { __index = index(orig), __newindex = newindex(orig) })
  datas[decoy] = { orig = orig, set_keys = {} }

  return decoy
end

function Decoys.original(decoy)
  local data = datas[decoy]
  if data then
    return data.orig
  end
  return nil
end

function Decoys.roll_forward(decoy)
  setmetatable(decoy, {})
  local data = datas[decoy]
  local orig = data.orig
  if not orig then
    return nil
  end

  for k,v in pairs(data.set_keys) do
    orig[k] = decoy[k]
  end

  return orig
end

return Decoys