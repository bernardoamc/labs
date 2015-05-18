function multipleVars(a, ...)
  local b, c = ...
  print(a)
  print(b)
  print(c)
end

multipleVars("ola", 1, 2, 3)


function a(c)
  local f = c.uhul or 3
  print(f)
end

a({ bla = 5, aha = 6})
