=begin
  Single-byte XOR cipher

  The hex encoded string:

  1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736

  ... has been XOR'd against a single character. Find the key, decrypt the message.

  You can do this by hand. But don't: write code to do it for you.

  How? Devise some method for "scoring" a piece of English plaintext. Character frequency is a good metric. Evaluate each output and choose the one with the best score.
=end

require_relative '../helpers'

xored_hex = '1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736'
xored_hex_bytes = hex_decode(xored_hex)
max_score = 0
answer = ''

(0..255).each do |c|
  result = xor_bytes_against_byte(xored_hex_bytes, c).pack('C*')
  score = english_score(result)

  if score > max_score
    max_score = score
    answer = result
  end
end

puts answer
