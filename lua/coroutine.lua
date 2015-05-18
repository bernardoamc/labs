--[[
  Coroutines:

  They are like threads, they have it's own stack, variables and instruction
  pointer; but shares global variables, for example.

  They do not run in parallel, a program with multiple coroutines will run only
  a single coroutine at any given time.

  Possible status: suspended, running, dead, normal (when a routine resumes another one).

  Uses:
    - producer/consumer
    - pipes
    - iterators
]]--

local co = coroutine.create(function ()
  for i = 1, 3 do
    print('co', i)
    coroutine.yield()
  end
end)

print(coroutine.status(co))

coroutine.resume(co)
print(coroutine.status(co))

coroutine.resume(co)
print(coroutine.status(co))

coroutine.resume(co)
print(coroutine.status(co))

coroutine.resume(co)
print(coroutine.status(co))

print(coroutine.resume(co))
