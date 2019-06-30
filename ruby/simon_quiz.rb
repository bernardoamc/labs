module Foo
  extend self

  def foo
    'foo'
  end
end

module Bar
  def bar
    'bar'
  end
end

class Quiz
end

Quiz.singleton_class.include(Bar)
Quiz.extend(Foo)

p Quiz.foo
p Quiz.bar

p Quiz.method(:foo).owner.singleton_class?
p Quiz.method(:bar).owner.singleton_class?
p Quiz.singleton_class.ancestors
