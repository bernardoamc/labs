class Minetest
  class << self
    def inherited(subclass)
      subclass.instance_variable_set(:@tests, {})
    end

    def test(description, &block)
      @tests[description] = block
    end

    def run
      @tests.keys.shuffle.each do |key|
        TestCase.new(key, @tests[key]).run
      end
    end
  end
end

class TestCase
  def initialize(&block)
    self.instance_eval(&block)
  end
end
