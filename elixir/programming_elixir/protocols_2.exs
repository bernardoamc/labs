# Any is a fallback if a type does not implement the protocol.

defprotocol Collection do
  @fallback_to_any true

  def is_collection?(value)
end

defimpl Collection, for: [List, Tuple, BitString] do
  def is_collection?(_), do: true
end

defimpl Collection, for: Any do
  def is_collection?(_), do: false
end

Enum.each [ 1, 1.0, [1,2], {1,2}, HashDict.new, "cat" ], fn value ->
  IO.puts "#{inspect value}: #{Collection.is_collection?(value)}"
end
