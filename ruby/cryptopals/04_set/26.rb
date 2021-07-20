require_relative '../helpers'
require 'openssl'

KEY = 16.times.map { rand(0..255) }
NONCE = 72

puts "Key: #{KEY.inspect}"

def encode_cookie(input)
  prefix = 'comment1=cooking%20MCs;userdata='
  suffix = ';comment2=%20like%20a%20pound%20of%20bacon'
  plaintext = prefix + input.tr(';=', '') + suffix
  puts plaintext[32]
  puts plaintext[38]
  puts plaintext[43]
  puts plaintext[45]
  aes_ctr_encrypt(plaintext.bytes, KEY, NONCE)
end

def decode_cookie(ciphertext)
  plaintext = aes_ctr_decrypt(ciphertext, KEY, NONCE).pack('C*')
  puts "Decoded string: #{plaintext}"
  config = plaintext.split(';').map { |kv| kv.split('=') }.to_h
  puts "Decoded data: #{config}"
  puts "Admin detected: #{config['admin'] == 'true'}"
end

input = 'AAAAAAAAAAAAAAAA:admin<true:A<AA'
ciphertext = encode_cookie(input)
block_offset = 48
ciphertext[block_offset] ^= 1
ciphertext[block_offset + 6] ^= 1
ciphertext[block_offset + 11] ^= 1
ciphertext[block_offset + 13] ^= 1
decode_cookie(ciphertext)
