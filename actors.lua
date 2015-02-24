local actors = { mt = {} }
local lanes = require "lanes".configure()

local ACTOR_MESSAGE = true
local STOP = -1
local GET_STATE = -2

local sender = nil

function actors.mt.send(to, body)
  to.linda:send(ACTOR_MESSAGE, { body = body, from = sender })
end

function actors.mt.stop(to)
  to:send(STOP)
end

function actors.mt.get_state(from)
  to:send(GET_STATE)
end

local function process(self, linda, receive, state)
  sender = sender or self
  while true do
    local key, msg = linda:receive(ACTOR_MESSAGE, 5)    
    if msg == nil or msg == STOP then
      break
    elseif msg == GET_STATE then
      local sender = msg.sender
      if sender ~= nil then
        sender:send(state)
      else
        -- Somehow return state to the 'main' lane?
      end
    else
      receive(state, msg)
    end
  end
  return state
end

function actors.new(receive, state)
  state = state or {}
  local linda = lanes.linda()
  local lane = lanes.gen("*", process)

  local actor = {}
  setmetatable(actor, { __index = actors.mt })
  
  actor.linda = linda
  lane(actor, linda, receive, state)

  return actor
end

return actors