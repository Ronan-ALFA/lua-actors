local actors = { mt = {} }
local lanes = require "lanes".configure()
local actor_mt = { __index = mt }
local MESSAGE_KEY = true
local ADD_ACTOR_KEY = false
local lindas = {}
local acting

local top_level_actor = { id = 0, linda = lanes.linda() }
setmetatable(top_level_actor, { __index = actors.mt })

function actors.mt.tell(to, msg)
  to.linda:send(MESSAGE_KEY, { body = msg, to = to.id, from = acting or top_level_actor })
end

function actors.mt.ask(to, msg, timeout)
  local from = acting or top_level_actor
  to:tell(msg)
  local key, reply = top_level_actor.linda:receive(timeout, MESSAGE_KEY)
  if reply then
    return reply.body
  end
  return nil
end

function actors.system(num_threads, libs)
  local system = {}
  local num_actors = 0
  local actor_lanes = {}

  local function process(linda)
    local actor_states = {}
    while true do
      key, msg = linda:receive(50, ADD_ACTOR_KEY, MESSAGE_KEY)
      if key == ADD_ACTOR_KEY then
        actor_states[msg.id] = { state = msg.state, receive = msg.receive }
      elseif key == MESSAGE_KEY then
        local dest = actor_states[msg.to]        
        if dest ~= nil then
          acting = dest
          dest.receive(dest.state, msg.body, msg.from)
          acting = nil
        end
      end
    end
  end

  function system.new(receive, state)
    num_actors = num_actors + 1
    local linda = lindas[math.random(#lindas)]
    local actor = {
      id = num_actors,
      linda = linda
    }
    linda:send(ADD_ACTOR_KEY, { id = num_actors, state = state or {}, receive = receive })
    setmetatable(actor, { __index = actors.mt })
    return actor
  end

  libs = libs or "*"

  for i = 1, num_threads do
    actor_lanes[i] = lanes.gen(libs, process)
    local linda = lanes.linda()
    lindas[i] = linda
    actor_lanes[i](linda)
  end

  return system
end

return actors