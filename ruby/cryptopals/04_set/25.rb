require_relative '../helpers'
require 'openssl'

NONCE = 0
KEY = 16.times.map { rand(0..255) }
PLAINTEXT = pkcs7_unpad(
  aes_ecb_decrypt(
    base64_decode(File.read('./25.txt').strip),
    'YELLOW SUBMARINE'.bytes
  )
)

def edit(ciphertext, offset, newtext)
  raise if offset >= ciphertext.size
  raise if (newtext.size + offset) > ciphertext.size

  plaintext = aes_ctr_decrypt(ciphertext, KEY, NONCE)

  newtext.size.times do |index|
    plaintext[offset + index] = newtext[index]
  end

  aes_ctr_encrypt(plaintext, KEY, NONCE)
end

# Sanity check
cipher = aes_ctr_encrypt('potatoland? heck yeah!'.bytes, KEY, NONCE)
new_cipher = edit(cipher, 10, '!'.bytes)
decrypted = aes_ctr_decrypt(new_cipher, KEY, NONCE).pack('C*')
expected = 'potatoland! heck yeah!'
puts decrypted == expected


# The idea here is that whatever we pass to our #edit message will be encrypted
# by ECB using the same content and KEY and the only difference is the XOR
# operation with the message. Mathematically speaking the operation for each
# block is the following:
#
# XOR(message, ECB_ENC(...))
#
# Since ECB_ENC(...) is the same independent of the message we can figure
# out the plaintext in a cheap way using:
#
# XOR (CIPHERTEXT, edited_message), which expands to:
# XOR(XOR(PLAINTEXT, ECB_ENC(...), XOR(random_message, ECB_ENC(...))
# Since XOR(ECB_ENC(...), ECB_ENC(...)) is zero we end up with:
# XOR(PLAINTEXT, random_message)
# Since we know our random_message we can just XOR it again with our value above
# to get the plaintext:
# XOR(XOR(PLAINTEXT, random_message), random_message)
#
# Or in code:

ciphertext = aes_ctr_encrypt(PLAINTEXT, KEY, NONCE)
random_message = ciphertext.size.times.map { rand(0..255) }
edited_message = edit(ciphertext, 0, random_message)
puts xor_bytes(xor_bytes(ciphertext, edited_message), random_message).pack('C*')
