local Decoys = {}

local datas = {}
local weak = { __mode = "k", __metatable = false }
setmetatable(datas, weak)

function Decoys.is(table)
  return datas[table] ~= nil
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
  setmetatable(decoy, { __index = index(orig), __newindex = newindex(orig), __metatable = false })
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

function Decoys.commit(decoy)
  local data = datas[decoy]
  if not data then
    return nil
  end

  local orig = data.orig
  for k,v in pairs(data.set_keys) do
    orig[k] = decoy[k]
    data.set_keys[k] = nil
    decoy[k] = nil
  end

  return orig
end

function Decoys.rollback(decoy)
  local data = datas[decoy]
  if not data then
    return nil
  end

  for k,v in pairs(data.set_keys) do
    data.set_keys[k] = nil
    decoy[k] = nil
  end
end

function Decoys.transact(tables, tx)
  local new_decoys = {}
  for i,v in ipairs(tables) do
    new_decoys[i] = Decoys.new(v)
  end

  local res, err = pcall(function() tx(unpack(new_decoys)) end)
  if res then
    for i,v in ipairs(new_decoys) do
      Decoys.commit(new_decoys[i])
    end
  else
    for i,v in ipairs(new_decoys) do
      Decoys.rollback(new_decoys[i])      
    end
  end
  return tables, err
end

return Decoys