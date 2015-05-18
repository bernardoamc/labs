local t = { x = 5, y = 10 }
local _t = t
t = {}
local mt = { __index = function(_, k) return _t[k] end, __newindex = function(_, k, v) return error('nada disso malandro') end}
setmetatable(t, mt)
print(t.x)
t.oi = 'hello'
