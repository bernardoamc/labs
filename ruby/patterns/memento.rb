# The memento pattern is used to fetch the state of an object, it's like
# taking a snapshot.
#
# It can be used to restore the object to a previous state or to access the
# object data when the object doesn't expose it directly. This data can
# be used in a view, for example.
#
# Let's see an example:

class Order
  def initialize(name, value)
    @name = name
    @value = value
  end

  def update_value(new_value)
    @value = new_value
  end

  def snapshot
    OrderSnapshot.new(@name, @value)
  end
end

class OrderSnapshot
  attr_reader :name, :value

  def initialize(name, value)
    @name = name
    @value = value
  end
end

order = Order.new("Hoverboard", 200)
snapshot = order.snapshot
order.update_value(250)

p order
p snapshot
