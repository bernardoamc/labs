
# line 1 "lexer.rl"
# Simple example of a Lexer built using Ragel
# Run this with: ragel -R lexer.rl
# Test with: run_lexer("test = -100")

# Regions outside of '%%{ }%%' blocks and lines that do not start with '%%'
# are assumed to be written in the host language.

# Ragel state machines are defined inside blocks demarcated with '%%{ }%%'

# line 42 "lexer.rl"


# Telling Ragel that the state machine should be compiled in this file using the 'write data' directive

# line 18 "lexer.rb"
class << self
	attr_accessor :_simple_lexer_actions
	private :_simple_lexer_actions, :_simple_lexer_actions=
end
self._simple_lexer_actions = [
	0, 1, 0, 1, 1, 1, 2, 1,
	3, 1, 4, 1, 5, 1, 6, 1,
	7, 1, 8
]

class << self
	attr_accessor :_simple_lexer_key_offsets
	private :_simple_lexer_key_offsets, :_simple_lexer_key_offsets=
end
self._simple_lexer_key_offsets = [
	0, 0, 2, 4, 9, 21, 24, 26
]

class << self
	attr_accessor :_simple_lexer_trans_keys
	private :_simple_lexer_trans_keys, :_simple_lexer_trans_keys=
end
self._simple_lexer_trans_keys = [
	48, 57, 48, 57, 95, 65, 90, 97,
	122, 32, 43, 45, 61, 9, 13, 48,
	57, 65, 90, 97, 122, 46, 48, 57,
	48, 57, 95, 65, 90, 97, 122, 0
]

class << self
	attr_accessor :_simple_lexer_single_lengths
	private :_simple_lexer_single_lengths, :_simple_lexer_single_lengths=
end
self._simple_lexer_single_lengths = [
	0, 0, 0, 1, 4, 1, 0, 1
]

class << self
	attr_accessor :_simple_lexer_range_lengths
	private :_simple_lexer_range_lengths, :_simple_lexer_range_lengths=
end
self._simple_lexer_range_lengths = [
	0, 1, 1, 2, 4, 1, 1, 2
]

class << self
	attr_accessor :_simple_lexer_index_offsets
	private :_simple_lexer_index_offsets, :_simple_lexer_index_offsets=
end
self._simple_lexer_index_offsets = [
	0, 0, 2, 4, 8, 17, 20, 22
]

class << self
	attr_accessor :_simple_lexer_trans_targs
	private :_simple_lexer_trans_targs, :_simple_lexer_trans_targs=
end
self._simple_lexer_trans_targs = [
	5, 0, 6, 4, 7, 7, 7, 0,
	4, 1, 1, 4, 4, 5, 3, 3,
	0, 2, 5, 4, 6, 4, 7, 7,
	7, 4, 4, 4, 4, 4, 0
]

class << self
	attr_accessor :_simple_lexer_trans_actions
	private :_simple_lexer_trans_actions, :_simple_lexer_trans_actions=
end
self._simple_lexer_trans_actions = [
	5, 0, 0, 17, 0, 0, 0, 0,
	9, 0, 0, 7, 9, 5, 0, 0,
	0, 0, 5, 11, 0, 13, 0, 0,
	0, 15, 17, 11, 13, 15, 0
]

class << self
	attr_accessor :_simple_lexer_to_state_actions
	private :_simple_lexer_to_state_actions, :_simple_lexer_to_state_actions=
end
self._simple_lexer_to_state_actions = [
	0, 0, 0, 0, 1, 0, 0, 0
]

class << self
	attr_accessor :_simple_lexer_from_state_actions
	private :_simple_lexer_from_state_actions, :_simple_lexer_from_state_actions=
end
self._simple_lexer_from_state_actions = [
	0, 0, 0, 0, 3, 0, 0, 0
]

class << self
	attr_accessor :_simple_lexer_eof_trans
	private :_simple_lexer_eof_trans, :_simple_lexer_eof_trans=
end
self._simple_lexer_eof_trans = [
	0, 0, 27, 0, 0, 28, 29, 30
]

class << self
	attr_accessor :simple_lexer_start
end
self.simple_lexer_start = 4;
class << self
	attr_accessor :simple_lexer_first_final
end
self.simple_lexer_first_final = 4;
class << self
	attr_accessor :simple_lexer_error
end
self.simple_lexer_error = 0;

class << self
	attr_accessor :simple_lexer_en_main
end
self.simple_lexer_en_main = 4;


# line 46 "lexer.rl"

def emit(token_name, data, target_array, ts, te)
  target_array << {:name => token_name.to_sym, :value => data[ts...te].pack("c*") }
end

def run_lexer(data)
  data = data.unpack("c*") if(data.is_a?(String))
  eof = data.length
  token_array = []


# line 149 "lexer.rb"
begin
	p ||= 0
	pe ||= data.length
	cs = simple_lexer_start
	ts = nil
	te = nil
	act = 0
