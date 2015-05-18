module TomlParser
  class Token
    attr_reader :name, :rule

    def initialize(name, rule)
      @name = name
      @rule = rule
    end
  end
end
