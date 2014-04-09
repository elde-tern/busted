-- supporting testfile; belongs to 'cl_spec.lua'

describe("Tests the busted command-line options", function()

  describe("test body", function()
    it("a test", function()
      error("test should not execute")
    end)
  end)

  describe("setup", function()
    local setup_run = false
    local nested_setup_run = false
    describe("context with setup", function()
      setup(function()
        setup_run = true
      end)
      it("a test", function() end)
    end)
    describe("nested context with setup", function()
      setup(function()
        nested_setup_run = true
      end)
      describe("layer", function()
        it("a nested test", function() end)
      end)
    end)
    describe("examine", function()
      it("setup skipped", function()
        if setup_run then
          error("setup should be skipped")
        end
      end)
      it("nested setup skipped", function()
        if nested_setup_run then
          error("nested setup should be skipped")
        end
      end)
    end)
  end)

  describe("teardown", function()
    local teardown_run = false
    local nested_teardown_run = false
    describe("context with teardown", function()
      teardown(function()
        teardown_run = true
      end)
      it("a test", function() end)
    end)
    describe("nested context with teardown", function()
      teardown(function()
        nested_teardown_run = true
      end)
      describe("layer", function()
        it("a nested test", function() end)
      end)
    end)
    describe("examine", function()
      it("teardown skipped", function()
        if teardown_run then
          error("teardown should be skipped")
        end
      end)
      it("nested teardown skipped", function()
        if nested_teardown_run then
          error("nested teardown should be skipped")
        end
      end)
    end)
  end)

  describe("before_each", function()
    local before_each_run = false
    local nested_before_each_run = false
    describe("context with before_each", function()
      before_each(function()
        before_each_run = true
      end)
      it("a test", function() end)
    end)
    describe("nested context with before_each", function()
      before_each(function()
        nested_before_each_run = true
      end)
      describe("layer", function()
        it("a nested test", function() end)
      end)
    end)
    describe("examine", function()
      it("before_each skipped", function()
        if before_each_run then
          error("before_each should be skipped")
        end
      end)
      it("nested before_each skipped", function()
        if nested_before_each_run then
          error("nested before_each should be skipped")
        end
      end)
    end)
  end)

  describe("after_each", function()
    local after_each_run = false
    local nested_after_each_run = false
    describe("context with after_each", function()
      after_each(function()
        after_each_run = true
      end)
      it("a test", function() end)
    end)
    describe("nested context with after_each", function()
      after_each(function()
        nested_after_each_run = true
      end)
      describe("layer", function()
        it("a nested test", function() end)
      end)
    end)
    describe("examine", function()
      it("after_each skipped", function()
        if after_each_run then
          error("after_each should be skipped")
        end
      end)
      it("nested after_each skipped", function()
        if nested_after_each_run then
          error("nested after_each should be skipped")
        end
      end)
    end)
  end)

end)
