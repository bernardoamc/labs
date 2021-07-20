require_relative '../helpers'
require 'openssl'

input = base64_decode(
  'L77na/nrFsKvynd6HzOoG7GHTLXsTVu9qvY/2syLXzhPweyyMTJULu/6/kXX0KSvoOLSFQ=='
)
key = 'YELLOW SUBMARINE'.unpack('C*')
nonce = 0

puts(aes_ctr_decrypt(input, key, nonce).pack('C*'))
puts(
  "Success: #{aes_ctr_encrypt(aes_ctr_decrypt(input, key, nonce), key, nonce) == input}"
)
