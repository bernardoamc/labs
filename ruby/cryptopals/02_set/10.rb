require_relative '../helpers'
require 'openssl'

buffer = base64_decode(File.read('10.txt').strip)
iv = Array.new(16, 0)
KEY = "YELLOW SUBMARINE".unpack('C*')

# Making sure the logic is sound by encrypting and decrypting and making sure
# we have the original value.
puts buffer == aes_cbc_decrypt(aes_cbc_encrypt(buffer, KEY, iv), KEY, iv)

puts aes_cbc_decrypt(buffer, KEY, iv).pack('C*')
