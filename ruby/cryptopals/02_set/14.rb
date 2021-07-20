require_relative '../helpers'
require 'openssl'

RANDOM_KEY = 16.times.map { rand(0..255) }
RANDOM_PREFIX = rand(2..14).times.map { rand(0..255) }
UNKNOWN_BUFFER = base64_decode(File.read('12.txt').strip)
BYTE = 'A'.ord

def encryption_oracle(controlled_buffer)
  padded_buffer = pkcs7_pad(RANDOM_PREFIX + controlled_buffer + UNKNOWN_BUFFER, 16)
  aes_ecb_encrypt(padded_buffer, RANDOM_KEY)
end

# My first idea is to find how much input we should give to our encryption
# oracle function until we can align our blocks.
#
# Imagine our "random prefix" is [3, 2, 1] and our block size is four.
# I would start adding 'A's until the random prefix gets to the size of
# a block and the rest of our input also fits a block size. In this case
# we would have to fill five 'A's.
# [3, 2, 1, A, A, A, A, A]. If I can find a block that is composed of only
# 'A's we know that we can apply the technique from exercise 12.

puts 'Figuring out the block and prefix size...'

def infer_block_and_prefix_size
  (1..256).each do |count|
    current_block = encryption_oracle(Array.new(count, BYTE))
    next_block = encryption_oracle(Array.new(count + 1, BYTE))

    if current_block.slice(0, count) == next_block.slice(0, count)
      block_size = 1

      while current_block.slice(0, block_size) == next_block.slice(0, block_size) do
        block_size += 1
      end

      block_size -= 1

      return [block_size - count, block_size]
    end
  end
end

prefix_size, block_size = infer_block_and_prefix_size
puts "The prefix size is: #{prefix_size}!"
puts "The actual prefix size is: #{RANDOM_PREFIX.size}"
puts "The block size is: #{block_size}!"

puts 'Testing for ECB...'
ecb_test = encryption_oracle(Array.new(block_size * 3, BYTE))
ebc_test_blocks = ecb_test.each_slice(block_size).to_a

# We have to skip the first block because of the random prefix
if ebc_test_blocks[1] == ebc_test_blocks[2]
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

def decrypt_byte(target, controlled_prefix, block_index)
  (0..255).each do |byte|
    encryption = encryption_oracle(controlled_prefix + [byte])
    #puts "Trying: #{encryption.slice(block_index * 16, 16)}"
    return byte if encryption.slice(block_index * 16, 16) == target
  end

  raise "This shouldn't happen!"
end

def decrypt_aes(block_size, prefix_size)
  padding_size = block_size - prefix_size
  puts "Padding size to fill first block: #{padding_size}"
  known = []

  UNKNOWN_BUFFER.size.times do
    block_index = (known.size / block_size) + 1
    prefix_size = (block_size - known.size - 1) % block_size
    prefix = Array.new(padding_size + prefix_size, BYTE)
    controlled_encryption = encryption_oracle(prefix)

    known << decrypt_byte(
      controlled_encryption.slice(block_index * block_size, block_size),
      prefix + known,
      block_index
    )
  end

  known
end

puts "Message found!\n\n#{decrypt_aes(block_size, prefix_size).pack('C*')}"
