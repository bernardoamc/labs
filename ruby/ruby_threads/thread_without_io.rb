require 'benchmark'
require 'digest/sha1'

def request_without_threads(n)
  n.times.map do
    Digest::SHA1.hexdigest 'pass'
  end
end

def request_with_threads(n)
  n.times.map do
    Thread.new do
      Digest::SHA1.hexdigest 'pass'
    end
  end.each(&:value)
end

Benchmark.bm do |x|
  x.report { request_without_threads(10000) }
  x.report { request_with_threads(10000) }
end
