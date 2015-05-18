math.randomseed(os.time())

local chars = { lower = 97, upper = 122 }
local numbers = { lower = 48, upper = 57 }
local generatedNames = {}

local Robot = {}
Robot.__index = Robot

local function char()
  return math.random(chars.lower, chars.upper)
end

local function number()
  return math.random(numbers.lower, numbers.upper)
end

local function generateName()
  local newName = ''

  repeat
    newName = string.char(char(), char(), number(), number(), number())
  until generatedNames[newName] == nil

  generatedNames[newName] = 1

  return newName
end

function Robot:new()
  local self = setmetatable({}, self)
  self.name = generateName()

  return self
end

function Robot:reset()
  self.name = generateName()
end

return Robot
