local School = {}
School.__index = School

function School:new()
  local self = setmetatable({}, self)
  self.students = setmetatable({}, { __index = function() return {} end })

  return self
end

function School:add(name, grade)
  self.students[grade] = self.students[grade]
  table.insert(self.students[grade], name)
  table.sort(self.students[grade])
end

function School:grade(grade)
  return self.students[grade]
end

function School:roster()
  return self.students
end

return School
