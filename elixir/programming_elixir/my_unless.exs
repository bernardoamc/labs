defmodule My do
  defmacro unless(expression, clauses) do
    do_clause = Keyword.get(clauses, :do, nil)
    else_clause = Keyword.get(clauses, :else, nil)

    quote do
      if unquote(!expression) do
        unquote(do_clause)
      else
        unquote(else_clause)
      end
    end
  end
end

defmodule Test do
  require My

  def test do
    My.unless 5 <> 10 do
      IO.puts "5 <> 10"
    else
      IO.puts "5 == 10"
    end

    My.unless 5 == 6 do
      IO.puts "5 == 6"
    else
      IO.puts "5 <> 6"
    end
  end
end

Test.test
