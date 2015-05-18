local Words = {}
Words.__index = Words

function Words:new(sentence)
  local self = setmetatable({}, self)
  self.sentence = sentence

  return self
end

function Words:count()
  local words = {}

  for word in self.sentence:gmatch('%w+') do
    word = word:lower()
    words[word] = (words[word] or 0) + 1
  end

  for k, v in pairs(words) do
    words[k] = tostring(v)
  end

  return words
end

return Words
