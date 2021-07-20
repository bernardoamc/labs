require_relative '../helpers'
require_relative '../mt19937'

rng = MT19937.new(42)
a = rng.take(10)
b = rng.take(10)
puts(a != b)

rng = MT19937.new(42)
a = rng.take(10)
rng = MT19937.new(23)
b = rng.take(10)
puts(a != b)

rng = MT19937.new(42)
a = rng.take(10)
rng = MT19937.new(42)
b = rng.take(10)
puts(a == b)
