# The Strategy pattern tries to solve the same problem that the Template Method
# pattern does, so what is the difference?
#
# 1- The Strategy pattern does not use inheritance, it uses composition.
# 2- It extracts the changing algorithm instead of keeping it in the class.
#
# Advantages:
#
# 1- Easier to change the algorithm on the fly.
# 2- Avoid inheritance, so i6t is easier to test the class separately.
# 3- We can use lambdas as strategies
#
# Let's see an example:

class Dollar
  def initialize(value_in_cents, converter)
    @value_in_cents = value_in_cents
    @converter = converter
  end

  def convert
    puts @converter.convert(@value_in_cents)
  end
end

class DolarToReal
  def convert(value_in_cents)
    value_in_cents * 4.0
  end
end

class DolarToLibra
  def convert(value_in_cents)
    value_in_cents * 0.7
  end
end

Dollar.new(100, DolarToReal.new).convert
Dollar.new(100, DolarToLibra.new).convert

# We could use blocks to do our job.

class NewDollar
  def initialize(value_in_cents)
    @value_in_cents = value_in_cents
  end

  def convert
    puts yield(@value_in_cents)
  end
end

NewDollar.new(100).convert do |cents|
  cents * 4.0
end

NewDollar.new(100).convert do |cents|
  cents * 0.7
end
