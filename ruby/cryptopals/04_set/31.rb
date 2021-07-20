require 'benchmark'
require 'net/http'
require_relative '../helpers'

OPTIONS = '0123456789abcdef'.split('').shuffle

def http_request(file, hmac)
  uri = URI("http://localhost:9999?file=#{file}&signature=#{hmac}")
  res = Net::HTTP.get_response(uri)
  res.code.to_i
end

# The idea is that we know roughly how much time it takes for
# a character to be validated, so we can measure this time in order
# to know how far our validation has gone.
def find_char(file, hmac, index)
  longest_execution_time = -1
  character = ''

  OPTIONS.each do |option|
    hmac[index] = option

    time = Benchmark.realtime do
      http_request(file, hmac)
    end

    if time > longest_execution_time
      longest_execution_time = time
      character = option
    end
  end

  character
end

def hmac_timing_attack(file)
  hmac = '0000000000000000000000000000000000000000'

  hmac.size.times.each do |index|
    hmac[index] = find_char(file, hmac, index)
    puts "Current hmac: #{hmac}"
  end

  hmac
end

file = ['fortnite', 'counter', 'strike', 'torchlight'].shuffle.first
hmac = hmac_timing_attack(file)
puts "Found hmac: #{http_request(file, hmac) == 200}"
