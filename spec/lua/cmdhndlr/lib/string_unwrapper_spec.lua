local StringUnwrapper = require("cmdhndlr.lib.string_unwrapper").StringUnwrapper

describe("StringUnwrapper", function()

  for _, c in ipairs({
    {str = "'hoge'", expected = "hoge"},
    {str = "\"hoge\"", expected = "hoge"},
    {str = "[[hoge]]", expected = "hoge"},
    {str = "[==[hoge]==]", expected = "hoge"},
  }) do
    it(("for_lua():unwrap('%s') == %s"):format(c.str, c.expected), function()
      local actual = StringUnwrapper.for_lua():unwrap(c.str)
      assert.equals(c.expected, actual)
    end)
  end

  for _, c in ipairs({
    {str = "'hoge'", expected = "hoge"},
    {str = "\"hoge\"", expected = "hoge"},
    {str = "`hoge`", expected = "hoge"},
  }) do
    it(("for_go():unwrap('%s') == %s"):format(c.str, c.expected), function()
      local actual = StringUnwrapper.for_go():unwrap(c.str)
      assert.equals(c.expected, actual)
    end)
  end

end)
