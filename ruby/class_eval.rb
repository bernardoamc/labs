class Foo
  METHODS = %w(hi bye)

  puts self

  METHODS.each do |method_name|
    class_eval <<-EOT, __FILE__, __LINE__ + 1
      puts self

      def #{method_name}(*args, &block)
        puts args.inspect
        puts "#{method_name}"
      end
    EOT
  end
end

Foo.new.hi
Foo.new.bye
