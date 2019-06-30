module Enumerable
  def lax
    Lax.new(self)
  end
end

class Lax < Enumerator
  def initialize(receiver)
    p receiver

    super() do |yielder|
      p yielder

      receiver.each do |value|
        if block_given?
          yield(yielder, value)
        else
          yielder << value
        end
      end
    end
  end

  def map(&block)
    Lax.new(self) do |yielder, value|
      yielder << block.call(value)
    end
  end
end

p 1.upto(10).lax.map { |x| x*x }.to_a
