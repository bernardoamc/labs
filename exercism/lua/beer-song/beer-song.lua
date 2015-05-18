local Beer = {}

local function build(n)
  local bottle = ( n > 2 and 'bottles') or 'bottle'

  return ('%d bottles of beer on the wall, %d bottles of beer.\nTake one down and pass it around, %d %s of beer on the wall.\n'):format(n, n, n-1, bottle)
end

local function one()
  return "1 bottle of beer on the wall, 1 bottle of beer.\nTake it down and pass it around, no more bottles of beer on the wall.\n"
end

local function zero()
  return "No more bottles of beer on the wall, no more bottles of beer.\nGo to the store and buy some more, 99 bottles of beer on the wall.\n"
end

function Beer.sing(from, to)
  local answer = {}
  to = to or 0

  for i = from, to, -1 do
    table.insert(answer, Beer.verse(i))
  end

  return table.concat(answer, '\n')
end

function Beer.verse(n)
  if n > 1 then
    return build(n)
  elseif n == 1 then
    return one()
  else
    return zero()
  end
end

return Beer
