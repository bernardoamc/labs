# Command/Query Separation
#
# The problem:
# Suppose you want to create orders for an user if they don't exist yet.
#
# How would you do it? Remember, a command should not return a value.

def import_order(user, order_name, &on_success)
  unless user[:orders].include?(order_name)
    puts "Order #{order_name} created"
    on_success.call(user[:name], order_name)
  end
end

user = { name: 'xyz', orders: ['one', 'two'] }

import_order(user, 'three') do |user, order|
  puts "User #{user} has a new order called #{order}"
end

import_order(user, 'one') do |user, order|
  puts "User #{user} has a new order called #{order}"
end

puts '-' * 40

# The method above respects the CQS principle, but what if we want to
# deal with existing orders?

class ImportOrderStatus
  def self.success() new(:success) end
  def self.exists() new(:exists) end

  def initialize(status)
    @status = status
  end

  def on_success
    yield if @status == :success
  end

  def on_exists
    yield if @status == :exists
  end
end

def import_order_2(user, order_name, &callback)
  if user[:orders].include?(order_name)
    yield ImportOrderStatus.exists
  else
    yield ImportOrderStatus.success
  end
end

user2 = { name: 'xyz', orders: ['one', 'two'] }
order_name = 'three'

import_order_2(user2, order_name) do |result|
  result.on_success do
    puts "User #{user2[:name]} has a new order called #{order_name}!"
  end

  result.on_exists do
    puts "User #{user2[:name]} already has the order #{order_name}!"
  end
end

order_name = 'one'
import_order_2(user2, order_name) do |result|
  result.on_success do
    puts "User #{user2[:name]} has a new order called #{order_name}!"
  end

  result.on_exists do
    puts "User #{user2[:name]} already has the order #{order_name}!"
  end
end
