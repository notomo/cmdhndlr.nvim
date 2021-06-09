local TableJoiner = require("cmdhndlr.lib.table_joiner").TableJoiner

describe("TableJoiner", function()

  it("adds if id does not match with last", function()
    local joiner = TableJoiner.new()
    joiner:add({{id = 1}})

    local holders = {{id = 2}, {id = 3}}
    joiner:add(holders)

    assert.same(holders, joiner:last())
  end)

  it("joins if id matches with last", function()
    local joiner = TableJoiner.new()
    joiner:add({{id = 1}})

    local holders = {{id = 1}, {id = 2}, {id = 3}}
    joiner:add(holders)

    assert.same(holders, joiner:last())
  end)

end)
