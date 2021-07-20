# https://rosettacode.org/wiki/SHA-1#Ruby

class SHA1
  def self.hexdigest(buffer, h = nil, length = nil)
    # functions and constants
    mask = 0xffffffff
    s = proc { |n, x| ((x << n) & mask) | (x >> (32 - n)) }
    f = [
      proc { |b, c, d| (b & c) | (b.^(mask) & d) },
      proc { |b, c, d| b ^ c ^ d },
      proc { |b, c, d| (b & c) | (b & d) | (c & d) },
      proc { |b, c, d| b ^ c ^ d }
    ].freeze
    k = [0x5a827999, 0x6ed9eba1, 0x8f1bbcdc, 0xca62c1d6].freeze

    input = buffer.clone
    length ||= input.size
    bit_len = length << 3
    input << 0x80
    input << 0 while (input.size % 64) != 56
    input += [bit_len >> 32, bit_len & mask].pack('N2').bytes

    raise 'failed to pad to correct length' if input.size % 64 != 0

    # initial hash
    h ||= [0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476, 0xc3d2e1f0]

    loop do
      block = input.shift(64)
      break if block.empty?
      w = block.pack('C*').unpack('N16')

      # Process block.
      (16..79).each do |t|
        w[t] = s[1, w[t - 3] ^ w[t - 8] ^ w[t - 14] ^ w[t - 16]]
      end

      a, b, c, d, e = h
      t = 0
      4.times do |i|
        20.times do
          temp = (s[5, a] + f[i][b, c, d] + e + w[t] + k[i]) & mask
          a, b, c, d, e = temp, a, s[30, b], c, d
          t += 1
        end
      end

      [a, b, c, d, e].each_with_index { |x, i| h[i] = (h[i] + x) & mask }
    end

    h.pack('N5').unpack('H*')[0]
  end
end
