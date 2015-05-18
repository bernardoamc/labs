module TomlParser
  class Parser
    def initialize(file_path, tokenizer, grammar)
      @file_path = file_path
      @tokenizer = tokenizer
      @grammar = grammar
      @tokens = []
    end

    def parse
      tokenize_input.each do |tokens, line|
        # Pensar em como criar a gramatica.
        # Acho que vou criar regras e falar o que pode vir depois de cada uma
        # e empilhar o contexto.
      end
    end

    private

    def tokenize_input
      File.open(@file_path, "r") do |f|
        f.each_line do |line|
          @tokens << [@tokenizer.tokenize(line), line]
        end
      end
    end
  end
end
