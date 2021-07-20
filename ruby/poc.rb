class CoolTestCase
  def self.test(name)
    puts name
  end
end

class AllTheTags
  class << self
    attr_accessor :last_tags
  end
end

module Tagit
  def tag(name)
    AllTheTags.last_tags = name
  end

  def test(name)
    puts AllTheTags.last_tags
    super(name)
    AllTheTags.last_tags = nil
  end
end

CoolTestCase.singleton_class.prepend(Tagit)

class Foo < CoolTestCase
  tag 'yay'
  test 'hello'

  tag 'meh'
  test 'blah'
end

foo = Foo.new



