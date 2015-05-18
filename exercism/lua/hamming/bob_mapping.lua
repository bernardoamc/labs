local map = {
  { '^$', 'Fine, be that way.' },
  { '^%L*$', 'Whoa, chill out!' },
  { '%?$', 'Sure' },
  { '', 'Whatever' }
}

local function hey(sentence)
  for _, m in pairs(map) do
    if sentence:find(m[1]) then return m[2] end
  end
end

return {
  hey = hey
}

