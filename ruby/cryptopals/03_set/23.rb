require_relative '../helpers'
require_relative '../mt19937'

W = 32
U, D = [11, 0xFFFFFFFF]
S, B = [7, 0x9D2C5680]
T, C = [15, 0xEFC60000]
L = 18

def temper(y)
  y = y ^ ((y >> U) & D)
  y = y ^ ((y << S) & B)
  y = y ^ ((y << T) & C)
  y = y ^ (y >> L)
  lowest(y, W)
end

# Reverses our temper method
def untemper(y)
  y = y ^ (y >> L)
  y = y ^ ((lowest(y >> 0 * T, T) << 1 * T) & C)
  y = y ^ ((lowest(y >> 1 * T, T) << 2 * T) & C)
  y = y ^ ((lowest(y >> 0 * S, S) << 1 * S) & B)
  y = y ^ ((lowest(y >> 1 * S, S) << 2 * S) & B)
  y = y ^ ((lowest(y >> 2 * S, S) << 3 * S) & B)
  y = y ^ ((lowest(y >> 3 * S, S) << 4 * S) & B)
  y = y ^ (y >> U)
  y = y ^ (y >> (2 * U))
  lowest(y, W)
end

def clone(rng)
  state = rng.take(624)
  clone = MT19937.new(0)
  clone.state = state.map { |n| untemper(n) }
  clone
end

rng = MT19937.new(42)
rng2 = clone(rng)
puts(rng.take(1000) == rng2.take(1000))

# the basic problem here is that it's practical to untemper the
# diffused state, so a transformation that's hard to reverse would
# help here

# cryptographic hash functions are sufficient for this purpose, even
# something as broken as MD5
