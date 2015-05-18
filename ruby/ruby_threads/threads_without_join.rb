  threads = []

  threads << Thread.new do
    puts "1"
    sleep 2
    puts "3"
  end

  threads << Thread.new('a', 'c') do |a, b|
    puts a
    sleep 2
    puts b
  end

  puts
