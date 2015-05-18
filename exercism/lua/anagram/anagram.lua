local Anagram = {}
Anagram.__index = Anagram

function Anagram.new(self, word)
  local self = setmetatable({}, self)
  self.word = self:sort_characters(word:lower())

  return self
end

function Anagram.sort_characters(self, word)
  local characters = {}

  for i = 1, #word do
    characters[i] = word:sub(i,i)
  end

  table.sort(characters)

  return table.concat(characters)
end

function Anagram.is_anagram(self, anagram)
  if #anagram ~= #self.word then
    return false
  end

  return self:sort_characters(anagram:lower()) == self.word
end

function Anagram.match(self, anagrams)
  local matches = {}

  for _, anagram in pairs(anagrams) do
    if self:is_anagram(anagram) then
      table.insert(matches, anagram)
    end
  end

  return matches
end

return Anagram
