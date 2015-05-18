values = {4, 3, 2}
x = 2
total = 0

for i = 1 , #values do
  total = total + values[i] * x^(i-1)
end

print(total)
