require_relative '../helpers'
require_relative '../mt19937'

SEED = rand(0..0xFFFF) # 16 bits
BYTE = 'A'.ord
PLAINTEXT = Array.new(14, BYTE)

puts mt19937_decrypt(mt19937_encrypt(PLAINTEXT, SEED), SEED).inspect

def encrypt_with_random_prefix(plaintext, seed)
  prefix = rand(2..32).times.map { |b| rand(0..255) }
  final_plaintext = prefix + plaintext
  mt19937_encrypt(final_plaintext, seed)
end

def valid_seed?(ciphertext, rng)
  ciphertext.each do |byte|
    return false if byte ^ rng.extract_byte != BYTE
  end

  true
end

def decrypt_with_random_prefix(ciphertext, seed)
  prefix_size = ciphertext.size - PLAINTEXT.size
  known_ciphertext = ciphertext.slice(prefix_size, PLAINTEXT.size)

  (0..0xFFFF).each do |potential_seed|
    rng = MT19937.new(potential_seed)
    prefix_size.times { rng.extract_byte }

    return potential_seed if valid_seed?(known_ciphertext, rng)
  end

  raise 'Seed not found!'
end

# ciphertext = encrypt_with_random_prefix(PLAINTEXT, SEED)
# puts decrypt_with_random_prefix(ciphertext, SEED)

def password_token
  rng = MT19937.new(Time.now.to_i)
  password = 16.times.map { rng.extract_byte }
  base64_encode_bytes(password)
end

def weak_password?(password_token)
  rng = MT19937.new(Time.now.to_i)
  bytes = 16.times.map { rng.extract_byte }

  decoded = base64_decode(password_token)
  bytes == decoded
end

puts 'WEAK!' if weak_password?(password_token)
