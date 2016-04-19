# The Iterator pattern is used to provide a way for the outside world to access
# a collection of sub-objects within an object without exposing its underlying
# representation.
#
# It comes in two flavors.
#
# 1- External iterators (external object that is responsible for the iteration)
#   - Client drives the iteration.
#   - Iterators can be shared.
#
# 2- Internal iterators (occur inside the aggregate object)
#   - Simple to use.
#
# Let's see an example of both iterators:

# Internal Iterator, imagine this method is inside a class.
def for_each_element(arr)
  index = 0
  total = arr.size

  while index < total
    yield(arr[index])
    index += 1
  end
end

a = [10, 20, 30]
for_each_element(a) {|element| puts("The element is #{element}")}

# External iterator
class ArrayIterator
  def initialize(array)
    @array = array
    @index = 0
  end

  def has_next?
    @index < @array.size
  end

  def item
    @array[@index]
  end

  def next_item
    value = @array[@index]
    @index += 1

    value
  end
end

array = ['red', 'green', 'blue']
i = ArrayIterator.new(array)

while i.has_next?
  puts("item: #{i.next_item}")
end
