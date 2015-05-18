results = []

100.times do
  results << %x{ ruby thread_unsafe_operator.rb }.chomp
end

puts results.inspect

