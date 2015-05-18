local DNA = {}

local function parse(dna)
  local quantity = { A = 0, T = 0, C = 0, G = 0 }

  for letter in dna:gmatch('.') do
    quantity[letter] = quantity[letter] + 1
  end

  return quantity
end

function DNA.new(self, dna)
  local nucleotideCounts = parse(dna)

  local count = function(self, letter)
    return nucleotideCounts[letter] or error('Invalid Nucleotide')
  end

  return {
    count = count,
    nucleotideCounts = nucleotideCounts
  }
end

return DNA