end

# line 57 "lexer.rl"

# line 161 "lexer.rb"
begin
	_klen, _trans, _keys, _acts, _nacts = nil
	_goto_level = 0
	_resume = 10
	_eof_trans = 15
	_again = 20
	_test_eof = 30
	_out = 40
	while true
	_trigger_goto = false
	if _goto_level <= 0
	if p == pe
		_goto_level = _test_eof
		next
	end
	if cs == 0
		_goto_level = _out
		next
	end
	end
	if _goto_level <= _resume
	_acts = _simple_lexer_from_state_actions[cs]
	_nacts = _simple_lexer_actions[_acts]
	_acts += 1
	while _nacts > 0
		_nacts -= 1
		_acts += 1
		case _simple_lexer_actions[_acts - 1]
			when 1 then
# line 1 "NONE"
		begin
ts = p
		end
# line 195 "lexer.rb"
		end # from state action switch
	end
	if _trigger_goto
		next
	end
	_keys = _simple_lexer_key_offsets[cs]
	_trans = _simple_lexer_index_offsets[cs]
	_klen = _simple_lexer_single_lengths[cs]
	_break_match = false

	begin
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + _klen - 1

	     loop do
	        break if _upper < _lower
	        _mid = _lower + ( (_upper - _lower) >> 1 )

	        if data[p].ord < _simple_lexer_trans_keys[_mid]
	           _upper = _mid - 1
	        elsif data[p].ord > _simple_lexer_trans_keys[_mid]
	           _lower = _mid + 1
	        else
	           _trans += (_mid - _keys)
	           _break_match = true
	           break
	        end
	     end # loop
	     break if _break_match
	     _keys += _klen
	     _trans += _klen
	  end
	  _klen = _simple_lexer_range_lengths[cs]
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + (_klen << 1) - 2
	     loop do
	        break if _upper < _lower
	        _mid = _lower + (((_upper-_lower) >> 1) & ~1)
	        if data[p].ord < _simple_lexer_trans_keys[_mid]
	          _upper = _mid - 2
	        elsif data[p].ord > _simple_lexer_trans_keys[_mid+1]
	          _lower = _mid + 2
	        else
	          _trans += ((_mid - _keys) >> 1)
	          _break_match = true
	          break
	        end
	     end # loop
	     break if _break_match
	     _trans += _klen
	  end
	end while false
	end
	if _goto_level <= _eof_trans
	cs = _simple_lexer_trans_targs[_trans]
	if _simple_lexer_trans_actions[_trans] != 0
		_acts = _simple_lexer_trans_actions[_trans]
		_nacts = _simple_lexer_actions[_acts]
		_acts += 1
		while _nacts > 0
			_nacts -= 1
			_acts += 1
			case _simple_lexer_actions[_acts - 1]
when 2 then
# line 1 "NONE"
		begin
te = p+1
		end
when 3 then
# line 29 "lexer.rl"
		begin
te = p+1
 begin
      emit(:assignment_operator, data, token_array, ts, te)
     end
		end
when 4 then
# line 38 "lexer.rl"
		begin
te = p+1
		end
when 5 then
# line 21 "lexer.rl"
		begin
te = p
p = p - 1; begin
      emit(:integer_literal, data, token_array, ts, te)
     end
		end
when 6 then
# line 25 "lexer.rl"
		begin
te = p
p = p - 1; begin
      emit(:float_literal, data, token_array, ts, te)
     end
		end
when 7 then
# line 33 "lexer.rl"
		begin
te = p
p = p - 1; begin
      emit(:identifier, data, token_array, ts, te)
     end
		end
when 8 then
# line 21 "lexer.rl"
		begin
 begin p = ((te))-1; end
 begin
      emit(:integer_literal, data, token_array, ts, te)
     end
		end
# line 311 "lexer.rb"
			end # action switch
		end
	end
	if _trigger_goto
		next
	end
	end
	if _goto_level <= _again
	_acts = _simple_lexer_to_state_actions[cs]
	_nacts = _simple_lexer_actions[_acts]
	_acts += 1
	while _nacts > 0
		_nacts -= 1
		_acts += 1
		case _simple_lexer_actions[_acts - 1]
when 0 then
# line 1 "NONE"
		begin
ts = nil;		end
# line 331 "lexer.rb"
		end # to state action switch
	end
	if _trigger_goto
		next
	end
	if cs == 0
		_goto_level = _out
		next
	end
	p += 1
	if p != pe
		_goto_level = _resume
		next
	end
	end
	if _goto_level <= _test_eof
	if p == eof
	if _simple_lexer_eof_trans[cs] > 0
		_trans = _simple_lexer_eof_trans[cs] - 1;
		_goto_level = _eof_trans
		next;
	end
end
	end
	if _goto_level <= _out
		break
	end
	end
	end

# line 58 "lexer.rl"

  puts token_array.inspect
end

run_lexer("test = -100")
