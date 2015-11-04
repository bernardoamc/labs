my_length :: [a] -> Int
my_length [] = 0
my_length (x : xs) = 1 + my_length(xs)


my_sum :: Num a => [a] -> a
my_sum [] = 0
my_sum (x : xs) = x + my_sum(xs)

f xs = take 3 (reverse xs)
