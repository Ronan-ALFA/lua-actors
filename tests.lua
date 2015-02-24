local actors = require "actors"

local actor
local outbox
local function set_outbox(state, msg)
  outbox = msg.body
end

describe("actors", function()
  it("can be created", function()
    actor = actors.new(set_outbox)
  end)
  it("receive messages", function()
    local msg = "Test!"
    -- actor:send({ body = msg })
    -- actor:stop()
    assert.are.equal(outbox, msg)
  end)
end)