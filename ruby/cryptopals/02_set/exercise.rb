require_relative '../helpers'
require 'openssl'

BLOCK_SIZE = 16
KEY = BLOCK_SIZE.times.map { rand(0..255) }
IV = BLOCK_SIZE.times.map { rand(0..255) }
PLAINTEXT = 'name=cbc attack;admin<true:id=11'.bytes

ciphertext = aes_cbc_encrypt(PLAINTEXT, KEY, IV)
ciphertext[5] ^= 1  # 6th byte of our first block
ciphertext[10] ^= 1 # 11th byte of our first block

puts aes_cbc_decrypt(ciphertext, KEY, IV).pack('C*')
