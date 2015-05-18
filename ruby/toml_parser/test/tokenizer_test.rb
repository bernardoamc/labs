require_relative 'helper'

class TestTomlParserTokenizer < Minitest::Test
  def setup
    # Tokens
    word = ::TomlParser::Token.new('[word]', '\w+')
    blank_line = TomlParser::Token.new('[blank_line]', '\s*')
    key = TomlParser::Token.new('[key]', '\s*\[\w+\]\s*')
    assigment = TomlParser::Token.new('[assigment]', '=')
    string = TomlParser::Token.new('[string]', '".*"')
    boolean = TomlParser::Token.new('[boolean]', 'true|false')
    number = TomlParser::Token.new('[number]', '[1-9]\d*(\.\d+)?')

    # Expressions
    key_exp = TomlParser::Expression.new([key])
    assigment_string_exp = TomlParser::Expression.new([word, assigment, string])
    assigment_boolean_exp = TomlParser::Expression.new([word, assigment, boolean])
    assigment_number_exp = TomlParser::Expression.new([word, assigment, number])
    blank_line_exp = TomlParser::Expression.new([blank_line])
    word_exp = TomlParser::Expression.new([word])

    @tokenizer = TomlParser::Tokenizer.new('test/tokenizer.txt', [
      key_exp,
      assigment_string_exp,
      assigment_boolean_exp,
      assigment_number_exp,
      blank_line_exp
    ])
  end

  def test_parse_returns_content
    expected_output = [
      "[word] [assigment] [string]",
      "[blank_line]",
      "[key]",
      "[word] [assigment] [string]",
      "[blank_line]",
      "[key]",
      "[word] [assigment] [number]",
      "[word] [assigment] [boolean]"
    ]

    assert_equal expected_output, @tokenizer.tokenize
  end
end
