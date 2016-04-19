# The composite pattern is used when you want to build an hierarchy or
# a tree of objects, but you don't want to worry if you are dealing with
# a single object or an entire branch.
#
# To use this pattern we need to identify what the objects have in common.
#
# We need to have:
#
# 1- A base class or interface to represent a component.
# 2- Leaf objects (the simple, indivisible building blocks of the process)
# 3- The composite (built from sub-components)
#
# Let's see an example:

class Task
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def get_value
    0.0
  end
end

class BuyPaintTask < Task
  def initialize
    super('Buy paint')
  end

  def get_value
    2.0
  end
end

class MixPaintsTask < Task
   def initialize
    super('Mix paints')
  end

  def get_value
    1.0
  end
end

class CompositeTask < Task
  def initialize(name)
    super(name)
    @sub_tasks = []
  end

  def add_sub_task(task)
    @sub_tasks << task
  end

  def remove_sub_task(task)
    @sub_tasks.delete(task)
  end

  def get_value
    value = 0.0
    @sub_tasks.each { |task| value += task.get_value }
    value
  end
end

class PaintWall < CompositeTask
  def initialize(name)
    super(name)
    add_sub_task(BuyPaintTask.new)
    add_sub_task(MixPaintsTask.new)
  end
end

puts PaintWall.new('Paint Wall').get_value
