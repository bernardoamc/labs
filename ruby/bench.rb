require 'benchmark'

class Foo
  attr_reader :id

  def initialize(id: 1)
    @id = id
  end
end

a = []
b = []

100_000.times do |i|
  a << Foo.new(id: i)
  b << Foo.new(id: i)
end

a.shuffle!
b.shuffle!

puts "Using: '-'"
puts Benchmark.measure { (a - b) == [] }

puts "Using map + sort"
puts Benchmark.measure {
  a.map(&:id).sort == b.map(&:id).sort
}
