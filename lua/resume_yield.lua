local co = coroutine.create(function (a, b, c)
  print('co', a, b, c)
end)

coroutine.resume(co, 1, 2, 3)

--
--

local co2 = coroutine.create(function (a, b)
  coroutine.yield(a + b, a - b)
end)

print(coroutine.resume(co2, 1, 2))
print(coroutine.resume(co2))
print(coroutine.resume(co2))

--
--

local co3 = coroutine.create(function (a)
  print('co3', a)
  print('co3', coroutine.yield())
  return 'ricardo'
end)

coroutine.resume(co3, 'foca')
print(coroutine.resume(co3, 'rico', 'tamandua'))
