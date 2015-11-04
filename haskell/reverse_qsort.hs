reverse_qsort [] = []
reverse_qsort (x : xs) = reverse_qsort larger ++ [x] ++ reverse_qsort smaller
  where smaller = [a | a <- xs, a <= x]
        larger = [b | b <- xs, b > x]
