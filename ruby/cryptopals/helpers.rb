require 'base64'

ENGLISH_FREQUENCY = {
  ' ' => 0.14,
  'e' => 0.12,
  't' => 0.09,
  'other' => 0.09,
  'a' => 0.08,
  'o' => 0.07,
  'i' => 0.06,
  'n' => 0.06,
  's' => 0.06,
  'h' => 0.06,
  'r' => 0.05,
  'd' => 0.04,
  'l' => 0.04,
  'c' => 0.02,
  'u' => 0.02,
  'm' => 0.02,
  'w' => 0.02,
  'f' => 0.02,
  'g' => 0.02,
  'y' => 0.01,
  'p' => 0.01,
  'b' => 0.01,
  'v' => 0.01,
  'k' => 0.01,
  'j' => 0.01,
  'x' => 0.00,
  'q' => 0.00,
  'z' => 0.00
}.freeze

def frequency_table(string)
  frequency = Hash.new { |h,k| h[k] = 0 }
  len = string.size

  string.each_char do |character|
    bucket = ENGLISH_FREQUENCY.key?(character) ? character : 'other'
    frequency[bucket] += 1
  end

  frequency.each { |k,v| frequency[k] = v.to_f / len }

  frequency
end

def chi_squared(expected_frequency, computed_frequency)
  expected_frequency.map do |letter, expected_value|
    computed_value = computed_frequency[letter] || 0
    next 0 if expected_value.zero?
    (expected_value - computed_value) ** 2 / expected_value
  end.sum
end

def english_score(string)
  computed_frequency = frequency_table(string)
  1 / chi_squared(ENGLISH_FREQUENCY, computed_frequency)
end

def base64_decode(string)
  Base64.decode64(string).bytes
end

def base64_encode_bytes(bytes)
  Base64.strict_encode64(bytes.pack('C*'))
end

def hex_decode(string)
  [string].pack('H*').unpack('C*')
end

def hex_encode(bytes)
  bytes.pack('C*').unpack('H*')[0]
end

def decode_query_string(input)
  input.split('&').map { |kv| kv.split('=') }.to_h
end

def encode_query_string(hash)
  hash.map { |k, v| "#{k}=#{v}" }.join('&')
end

def xor_bytes(bytes1, bytes2)
  raise 'Byte arrays should have same length' if bytes1.size != bytes2.size
  bytes1.zip(bytes2).map { |a, b| a ^ b }
end

def xor_bytes_against_byte(bytes, xor_against)
  bytes.map { |x| x ^ xor_against }
end

def xor_bytes_repeating(bytes, key_bytes)
  key_size = key_bytes.size

  bytes.map.with_index(0) do |byte, index|
    byte ^ key_bytes[index % key_size]
  end
end

def popcount(x)
  x.to_s(2).count('1')
end

def hamming(s1, s2)
  raise 'Strings should have the same length' if s1.size != s2.size
  s1.size.times.map { |i| popcount(s1[i].ord ^ s2[i].ord) }.sum
end

def rightpad(buffer, expected_size, filler)
  return buffer if buffer.size >= expected_size
  padding_size = expected_size - buffer.size
  buffer + Array.new(padding_size, filler)
end

# AES is a 128 bit encryption, hence the need for 16-byte chunks
def aes_ecb_internal(mode, buffer, key)
  raise 'Buffer must be composed of 16-byte chunks' unless (buffer.size % 16).zero?
  cipher = OpenSSL::Cipher.new('AES-128-ECB')
  cipher.send(mode)
  cipher.key = key.pack('C*')
  cipher.padding = 0 # decryption will otherwise fail
  result = cipher.update(buffer.pack('C*')) + cipher.final
  result.unpack('C*')
end

def aes_ecb_decrypt(buffer, key)
  aes_ecb_internal(:decrypt, buffer, key)
end

def aes_ecb_encrypt(buffer, key)
  aes_ecb_internal(:encrypt, buffer, key)
end

# See https://tools.ietf.org/html/rfc2315#section-10.3
def pkcs7_pad(bytes, block_size)
  raise 'Invalid block size' if block_size >= 256
  padding_len = block_size - (bytes.size % block_size)
  padding = Array.new(padding_len, padding_len)
  bytes + padding
end

def pkcs7_unpad(buffer)
  size = buffer[-1]
  padding = buffer.slice(-size, size)
  raise 'invalid padding' unless size > 0 && size < 256 &&
                                 padding.all? { |b| b == size }
  buffer[0...-size]
end

# CBC mode is a block cipher mode that allows us to encrypt irregularly-sized
# messages, despite the fact that a block cipher natively only transforms
# individual blocks.
#
# For every plaintext block:
#
# 1. XOR the previous block encryption result with the next plaintext block
#   *. The first block doesn't have a previous block, so do it with a fake
#     ciphertext block called initialization vector (IV)
# 2. Encrypt this result through aes_ecb using the key to get a ciphertext
# 3. Add the ciphertext to an Array
# 4. Repeat until all plaintext blocks are consumed
def aes_cbc_encrypt(buffer, key, iv)
  blocks = buffer.each_slice(key.size)
  previous_ciphertext_block = iv

  blocks.flat_map do |block|
    previous_ciphertext_block = aes_ecb_encrypt(
      xor_bytes(previous_ciphertext_block, block),
      key
    )

    previous_ciphertext_block
  end
end

def aes_cbc_decrypt(ciphertext, key, iv)
  blocks = ciphertext.each_slice(key.size)
  previous_ciphertext = iv

  blocks.flat_map do |block|
    decrypted = xor_bytes(aes_ecb_decrypt(block, key), previous_ciphertext)
    previous_ciphertext = block

    decrypted
  end
end

def long_bytes_le(buffer)
  [buffer].pack('q<').bytes
end

def aes_ctr_internal(buffer, key, nonce)
  nonce = long_bytes_le(nonce)
  blocks = buffer.each_slice(16)

  blocks.each_with_index.flat_map do |block, i|
    intermediate = aes_ecb_encrypt(nonce + long_bytes_le(i), key)
    xor_bytes(block, intermediate.take(block.length))
  end
end

alias aes_ctr_decrypt aes_ctr_internal
alias aes_ctr_encrypt aes_ctr_internal

def lowest(n, w)
  n & ((1 << w) - 1)
end

require_relative 'mt19937'
def mt19937_internal(buffer, key)
  rng = MT19937.new(key)
  buffer.map { |byte| byte ^ rng.extract_byte }
end

alias mt19937_encrypt mt19937_internal
alias mt19937_decrypt mt19937_internal

require_relative 'sha1'

def sha1_mac(buffer, key)
  SHA1.hexdigest(key + buffer)
end

def sha1_hmac(buffer, key)
  hmac(buffer, key, 64) { |key| SHA1.hexdigest(key) }
end

require_relative 'md4'

def md4_mac(buffer, key)
  MD4.hexdigest(key + buffer)
end

def hmac(buffer, key, block_size)
  key = hex_decode(yield key) if key.size > block_size
  key += Array.new(block_size - key.size, 0) if key.size < block_size
  opad = xor_bytes(key, Array.new(block_size, 0x5c))
  ipad = xor_bytes(key, Array.new(block_size, 0x36))
  yield(opad + hex_decode(yield ipad + buffer))
end
