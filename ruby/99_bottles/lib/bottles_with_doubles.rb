class Integer
  def to_bottle_number
    BottleNumber.for(self)
  end
end

def BottleNumber(number)
  return number if number.kind_of?(BottleNumber)
  BottleNumber.for(number)
end

# 1- Extracted class to solve the single responsibility problem
# 2- Inject an object to solve the coupling problem
# 3- Test the right objects
# 4- Find better names
# 5- Adjust tests with the new class name
# 6- Remove duplicated tests
# 7- Can we find better names?
# 8- Reduce the amount of things we know about an object

class DescendingSong
  attr_reader :verse_template, :max, :min

  def initialize(verse_template: BottleVerse, max: 99, min: 0)
    @verse_template = verse_template
    @max = max
    @min = min
  end

  def song
    verses(max, min)
  end

  def verses(upper, lower)
    upper.downto(lower).map { |i| verse(i) }.join("\n")
  end

  def verse(number)
    verse_template.lyrics(number)
  end
end

class BottleVerse
  private_class_method :new

  def self.lyrics(number)
    new(number).lyrics
  end

  def initialize(number)
    @number = number
  end

  def lyrics
    bottle_number = BottleNumber.for(number)

    "#{bottle_number} of beer on the wall, ".capitalize +
    "#{bottle_number} of beer.\n" +
    "#{bottle_number.action}, " +
    "#{bottle_number.successor} of beer on the wall.\n"
  end

  private
  attr_reader :number
end

class BottleNumber
  def self.for(number)
    case number
    when 0
      BottleNumber0
    when 1
      BottleNumber1
    else
      BottleNumber
    end.new(number)
  end

  attr_reader :number
  def initialize(number)
    @number = number
  end

  def to_s
    "#{quantity} #{container}"
  end

  def quantity
    number.to_s
  end

  def container
    "bottles"
  end

  def action
    "Take #{pronoun} down and pass it around"
  end

  def pronoun
    "one"
  end

  def successor
    BottleNumber(number - 1)
  end
end

class BottleNumber0 < BottleNumber
  def quantity
    "no more"
  end

  def action
    "Go to the store and buy some more"
  end

  def successor
    99.to_bottle_number
  end
end

class BottleNumber1 < BottleNumber
  def container
    "bottle"
  end

  def pronoun
    "it"
  end
end
