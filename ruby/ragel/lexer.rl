# Simple example of a Lexer built using Ragel
# Run this with: ragel -R lexer.rl
# Test with: run_lexer("test = -100")

# Regions outside of '%%{ }%%' blocks and lines that do not start with '%%'
# are assumed to be written in the host language.

# Ragel state machines are defined inside blocks demarcated with '%%{ }%%'
%%{

  # Defining a blank state machine called 'test_lexer'
  machine simple_lexer;

  integer     = ('+'|'-')?[0-9]+;
  float       = ('+'|'-')?[0-9]+'.'[0-9]+;
  assignment  = '=';
  identifier  = [a-zA-Z][a-zA-Z_]+;

  main := |*

    integer => {
      emit(:integer_literal, data, token_array, ts, te)
    };

    float => {
      emit(:float_literal, data, token_array, ts, te)
    };

    assignment => {
      emit(:assignment_operator, data, token_array, ts, te)
    };

    identifier => {
      emit(:identifier, data, token_array, ts, te)
    };

    # Define it to say that whitespace is valid in our target grammar.
    space;

  *|;

}%%

# Telling Ragel that the state machine should be compiled in this file using the 'write data' directive
%% write data;

def emit(token_name, data, target_array, ts, te)
  target_array << {:name => token_name.to_sym, :value => data[ts...te].pack("c*") }
end

def run_lexer(data)
  data = data.unpack("c*") if(data.is_a?(String))
  eof = data.length
  token_array = []

  %% write init;
  %% write exec;

  puts token_array.inspect
end
