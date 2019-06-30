class MyString < String
  def initialize(str)
    @str = str
  end

  def sub(*args, &block)
    super
  end
end

str = MyString.new('foo')

puts(str.sub(/(fo)(o)/) {
  puts 'Mine'
  puts $~.inspect
  $2 + $1.upcase!
})

puts('foo'.sub(/(fo)(o)/) {
  puts 'Original'
  puts $~.inspect
  $2 + $1.upcase!
})
