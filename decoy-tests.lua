local decoys = require "decoys"

describe("decoys",function()
  local orig_copy = { a = 1, b = 2, cc = 2, strings = { a = "one", aa = "one" } }
  local orig =      { a = 1, b = 2, cc = 2, strings = { a = "one", aa = "one"  } }
  local decoy
  local rollback
  local result =    { a = 0, b = 1, c = 2,  strings = { a = "zero", b = "one" }, hex = { a = 0x00 } }
  it("should decoy existing tables", function()
    decoy = decoys.new(orig)
    assert.are.same(orig, decoy)
  end)
  it("should not be the same table as their originals", function()
    assert.are_not.equal(orig, decoy)
  end)
  it("should change values", function()
    decoy.a = nil
    decoy.a = 0
    decoy.b = 1
    decoy.c = 2
    decoy.cc = 22
    decoy.cc = nil
    decoy.strings.a = "zero"
    decoy.strings.b = "one"
    decoy.strings.aa = nil
    decoy.hex = { a = 0x00 }
    assert.are.same(decoy, result)
  end)
  it("should not modify the original table", function()
    rollback = decoys.original(decoy)
    assert.are.equal(orig, rollback)
    assert.are.same(orig, orig_copy)

    assert.are.equal(decoys.original({}),nil)
  end)
  it("should roll forward changes", function()
    decoys.roll_forward(decoy)
    assert.are.same(result, orig)
    assert.are.same(result, decoy)
  end)
end)