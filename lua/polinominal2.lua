function exp(answer, value, p)
  if p == 0 then
    return answer
  else
    answer = answer * value
    return exp(answer, value, p-1)
  end
end

values = {4, 3, 2}
x = 2
total = 0

for i = 1 , #values do
  total = total + values[i] * exp(1, x, i-1)
end

print(total)
