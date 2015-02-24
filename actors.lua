local lanes = require "lanes".configure()
local luaproc = require "luaproc"

local actors = {
  mt = {}
}

actors.timeout = 5

local STOP = -1

function actors.mt.send(to, msg_type, ...)
  luaproc.send(to.channel, msg_type, arg)
end

function actors.mt.stop(to)
  to:send(STOP)
end

local function process(channel_name, receive, state)
  while true do
    local msg = luaproc.receive(channel_name)
    if msg == nil or msg == STOP then
      break
    else
      receive(state, msg)
    end
  end
end

function actors.new(receive, state)
  state = state or {}
  local proc, err = luaproc.newproc()
  local chan, err = luaproc.newchannel(tostring("actor-" .. proc))

  local actor = { channel = chan, proc = proc }
  setmetatable(actor, { __index = actors.mt })

  return actor
end

return actors