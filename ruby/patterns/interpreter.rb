# The Interpreter pattern, as the name says, is used to interpret some kind of
# specific language. It is used when a domain is better expressed with a proper
# language. The interpreter pattern usually has 2 steps.
#
# 1. Parse specific language to generate an Abstract Syntax Tree (AST)
# 2. Evaluate the AST against a context.
#
# In the following example from Design Patterns in Ruby book, we don't generate
# an AST exactly.
#
# Let's see:

require 'find'

class Expression
  def |(other)
    Or.new(self, other)
  end

  def &(other)
    And.new(self, other)
  end
end

class All < Expression
 def evaluate(dir)
   results= []

   Find.find(dir) do |p|
     next unless File.file?(p)
     results << p
   end

    results
  end
end

class FileName < Expression
  def initialize(pattern)
    @pattern = pattern
  end

  def evaluate(dir)
    results= []

    Find.find(dir) do |p|
      next unless File.file?(p)
      name = File.basename(p)
      results << p if File.fnmatch(@pattern, name)
    end

    results
  end
end

class Bigger < Expression
  def initialize(size)
    @size = size
  end

  def evaluate(dir)
    results= []

    Find.find(dir) do |p|
      next unless File.file?(p)
      results << p if File.size(p) > @size
    end

    results
  end
end

class Writable < Expression
  def evaluate(dir)
    results= []

    Find.find(dir) do |p|
      next unless File.file?(p)
      results << p if File.writable?(p)
    end

    results
  end
end

class Not < Expression
  def initialize(expression)
    @expression = expression
  end

  def evaluate(dir)
    All.new.evaluate(dir) - @expression.evaluate(dir)
  end
end

class Or < Expression
  def initialize(expression1, expression2)
    @expression1 = expression1
    @expression2 = expression2
  end

  def evaluate(dir)
    result1 = @expression1.evaluate(dir)
    result2 = @expression2.evaluate(dir)
    (result1 + result2).sort.uniq
  end
end

class And < Expression
  def initialize(expression1, expression2)
    @expression1 = expression1
    @expression2 = expression2
  end

  def evaluate(dir)
    result1 = @expression1.evaluate(dir)
    result2 = @expression2.evaluate(dir)
    result1 & result2
  end
end

writable_txt_bigger_than_2k = ((Bigger.new(2048) & Not.new(Writable.new)) | FileName.new("*.txt"))
p writable_txt_bigger_than_2k.evaluate("./files")
