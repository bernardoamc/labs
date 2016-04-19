# Used to track changes in a source object (observable) and notify target
# objects (observers) about the change. It solves the problem without
# coupling both objects. It is like the Strategy patterns since the
# intention is to call another object to do something, but the intention
# is different.
#
# Let's see an example:

module Observable
  def initialize
    @observers = []
  end

  def add_observer(observer)
    @observers << observer
  end

  def remove_observer(observer)
    @observers.delete(observer)
  end

  def notify_observers
    @observers.each do |observer|
      observer.update(self)
    end
  end
end

class Player
  include Observable

  attr_reader :position

  def initialize(position)
    super()
    @position = position
  end

  def position=(position)
    @position = position
    notify_observers
  end
end

class MiniMap
  def update(player)
    puts "Set player position to #{player.position}"
  end
end

class Enemy
  def update(player)
    puts "Aim at #{player.position}"
  end
end

player = Player.new(100)
player.add_observer(MiniMap.new)
player.add_observer(Enemy.new)

player.position = 120
