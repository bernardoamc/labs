class Foo
  def bla
    puts '1'
    yield(self, 'hey') if block_given?
    puts '2'
  end

  def hello
    puts 'hello'
  end
end

foo = Foo.new

foo.bla do |popover, random|
  puts 'hey'
  popover.hello
  puts random
end

foo.bla
