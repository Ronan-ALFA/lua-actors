local actors = require "actors"

local actor
local outbox
local function set_msg(state, msg)
  state.msg = msg
end

describe("actors", function()
  it("can be created", function()
    actor = actors.new(set_msg)
  end)
  it("receive messages", function()
    local msg = "Test!"
    actor:send(msg)
    actor:stop()
    -- assert.are.same(actor:wait_death(), { msg = msg })
  end)
end)