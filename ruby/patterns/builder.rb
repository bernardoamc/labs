# The Builder patten is useful to make object construction easier and also
# good to create a valid object. So it basically deals with the boilerplate
# of creating the object and ensuring that it is valid.
#
# Let's see an example:

class Laptop
  attr_accessor :drives, :memory_size
  attr_reader :display

  def initialize
    @drives = []
    @display = :lcd
    @memory_size = 1000
  end
end

class LaptopDrive
  attr_reader :type

  def initialize(type, size, writer)
    @type = type
    @size = size
    @writer = writer
  end
end

class LaptopBuilder
  def initialize
    @laptop = Laptop.new
  end

  def display=(display)
    raise "Laptop display must be lcd" unless display == :lcd
  end

  def add_cd(writer=false)
    @laptop.drives << LaptopDrive.new(:cd, 760, writer)
  end

  def add_dvd(writer=false)
    @laptop.drives << LaptopDrive.new(:dvd, 4000, writer)
  end

  def add_hard_disk(size_in_mb)
    @laptop.drives << LaptopDrive.new(:hard_disk, size_in_mb, true)
  end

  def memory_size=(size_in_mb)
    @laptop.memory_size = size_in_mb
  end

  def laptop
    raise "Not enough memory" if @laptop.memory_size < 250
    raise "Too many drives" if @laptop.drives.size > 4

    hard_disk = @laptop.drives.find {|drive| drive.type == :hard_disk}
    raise "No hard disk." unless hard_disk

    @laptop
  end
end

builder = LaptopBuilder.new
builder.display = :lcd
builder.add_hard_disk(1000000)
builder.add_dvd
builder.memory_size = 2048
laptop = builder.laptop
p laptop
