#############################################################################
# 1. Let KEYSIZE be the guessed length of the key; try values from 2 to
# (say) 40.
#
# 2. Write a function to compute the edit distance/Hamming distance
# between two strings. *The Hamming distance is just the number of
# differing bits*. The distance between:
#
#     this is a test
#
# and
#
#     wokka wokka!!!
#
# is **37**. Make sure your code agrees before you proceed.
#
# 3. For each KEYSIZE, take the *first* KEYSIZE worth of bytes, and the
# *second* KEYSIZE worth of bytes, and find the edit distance between
# them. Normalize this result by dividing by KEYSIZE.
#
# 4. The KEYSIZE with the smallest normalized edit distance is probably
# the key. You could proceed perhaps with the smallest 2-3 KEYSIZE
# values. Or take 4 KEYSIZE blocks instead of 2 and average the
# distances.
#
# 5. Now that you probably know the KEYSIZE: break the ciphertext into
# blocks of KEYSIZE length.
#
# 6. Now transpose the blocks: make a block that is the first byte of
# every block, and a block that is the second byte of every block, and
# so on.
#
# 7. Solve each block as if it was single-character XOR. You already
# have code to do this.
#
# 8. For each block, the single-byte XOR key that produces the best
# looking histogram is the repeating-key XOR key byte for that block.
# Put them together and you have the key.
#############################################################################

require_relative '../helpers'
string = base64_decode(File.read('06.txt').strip)

KEY_LEN_RANGE = (2..40)

# The idea is that we can:
# 1. Get 4 chunks of KEY_LEN
# 2. XOR these chunks with repeating XOR
# 3. Calculate the hamming distance between adjacent chunks and divide by the key
#     length to normalize it.
# 4. Get the average of distances

Key = Struct.new(:distance, :len, keyword_init: true) do
  def key_sort(other)
    distance <=> other.distance
  end
end

keys = KEY_LEN_RANGE.map do |key_len|
  c1 = string.slice(0, key_len)
  c2 = string.slice(key_len, key_len)
  c3 = string.slice(key_len * 2, key_len)
  c4 = string.slice(key_len * 3, key_len)

  d1 = hamming(c1, c2) / key_len.to_f
  d2 = hamming(c2, c3) / key_len.to_f
  d3 = hamming(c3, c4) / key_len.to_f

  distance = (d1 + d2 + d3) / 3.0

  Key.new(distance: distance, len: key_len)
end

candidates = keys.sort(&:key_sort).first(3)
puts "Potential key lenght candidates: #{candidates.inspect}"

# Now that we have the best key length candidates we need to:
# 1. break the ciphertext into blocks of KEYSIZE length.
# 2. transpose the blocks: make a block that is the first byte of every block,
#    and a block that is the second byte of every block, and so on.
# 3. Solve each block as if it was single-character XOR.
# 4. For each block, the single-byte XOR key that produces the best
#    looking histogram is the repeating-key XOR key byte for that block.
keys = candidates.map do |candidate|
  blocks = string.each_slice(candidate.len).to_a

  # Right padding the last block so all blocks have the same length.
  # This way we can transpose blocks successfully.
  blocks[-1] = rightpad(blocks[-1], blocks.first.size, nil)

  blocks.transpose.map do |transposed_block|
    max_score = 0
    chosen_character = ''

    (0..255).each do |xored_candidate|
      xor_result = xor_bytes_against_byte(
        transposed_block.compact,
        xored_candidate
      ).pack('C*')
      score = english_score(xor_result)

      if score > max_score
        max_score = score
        chosen_character = xored_candidate
      end
    end

    chosen_character
  end.pack('C*')
end

puts "Potential keys: #{keys}"
translations = keys.map { |key| xor_bytes_repeating(string, key.bytes).pack('C*') }
puts translations.max_by { |t| english_score(t) }
