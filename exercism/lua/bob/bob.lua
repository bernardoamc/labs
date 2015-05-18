local Bob = {}

function Bob.hey(str)
  if str == '' then
    return 'Fine, be that way.'
  elseif not str:find('[a-z]') then
    return 'Whoa, chill out!'
  elseif str:sub(-1) == '?' then
    return 'Sure'
  end

  return 'Whatever'
end

return Bob
