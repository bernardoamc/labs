# The proxy pattern is used when you want an object to stand between the client
# and a real object. The point is that the client doesn't know that this object
# is not the real one. This pattern is great for separation of concerns.
#
# The difference between the Adapter pattern and this one is that the Adapter
# pattern changes the interface of the real object, while the Proxy pattern
# don't change the real object interface, it just increment functionality with
# the objective of controlling the real object.
#
# Let's see an example:

class Game
  def initialize(player_name, score)
    @player_name = player_name
    @score = score
  end

  def run
    puts "Running game!"
  end
end

# Suppose that the game is not free anymore, but we don't want to change
# our Game class since it is working well and adding authentication/authorization
# is not really the job of a Game.

class GameProtectionProxy < BasicObject
  def initialize(game)
    @game = game
  end

  def method_missing(name, *args, &block)
    check_access
    @game.send(name, *args, &block)
  end

  def check_access
    ::Kernel.puts "Verifying user... access allowed!"
  end
end

game_proxy = GameProtectionProxy.new(Game.new("bernardo", 100))
game_proxy.run
