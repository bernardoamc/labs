=begin

  Fixed XOR

  Write a function that takes two equal-length buffers and produces their XOR combination.

  If your function works properly, then when you feed it the string:

  1c0111001f010100061a024b53535009181c

  ... after hex decoding, and when XOR'd against:

  686974207468652062756c6c277320657965

  ... should produce:

  746865206b696420646f6e277420706c6179

=end

require_relative '../helpers'

class HexRaw
  def initialize(str)
    @str = str
  end

  def to_bytes
    [@str].pack('H*').bytes
  end

end

hex = '1c0111001f010100061a024b53535009181c'
hex_bytes = hex_decode(hex)

xor_against = '686974207468652062756c6c277320657965'
xor_against_bytes = hex_decode(xor_against)

xored = xor_bytes(hex_bytes, xor_against_bytes)
xored_hex_encoded = hex_encode(xored)
expected = '746865206b696420646f6e277420706c6179'
puts expected == xored_hex_encoded
