require 'ffi'

module LinkedList
  extend FFI::Library
  ffi_lib "linked_list.so"

  attach_function :create_node, [:int], :pointer
  attach_function :print_list, [:pointer], :void
  attach_function :search_list, [:pointer, :int], :pointer
  attach_function :insert_list, [:pointer, :int], :void
  attach_function :predecessor_list, [:pointer, :int], :pointer
  attach_function :delete_list, [:pointer, :int], :void

  class Node < FFI::Struct
    layout :value, :int,
           :next,  :pointer
  end
end

root = LinkedList.create_node(1)
LinkedList.insert_list(root, 2)
LinkedList.insert_list(root, 3)
LinkedList.insert_list(root, 4)
LinkedList.insert_list(root, 5)

ruby_root = LinkedList::Node.new(root)
puts ruby_root[:value]
while ruby_root[:value]
  puts ruby_root[:value]
  ruby_root = LinkedList::Node.new(ruby_root[:next])
end

node = LinkedList.search_list(root, 3)
ruby_node = LinkedList::Node.new(node)
puts ruby_node[:value]

if ruby_node_3
  puts "The value 3 exists in the list."
end

LinkedList.delete_list(root, 3)

node_x = LinkedList.search_list(root, 3)
ruby_node = LinkedList::Node.new(node_x)

puts ruby_node[:value]

unless ruby_node
  puts "The value 3 does not exists in the list."
end

LinkedList.print_list(root)
