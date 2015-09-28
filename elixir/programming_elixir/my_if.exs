# myif bla do
#   lala
# else
#   lele
# end
#
# Vai virar:
#
# myif bla,
#   do:   lala,
#   else: lele

defmodule My do
  defmacro if(condition, clauses) do
    do_clause   = Keyword.get(clauses, :do, nil)
    else_clause = Keyword.get(clauses, :else, nil)

    quote do
      case unquote(condition) do
        val when val in [false, nil] -> unquote(else_clause)
        _                            -> unquote(do_clause)
      end
    end
  end
end

defmodule Test do
  require My

  def check do
    My.if 10 == 10 do
      IO.puts "10 == 10"
    else
      IO.puts "10 != 10"
    end
  end
end

Test.check
