class Foo; end
foo = Foo.new

p RubyVM.stat # => {:global_method_state=>133, :global_constant_state=>804, :class_serial=>5486}

# break a classes method cache. :class_serial will increase
foo.extend(Module.new { def bar; end })

p RubyVM.stat # => {:global_method_state=>133, :global_constant_state=>804, :class_serial=>5491}

# break Object's method cache. :global_method_state will increase
class Object
  def omb
  end
end

p RubyVM.stat # => {:global_method_state=>134, :global_constant_state=>804, :class_serial=>5491}

# break constant cache, :global_constant_state will increase
Object.send :remove_const, :Foo

p RubyVM.stat # => {:global_method_state=>134, :global_constant_state=>805, :class_serial=>5491}
