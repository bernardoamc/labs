# Commands are useful for keeping a running list of things that your program
# needs to do, or for remembering what it has already done. You can also run
# your commands backward and undo the things that your program has done.
#
# The composite pattern can be used to execute multiple commands.
#
# An Activerecord migration is a good example of the command pattern,
# since it can be executed and knows how to reverse itself.
#
# Let's see an example:

class Door
  def initialize(command)
    @command = command
  end

  def open
    @command.execute if @command
  end
end

class CompositeCommand
  def initialize
    @commands = []
  end

  def add_command(command)
    @commands << command
  end

  def execute
    @commands.each { |command| command.execute }
  end
end

class Greet
  def execute
    puts "Hi!"
  end
end

class Yell
  def execute
    puts "Get out of here!"
  end
end

commands = CompositeCommand.new
commands.add_command(Greet.new)
commands.add_command(Yell.new)

Door.new(commands).open
