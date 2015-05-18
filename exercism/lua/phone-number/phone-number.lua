local function digits(phone)
  local numbers = {}

  for n in phone:gmatch('%d') do
    table.insert(numbers, n)
  end

  return numbers
end

local function validate(digits)
  local size = #digits

  if (size == 11 and digits[1] == '1') or size == 10 then
    -- Just return the last ten numbers
    return table.concat(digits, '', size - 9, size)
  else
    return string.rep('0', 10)
  end
end

local Phone = { }
Phone.__index = Phone

function Phone:new(phone)
  local self = setmetatable({}, self)
  self.digits = digits(phone)
  self.number = validate(self.digits)

  return self
end

function Phone:areaCode()
  return self.number:sub(1,3)
end

function Phone:toString()
  return string.format('(%s) %s-%s', self.number:sub(1,3), self.number:sub(4,6), self.number:sub(7))
end

return Phone
