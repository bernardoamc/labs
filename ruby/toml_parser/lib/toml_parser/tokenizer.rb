module TomlParser
  class Tokenizer
    def initialize(expressions)
      @expressions = expressions
    end

    def tokenize(input)
      @expressions.each do |expression|
        return expression.name if expression.match?(line)
      end

      '[not_identified]'
    end
  end
end
