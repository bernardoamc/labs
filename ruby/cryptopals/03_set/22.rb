require_relative '../helpers'
require_relative '../mt19937'

def random_ints(seed, n)
  rng = MT19937.new(seed)
  rng.take(n)
end

def random_wait
  puts('waiting a bit...')
  sleep(rand(40..1000))
end

def wait_for_it
  random_wait
  rng = MT19937.new(Time.now.to_i)
  random_wait
  rng.extract_number
end

# The idea here is that since our PRNG is initialized
# with Time.now as a seed and we had to wait between
# 40 and 1000 seconds, by reducing the Time.now by
# 2000 seconds and iterating through it until we hit
# the original Time.now we are guaranteed to find
# our seed.
def crack_it(rng_output)
  to = Time.now.to_i
  from = to - 2000
  (from..to).reverse_each do |seed|
    rng = MT19937.new(seed)
    return seed if rng.extract_number == rng_output
  end
  raise 'Seed not found'
end

# Sanity check
seed = rand(0..1000)
a = random_ints(seed, 100)
b = random_ints(seed, 100)
puts(a == b)

rng_output = wait_for_it
puts("RNG output: #{rng_output}")
seed = crack_it(rng_output)
puts("RNG seed: #{seed}")
