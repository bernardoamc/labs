require_relative 'helpers'

class MT19937
  W, N, M, R = [32, 624, 397, 31]
  A = 0x9908B0DF
  U, D = [11, 0xFFFFFFFF]
  S, B = [7, 0x9D2C5680]
  T, C = [15, 0xEFC60000]
  L = 18
  F = 1812433253
  MASK_LOWER = (1 << R) - 1
  MASK_UPPER = (1 << R)

  attr_accessor :state, :index

  def initialize(seed)
    @index = N
    @state = Array.new(N, 0)
    @state[0] = seed
    (1...N).each do |i|
      @state[i] = lowest(F * (@state[i - 1] ^ (@state[i - 1] >> (W - 2))) + i, W)
    end
  end

  # width is the number of bits
  def extract_number(width = W)
    twist if @index >= N

    y = @state[@index]
    y = y ^ ((y >> U) & D)
    y = y ^ ((y << S) & B)
    y = y ^ ((y << T) & C)
    y = y ^ (y >> L)

    @index += 1
    lowest(y, width)
  end

  def extract_byte
    extract_number(8)
  end

  def take(n)
    (1..n).map { extract_number }
  end

  def twist
    N.times do |i|
      x = (@state[i] & MASK_UPPER) + (@state[(i + 1) % N] & MASK_LOWER)
      xa = x >> 1
      xa = xa ^ A unless (x % 2).zero?
      @state[i] = @state[(i + M) % N] ^ xa
    end
    @index = 0
  end
end

