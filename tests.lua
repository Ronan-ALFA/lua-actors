local actors = require "actors"

local system
describe("actor systems", function()
  it("can be created", function()
    -- This creates an actor system with two threads.
    system = actors.system(2)
  end)
end)

local actor1, actor2
local outbox
describe("actors", function()
  it("can be created", function()
    -- This creates a new actor with the following receive function.
    local function counter(state, body, from)
      state.count = (state.count or 0) + 1
      from:tell(state.count)
    end
    -- The actor is randomly assigned to one of the system's threads.
    actor1 = system.new(counter)
    actor2 = system.new(counter)
  end)
  it("receive messages", function()
    local msg = "Test!"
    actor1:tell(msg)
    assert.are.same(actor1:ask(msg,1), 1)
  end)
end)