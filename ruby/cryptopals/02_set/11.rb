require_relative '../helpers'
require 'openssl'

# This function is responsible for:
#   1. Generating a prefix padding of length in between 5 and 10, inclusive.
#   1. Generating a suffix padding of length in between 5 and 10, inclusive.
#   2. Prepending and appending the paddings to the buffer.
#   3. Generate a random key
#   4. Encrypts it under AES_CBC or AES_ECB depending of the value of a random number
def encryption_oracle(buffer)
  prefix_padding = rand(5..10).times.map { rand(0..255) }
  suffix_padding = rand(5..10).times.map { rand(0..255) }
  padded_buffer = pkcs7_pad(prefix_padding + buffer + suffix_padding, 16)
  key = 16.times.map { rand(0..255) }

  if rand(2).zero?
    puts 'Encrypting with ECB...'
    aes_ecb_encrypt(padded_buffer, key)
  else
    puts 'Encrypting with CBC...'
    iv = 16.times.map { rand(0..255) }
    aes_cbc_encrypt(padded_buffer, key, iv)
  end
end

encoded = encryption_oracle(Array.new(50, 'A'.ord))
puts "Encoded: #{encoded.pack('C*')}"

## Idea to identify which block mode is being used.
# 1. We know that AES_ECB is deterministic as-in, given an input and a key
#    we will always end up with the same cyphertext any time we encrypt
#    our plaintext.
# 2. Given that, we can calculate the hamming distance between blocks and see
#    if we find two repeated blocks, if we do we KNOW that the block mode is
#    AES instead of CBC.

blocks = encoded.each_slice(16).to_a

if blocks.uniq.size != blocks.size
  puts "Found duplicates, it's AES ECB"
else
  puts "No duplicates found , AES CBC"
end


