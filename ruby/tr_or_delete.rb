tracer = TracePoint.new(:call, :c_call, :return, :c_return) do |tp|
  p [tp.path, tp.lineno, tp.event, tp.method_id]
#  if tp.event == :call || tp.event == :c_call || tp.event == :b_call
#    p [:call, tp.defined_class, tp.method_id]
#  elsif tp.event == :return || tp.event == :c_return || tp.event == :b_return
#    p [:return, tp.defined_class, tp.method_id]
#  end
end

string = 'a    b'

p "Delete:"
tracer.enable do
  string.delete(' ')
end
p '------------------------------------'

p "tr:"
tracer.enable do
  string.tr(' ', '')
end
