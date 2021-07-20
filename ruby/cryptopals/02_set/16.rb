=begin
See https://resources.infosecinstitute.com/topic/cbc-byte-flipping-attack-101-approach/
for another explanation besides mine.

Let's remember how CBC decryption operates:

For the first block we have: decrypted = XOR(AES_DECRYPT(block, key), IV)
For the remaining blocks we have: decrypted = XOR(AES_DECRYPT(block, key), last_block)
Every round we do: plaintext += decrypted

If we are making a 1 bit error in one block ciphertext then decrypting it will
result in that block being scrambled while the next block will be modified by
one bit due to the XOR with that previous ciphertext block.

Let's say we have:

input = 'AAAAAAAAAAAAAAAA:admin<true:A<AA'

Input blocks: ["comment1=cooking", "%20MCs;userdata=", "AAAAAAAAAAAAAAAA", ":admin<true:A<AA", ";comment2=%20lik", "e%20a%20pound%20", "of%20bacon"]

Ciphertext blocks: [
  [102, 30, 140, 147, 165, 187, 118, 179, 109, 193, 85, 30, 91, 140, 126, 144],
  [62, 186, 108, 129, 88, 176, 36, 170, 58, 73, 255, 160, 13, 27, 118, 94],
  [248, 162, 172, 73, 24, 181, 67, 33, 91, 111, 148, 146, 93, 49, 112, 8],
  [181, 233, 204, 238, 65, 248, 91, 138, 56, 220, 227, 147, 20, 190, 35, 105],
  [236, 49, 228, 95, 163, 113, 96, 28, 31, 65, 58, 149, 173, 148, 0, 246],
  [134, 127, 1, 84, 141, 254, 246, 183, 251, 137, 184, 233, 137, 150, 168, 110],
  [52, 121, 154, 223, 110, 26, 221, 103, 154, 90, 11, 107, 186, 130, 91, 208]
]

What we want to do is to change on our fourth block the following characters:
  : will become ;
  < will become =

So we know the decryption of the fourth block will be XORed with the third block's ciphertext.

Let's see the operations that we have to do:

(0th pos)  decryption(181) xor (248) needs to become ; or 59 in ascii
(6th pos)  decryption(91) xor (67) needs to become = or 61
(11th pos) decryption(147) xor (146) needs to become ; or 59 in ascii
(13th pos) decryption(190) xor (49) needs to become = or 61 in ascii

Why these operations? Because AES CBC does two things with each block:
  1. Decrypts the current block with AES EDC
  2. XOR the result with the previous ciphertext

So now we need to do the math:

Right now we have dec(181) ^ (248) = 58 (:)
Which is equivalent to: dec(181) = 58 ^ 248
So dec(181) = 194

Now we need to convert our ":" to ";", which is 59.
So: 194 ^ ? = 59
=> ? = 59 ^194
=? ? = 249

So we now that we need to replace the first byte of the third block's ciphertext
from 248 to 249.

By doing the math we see that all of the bytes we change needs to be shifted by one.
So let's do it.
=end

require_relative '../helpers'
require 'openssl'

KEY = 16.times.map { rand(0..255) }
IV = 16.times.map { rand(0..255) }

puts "Key: #{KEY.inspect}"
puts "IV:  #{IV.inspect}"

def encode_cookie(userdata)
  prefix = 'comment1=cooking%20MCs;userdata='
  suffix = ';comment2=%20like%20a%20pound%20of%20bacon'
  input = prefix + userdata.tr(';=', '') + suffix

  puts "Input blocks: #{input.bytes.each_slice(16).to_a.map{ |b| b.pack('C*') }}"

  aes_cbc_encrypt(pkcs7_pad(input.bytes, 16), KEY, IV)
end

def decode_cookie(buffer)
  input = pkcs7_unpad(aes_cbc_decrypt(buffer, KEY, IV)).pack('C*')
  puts "Decoded string: #{input}"
  output = input.split(';').map { |kv| kv.split('=') }.to_h
  puts "Decoded data: #{output}"
  puts "Admin detected: #{output['admin'] == 'true'}"
end


input = 'AAAAAAAAAAAAAAAA:admin<true:A<AA'
ciphertext = encode_cookie(input)
block_offset = 32 # We want to change the third block
ciphertext[block_offset] ^= 1
ciphertext[block_offset + 6] ^= 1
ciphertext[block_offset + 11] ^= 1
ciphertext[block_offset + 13] ^= 1
decode_cookie(ciphertext)
