def add_preload
  old_preload_proc = lambda do |obj, args, ctx|
    p obj, args, ctx
  end

  lambda do |obj, args, ctx|
    yield(obj, args, ctx)
    old_preload_proc&.call(obj, args, ctx)
  end
end

la = add_preload { |obj, _, _| p obj; p 'My custom block ya' }
la.call('a', 'b', 'c')
