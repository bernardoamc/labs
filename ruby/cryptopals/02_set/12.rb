require_relative '../helpers'
require 'openssl'

RANDOM_KEY = 16.times.map { rand(0..255) }
UNKNOWN_BUFFER = base64_decode(File.read('12.txt').strip)
BYTE = 'A'.ord

def encryption_oracle(controlled_buffer)
  padded_buffer = pkcs7_pad(controlled_buffer + UNKNOWN_BUFFER, 16)
  aes_ecb_encrypt(padded_buffer, RANDOM_KEY)
end

# Let's find the block size of our algorithm.
#
# Suppose our buffer is composed of [0, 1, 2, 3, 4] and our block size is FOUR
#
# We start feeding 'A' (41) to our algorithm every cycle.
# After pkcs7 padding we have: [41, 0, 1, 2, 3, 4, \x2, \x2]
# Encrypt the value above.
#
# Do the same thing now, but instead of one 'A' we feed it two 'A's.
# [41, 41, 0, 1, 2, 3, 4, \x1]
# Encrypt this new value.
#
# Is the FIRST block the same ciphertext for the 'A' and 'AA' cases?
# No, so let's keep feeding it more 'A's.
# [41, 41, 41, 0, 1, 2, 3, 4, \x4, \x4, \x4, \x4]
# Is this first block the same as the previous one?
# No, since we have [41, 41, 0, 1] versus [41, 41, 41, 0]
#
# Next 'A'
# [41, 41, 41, 41, 0, 1, 2, 3, 4, \x3, \x3, \x3]
# Is this first block the same as the previous one?
# No, since we have [41, 41, 41, 0] versus [41, 41, 41, 41]
#
# Next 'A'
# [41, 41, 41, 41, 41, 0, 1, 2, 3, 4, \x2, \x2]
# Is this first block the same as the previous one?
# YES, since we have [41, 41, 41, 41] versus [41, 41, 41, 41]
#
#
# Nice, we found our block size! Which is the number of 'A' minus one.
# In this case it's 4.

puts 'Figuring out the block size...'

def infer_block_size
  (1..256).each do |count|
    current_block = encryption_oracle(Array.new(count, BYTE))
    next_block = encryption_oracle(Array.new(count + 1, BYTE))

    if current_block.slice(0, count) == next_block.slice(0, count)
      return count
    end
  end
end

block_size = infer_block_size
puts "The block size is: #{block_size}!"

puts 'Testing for ECB...'
ecb_test = encryption_oracle(Array.new(block_size * 2, BYTE))
ebc_test_blocks = ecb_test.each_slice(block_size).to_a

if ebc_test_blocks[0] == ebc_test_blocks[1]
  puts 'ECB detected!'
end

# Let's now decrypt one byte per turn!
# 1. Craft an input block that is exactly 1 byte short. For instance, if the block
#    size is 4 bytes, make "AAA".
# 2. Store the first block of this encryption.
# 3. Build a dictionary of type "AAAX", so "AAAA", "AAAB", and so on.
# 4. Compare the result of this dictionary against step 2.
# 5. BAM, we have found one byte!
# 6. Now reduce your input to just "AA" and repeat the process.
# 7. Eventually we will have found the entire block.
#
# Let's see an example with: [0,1,2,3,4,5,6,7] and block size 4
# So first we add 3 'A's => [A, A, A, 0, 1, 2, 3, 4, 5, 6, 7]
# Now we encrypt this value and get the first block. [A, A, A, 0]
# Now we create our dictionary 'AAA0', 'AAA1', AAA2' and so on.
# By comparing [A, A, A, 0] with our dictionary we find that the first byte is zero!
# Now we do the same thing with one less 'A' => [A, A, 0, 1]
# And we build a dictionary of 'AA00', 'AA01', 'AA02' and so on.
# By comparing [A, A, 0, 1] with our dictionary we find that the first byte is one!
# Now we do this until we exhaust the firsy block. What about the second?
# By now we know that the first block is composed of [0, 1, 2, 3]
# So we can repeat the process!
# Send 'AAA' and build a dictionary for the last byte of the SECOND block!
# Let's see the first two blocks: [A, A, A, 0, 1, 2, 3, 4]
# We now build a dictionary of type '1230', '1231', '1233', and so on.
# And find that our fifth byte is '4'!
# This is repeat until the entire string exhausted!

puts "Decrypting message..."

def decrypt_byte(target, controlled_prefix, current_block)
  (0..255).each do |byte|
    encryption = encryption_oracle(controlled_prefix + [byte])
    return byte if encryption.slice(current_block * 16, 16) == target
  end

  raise "This shouldn't happen!"
end

def decrypt_aes(block_size)
  known = []

  UNKNOWN_BUFFER.size.times do
    current_block = known.size / block_size
    prefix_size = (block_size - known.size - 1) % block_size
    prefix = Array.new(prefix_size, BYTE)
    controlled_encryption = encryption_oracle(prefix)

    known << decrypt_byte(
      controlled_encryption.slice(current_block * block_size, block_size),
      prefix + known,
      current_block
    )
  end

  known
end

puts "Message found!\n\n#{decrypt_aes(block_size).pack('C*')}"
