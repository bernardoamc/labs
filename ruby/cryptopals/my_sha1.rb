class MySHA1
  H = [0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476, 0xc3d2e1f0]
  K = Array.new(20, 0x5a827999) +
        Array.new(20, 0x6ed9eba1) +
        Array.new(20, 0x8f1bbcdc) +
        Array.new(20, 0xca62c1d6)

  BIT_BLOCK_SIZE = 512 # Size of a block in bits
  BIT_LENGTH_SIZE = 64 # Size in which the buffer length is stored in bits
  BUFFER_MAX_SIZE = BIT_BLOCK_SIZE - BIT_LENGTH_SIZE

  def initialize(buffer)
    @buffer = buffer
  end

  # Take the input message and manipulate it into bits, and pad it
  # sufficiently to make a multiple of 512 bits.
  #
  # The padding consists of a 1, followed by 0 to make the total
  # length 448 bits, and then the input message length in bits
  # formatted as a 64-bit string.
  def hexdigest
    bits = @buffer.bytes.map do |byte|
      "%08b" % byte
    end.join('')

    padding = '1' +
      ('0' * (BUFFER_MAX_SIZE - bits.size - 1)) +
      ('%064b' % (@buffer.size * 8))

    padded_bits = bits + padding
    raise 'Invalid padding' if padded_bits.size != BIT_BLOCK_SIZE

    blocks = padded_bits.chars.each_slice(BIT_BLOCK_SIZE).to_a
    blocks_size = blocks.size

    blocks.each do |block|
      # Now we need to break this block into chunks of 32 bits
      eight_byte_chunks = block.each_slice(32).map do |eight_byte_chunk|
        eight_byte_chunk.join('').to_i(2)
      end

      # Now we need to extend this array of 32 bit chunks into an
      # array of 80 bit chunks through some transformations
      (16..79).each do |i|
        chunkA = eight_byte_chunks[i - 3]
        chunkB = eight_byte_chunks[i - 8]
        chunkC = eight_byte_chunks[i - 14]
        chunkD = eight_byte_chunks[i - 16]

        xorA = chunkA ^ chunkB
        xorB = xorA ^ chunkC
        xorC = xorB ^ chunkD

        newChunk = rotl(xorC, 1)
        eight_byte_chunks << newChunk
      end

      a, b, c, d, e = H
      newH = H.dup
    end
  end

  private

  MASK = 0xffffffff

  # Rotate 'x' left by an amount 'n'
  # Example: rotl(1011, 2, 4) = 1110
  def rotl(x, n)
    ((x << n) & MASK) | (x >> (32 - n))
  end

  # For each bit index, that result bit is according to the bit from 𝑦
  # (or respectively 𝑧 ) at this index, depending on if the bit from 𝑥
  # at this index is 1 (or respectively 0)
  def choose(x, y, z)
    (x & y) ^ (~x & z)
  end

  def parity(x, y, z)
    x ^ y ^ z
  end

  # For each bit index, that result bit is according to the majority
  # of the 3 inputs bits for 𝑥 𝑦 and 𝑧 at this index.
  def majority(x, y, z)
    (x & y) ^ (x & z) ^ (y & z)
  end
end

sha1 = MySHA1.new('potato')
sha1.hexdigest
