thread = Thread.new do
  raise 'booom'
end

puts 'Exception?'
sleep 2
puts 'What?'

thread.join
