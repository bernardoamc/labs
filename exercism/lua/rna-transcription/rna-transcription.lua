local mapping = { C = 'G', G = 'C', A = 'U', T = 'A' }

local function toRna(dna)
  local rna = {}

  for letter in dna:gmatch('.') do
    table.insert(rna, mapping[letter])
  end

  return table.concat(rna, '')
end

return toRna
