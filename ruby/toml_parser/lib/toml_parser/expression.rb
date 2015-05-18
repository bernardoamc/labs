module TomlParser
  class Expression
    attr_reader :name

    def initialize(tokens)
      @name = generate_name(tokens)
      @rule = generate_rule(tokens)
    end

    def match?(line)
      @rule =~ line
    end

    def parse(line)
      line.match(@rule).captures
    end

    private

    def generate_name(tokens)
      tokens.map(&:name).join(' ')
    end

    def generate_rule(tokens)
      rule = tokens.map do |token|
        "(#{token.rule})"
      end.join(' ')

      /\A#{rule}\s*\Z/
    end
  end
end
