FIZZ = ->(n) { n % 2 ? print 'FIZZ' : print ''; n }
BUZZ = ->(n) { n % 3 ? print 'BUZZ' : print ''; n }
RULES = [FIZZ, BUZZ]

[2, 3, 5, 6].each do |n|
  puts RULES.inject(:>>).call(n)
end
