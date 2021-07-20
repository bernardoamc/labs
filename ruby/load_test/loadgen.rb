# ruby loadgen.rb <HOST> <RATE OF REQUESTS>
# ruby loadgen.rb http://localhost:9292 4

require 'concurrent-ruby'
require 'net/http'

uri = URI(ARGV[0])
pool = Concurrent::CachedThreadPool.new
RATE = ARGV[1].to_i

while true
  sleep(1/RATE.to_f)

  pool.post do
    time = Time.now
    Net::HTTP.get(uri)
    time_taken = Time.now - time
    puts (time_taken * 1_000).round(2)
  end
end
