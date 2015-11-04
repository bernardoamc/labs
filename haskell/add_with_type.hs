add :: (Int, Int) -> Int
add (x, y) = x + y


-- curry_add expects an Int x and returns a function curry_add x,
-- that function in turn expects an Int y and returns the result x + y.
curry_add :: Int -> (Int -> Int)
curry_add x y = x + y
