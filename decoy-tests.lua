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
  it("should know what is a decoy and what isn't", function()
    assert.are.equal(true, decoys.is(decoy))
    assert.are.equal(false, decoys.is({}))
  end)
  it("should roll forward changes", function()
    decoys.commit(decoy)
    assert.are.same(result, orig)
    assert.are.same(result, decoy)
  end)
  it("should continue to function after comitting", function()
    assert.are.equal(true, decoys.is(decoy))
    decoy.d = 3
    assert.are.equal(3, decoy.d)
    assert.are.equal(nil, orig.d)
    decoys.commit(decoy)
    assert.are.equal(3, orig.d)
  end)
end)

describe("Transactions", function()
  local o1 = {}
  local o2 = { a = 1 }
  local r1 = { a = 1 }
  local r2 = { a = 2 }
  it("should commit successfully", function()
    local res = decoys.transact({o1,o2}, function(d1,d2)
      d1.a = 1
      d2.a = 2
    end)
    assert.are.same(o1,r1)
    assert.are.same(o2,r2)
    assert.are.same({o1,o2},res)
  end)
  it("should rollback errors", function()
    local res, err = decoys.transact({o1,o2}, function(d1,d2)
      d1.a = nil
      d2.a = 1
      error("err")
    end)
    assert.are.same(o1,r1)
    assert.are.same(o2,r2)
    assert.are.same({o1,o2},res)
    assert.are.same("decoy-tests.lua:73: err",err)
  end)
end)