# Implement the repository pattern in the superclass and let the child classes register themselves
# We could also have used the inherited callback
# Extract #verse to BottleVerse and implement #lyrics instead of #verse
# Inject BottleVerse as a dependency in Bottles
# Rename Bottles to DescendingSong
class Bottles
  def song
    verses(99, 0)
  end

  def verses(starting, ending)
    starting.downto(ending).collect do |number|
      verse(number)
    end.join("\n")
  end

  def verse(number)
    bottle_number = BottleNumber.for(number)

    "#{bottle_number} of beer on the wall, ".capitalize +
    "#{bottle_number} of beer.\n" +
    "#{bottle_number.action}, " +
    "#{bottle_number.successor} of beer on the wall.\n"
  end
end

class BottleNumber
  def self.for(number)
    begin
      const_get("BottleNumber#{number}")
    rescue NameError
      BottleNumber
    end.new(number)
  end

  attr_reader :number
  def initialize(number)
    @number = number
  end

  def container
    "bottles"
  end

  def quantity
    number.to_s
  end

  def action
    "Take #{pronoun} down and pass it around"
  end

  def pronoun
    "one"
  end

  def successor
    BottleNumber.for(number - 1)
  end

  def to_s
    "#{quantity} #{container}"
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
    BottleNumber.for(99)
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

class BottleNumber6 < BottleNumber
  def quantity
    1
  end

  def container
    "six-pack"
  end
end
