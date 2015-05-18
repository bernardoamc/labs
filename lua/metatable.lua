-- Using prototype inheritance
local prototype = { width = 50, height = 100 }
local metatable = {}

metatable.__index = prototype

local function new(object)
  setmetatable(object, metatable)

  return object
end

local window = new{ x = 10, y = 20 , height = 50 }
print(window.width, window.height, window.x, window.y)

-- Example of default values in a table
local function setDefault(object, default)
  local metatable = { __index = function () return default end }
  setmetatable(object, metatable)
end

local t = { x = 10, y = 20 }
print(t.x, t.y, t.z)

setDefault(t, 50)
print(t.x, t.y, t.z)
