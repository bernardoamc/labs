@counter = 0

5.times.map do |i|
  Thread.new do
    temp = @counter
    puts "temp: #{temp} na thread #{i+1}"
    temp = temp + 1
    puts "INC temp: #{temp} na thread #{i+1}"
    @counter = temp
    puts "counter: #{@counter} na thread #{i+1}"
  end
end.each(&:join)

puts @counter
