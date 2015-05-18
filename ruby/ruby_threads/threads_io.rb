require 'benchmark'
require 'open-uri'

def request_without_threads(n)
  n.times.map do
    open('http://pudim.com.br')
  end
end

def request_with_threads(n)
  n.times.map do
    Thread.new do
      open('http://pudim.com.br')
    end
  end.each(&:value)
end

Benchmark.bm do |x|
  x.report { request_without_threads(10) }
  x.report { request_with_threads(10) }
end
