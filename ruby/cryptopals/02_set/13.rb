#   Idea: We can align the blocks so we can copy and paste just the blocks
#     that are interesting to us. Meaning we can control what each block
#     will contain. We can also count on pkcs7 to pad missing bytes in
#     our last block.
#
#   For example, providing:
#     "AAAAAAAAAAadmin\v\v\v\v\v\v\v\v\v\v\vAAA"
#
#   We end up with:
#     email=AAAAAAAAAAadmin\v\v\v\v\v\v\v\v\v\v\vAAA&uid=10&role=user
#   The representation in blocks is:
#     Block 0: email=AAAAAAAAAA
#     Block 1: admin\v\v\v\v\v\v\v\v\v\v\v
#     Block 2: AAA&uid=10&role=
#     Block 3: user
#
#   So we can now shift blocks to get the output we desired. For example.
#     Block 0: "email=AAAAAAAAAA"
#     Block 1: "admin\v\v\v\v\v\v\v\v\v\v\v"
#     Block 2: "AAA&uid=10&role="
#
#   So we can reconstruct out cirphertext with: block[0] + block[2] + block[1]
#
#   And since the last block is "admin\v\v\v\v\v\v\v\v\v\v\v"
#   After going through pkcs7_unpad we end up with just admin!
#
#   Why is that? Because \v stands for 11 in byte representation. And 11
#   is exactly the amount of \v that we provided. :)

require_relative '../helpers'
require 'openssl'

KEY = 16.times.map { rand(0..255) }

def profile_for(email)
  encode_query_string({
    'email' => email.tr('&=', ''),
    'uid'  => 10,
    'role'  => 'user'
  })
end

def encrypt_profile(input)
  aes_ecb_encrypt(pkcs7_pad(input, 16), KEY)
end

def decrypt_profile(input)
  decode_query_string(
    pkcs7_unpad(aes_ecb_decrypt(input, KEY)).pack('C*')
  )
end

input = "AAAAAAAAAAadmin\v\v\v\v\v\v\v\v\v\v\vAAA"
ciphertext = encrypt_profile(profile_for(input).bytes)

# Block 0: email=AAAAAAAAAA
# Block 1: admin\v\v\v\v\v\v\v\v\v\v\v
# Block 2: AAA&uid=10&role=
# Block 3: user

block0 = ciphertext.slice(0, 16)
block1 = ciphertext.slice(16, 16)
block2 = ciphertext.slice(32, 16)
ciphertext = block0 + block2 + block1

profile = decrypt_profile(ciphertext)

puts profile
puts profile['role'] == 'admin'
