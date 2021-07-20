require_relative '../helpers'
require 'openssl'

class InvalidFormat < StandardError; end

KEY = 16.times.map { rand(0..255) }
puts "Key: #{KEY.inspect}"

def encode_cookie(input)
  prefix = 'comment1=cooking%20MCs;userdata='
  suffix = ';comment2=%20like%20a%20pound%20of%20bacon'
  plaintext = prefix + input.tr(';=', '') + suffix
  raise InvalidFormat.new(plaintext) unless plaintext.ascii_only?
  aes_cbc_encrypt(pkcs7_pad(plaintext.bytes, 16), KEY, KEY)
end

def decode_cookie(ciphertext)
  plaintext = pkcs7_unpad(
    aes_cbc_decrypt(ciphertext, KEY, KEY)
  ).pack('C*')

  raise InvalidFormat.new(plaintext) unless plaintext.ascii_only?
  config = plaintext.split(';').map { |kv| kv.split('=') }.to_h
  puts "Decoded data: #{config}"
  puts "Admin detected: #{config['admin'] == 'true'}"
end

def exploit_server(input)
  cookie = encode_cookie(input)
  16.times { |i| cookie[16 + i] = 0 }
  16.times { |i| cookie[32 + i] = cookie[i] }

  begin
    decode_cookie(cookie)
  rescue InvalidFormat => e
    puts "Invalid message!"
    e.message
  end
end

# This attack can only happen if two conditions are fulfilled:
# 1. The server uses the KEY as the IV
# 2. The server raises an error surfacing the decoded message
#
# Given the two conditions above we can exploit this in the following way:
# 1. Make a plaintext with at least 3 blocks with the same contents
# 2. Encrypt the plaintext to get the ciphertext
# 3. Modify the second block of the ciphertext to contain only zeros
# 4. Decode the ciphertext and get the invalid plaintext result
# 5. XOR(block[0], block[2])
# 6. That's your key!
#
# The reason this works is because the first block is computed like:
#   AES(ciphertext, KEY) XOR KEY
#
# It's the KEY in this case because we used it also as the IV. :)
#
# The third block is computed like:
#   AES(ciphertext, KEY) XOR ciphertext_block[1]
#
# So when we do:
#   (AES(ciphertext, KEY) XOR KEY) XOR (AES(ciphertext, KEY) XOR block[1])
#   AES(ciphertext XOR AES(ciphertext, KEY) becomes ZERO
# So we end up with:
#   KEY XOR ciphertext_block[1]
# But remember that we made block[1] be all zeros!
#   KEY XOR 0 => KEY

input = 'A' * (16 * 3)
result = exploit_server(input)
blocks = result.bytes.each_slice(16).to_a

puts 'Key found:'
puts xor_bytes(blocks[0], blocks[2]).inspect
