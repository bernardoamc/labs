=begin
Goal: "Given the iv, ciphertext, and a padding oracle, finds and returns the plaintext."
=end

require_relative '../helpers'
require 'openssl'

UNKNOWN_STRINGS = [
  'MDAwMDAwTm93IHRoYXQgdGhlIHBhcnR5IGlzIGp1bXBpbmc=',
  'MDAwMDAxV2l0aCB0aGUgYmFzcyBraWNrZWQgaW4gYW5kIHRoZSBWZWdhJ3MgYXJlIHB1bXBpbic=',
  'MDAwMDAyUXVpY2sgdG8gdGhlIHBvaW50LCB0byB0aGUgcG9pbnQsIG5vIGZha2luZw==',
  'MDAwMDAzQ29va2luZyBNQydzIGxpa2UgYSBwb3VuZCBvZiBiYWNvbg==',
  'MDAwMDA0QnVybmluZyAnZW0sIGlmIHlvdSBhaW4ndCBxdWljayBhbmQgbmltYmxl',
  'MDAwMDA1SSBnbyBjcmF6eSB3aGVuIEkgaGVhciBhIGN5bWJhbA==',
  'MDAwMDA2QW5kIGEgaGlnaCBoYXQgd2l0aCBhIHNvdXBlZCB1cCB0ZW1wbw==',
  'MDAwMDA3SSdtIG9uIGEgcm9sbCwgaXQncyB0aW1lIHRvIGdvIHNvbG8=',
  'MDAwMDA4b2xsaW4nIGluIG15IGZpdmUgcG9pbnQgb2g=',
  'MDAwMDA5aXRoIG15IHJhZy10b3AgZG93biBzbyBteSBoYWlyIGNhbiBibG93'
]

INPUT = base64_decode(UNKNOWN_STRINGS.shuffle.first)
puts "Input: #{INPUT}"

KEY = 16.times.map { rand(0..255) }
puts "Key: #{KEY.inspect}"

BLOCK_SIZE = 16

def encrypt_credentials
  iv = 16.times.map { rand(0..255) }
  padded_buffer = pkcs7_pad(INPUT, 16)
  output = aes_cbc_encrypt(padded_buffer, KEY, iv)

  [iv, output]
end

def check_credentials(iv, buffer)
  output = aes_cbc_decrypt(buffer, KEY, iv)
  pkcs7_unpad(output)
  true
rescue
  false
end

iv, encrypted_output = encrypt_credentials
puts  "IV: #{iv}"
puts "Encrypted buffer: #{encrypted_output}"
puts "Valid encryption: #{check_credentials(iv, encrypted_output)}"

=begin
 There are two steps to this attack:

 1. Finding an IV that generates a value with correct padding after the XOR
 2. Inferring a value that produces 0 after figuring out step 1
 3. If we find an IV that XOR(BLOCK, IV) = 0 it means that BLOCK == IV
=end

def decrypt_byte(iv, block, known)
  c = BLOCK_SIZE.times.map { rand(0..255) }
  p = known.length + 1

  # During encryption we:
  # 1. XOR (block, iv)
  # 2. Encrypt the value above ending with an "encrypted value"
  #
  # During decryption we do:
  # 1. decrypted_value = aes_cbc_decrypt(encrypted_value, KEY)
  # 2. XOR(decrypted_value, iv)
  # 3. We now have our plaintext
  #
  # So let's deconstruct what "c[byte_pos] = x ^ p ^ iv[byte_pos]" means.
  #
  # 1. We know "x" is part of our "zeroing IV", meaning:
  #    * XOR(decrypted_value[pos], x) == 0
  # 2. p is the amount of zeroing bytes we already know
  # 3. iv[byte_pos]  is our IV
  #
  # By doing c[byte_pos] = x ^ p ^ iv[byte_pos]
  #
  # We know that doing XOR(XOR(decrypted_block, iv), iv) will return decrypted_block
  # Following with XOR(decrypted_block[pos], x) will return 0 since x is equal the block
  # byte.
  # Followed by XOR(0, p) will return p, setting the byte to the padding value we want

  known.each_with_index do |x, i|
    byte_pos = BLOCK_SIZE - i - 1
    c[byte_pos] = x ^ p ^ iv[byte_pos]
  end

  i = 0

  loop do
    c[BLOCK_SIZE - p] = i
    break if check_credentials(c, block)
    raise "Couldn't guess byte" if i > 256
    i += 1
  end

  # So here we know c[BLOCK_SIZE - p] = i generated a value that
  # when XORed creates a valid padding for that specific byte.
  # Now we need to find the value for the "zeroing IV".
  #
  # We know that "iv[BLOCK_SIZE - p] ^ i" generates a number for a valid padding
  # when XORing it with our decrypted_value
  # and "p" represents that number for the current iteration. So XORing
  # "iv[BLOCK_SIZE - p] ^ i" with "p" will generate a number that when XORed
  # with the decrypted block will zero it.

  iv[BLOCK_SIZE - p] ^ i ^ p
end

def decrypt_block(iv, buffer, n)
  iv = buffer.slice((n - 1) * BLOCK_SIZE, BLOCK_SIZE) if n > 0
  block = buffer.slice(n * BLOCK_SIZE, BLOCK_SIZE)
  known = []

  BLOCK_SIZE.times do
    known << decrypt_byte(iv, block, known)
  end

  known.reverse
end

def decrypt(buffer, iv)
  n = buffer.length / BLOCK_SIZE
  (0...n).flat_map { |i| decrypt_block(iv, buffer, i) }
end

decrypted = decrypt(encrypted_output, iv)
puts "Decrypted: #{decrypted}"
puts pkcs7_unpad(decrypted).pack('C*')
