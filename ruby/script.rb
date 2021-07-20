require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'benchmark-ips', require: 'benchmark/ips'
end

Benchmark.ips do |x|
  x.report('original') { naive_implementation() }
  x.report('optimized') { fast_implementation() }

  x.compare!
end
