defprotocol Inspect do
  def inspect(thing, opts)
end

defimpl Inspect, for: PID do
  def inspect(pid, _opts) do
    IO.puts "#PID" <> :erlang.iolist_to_binary(:erlang.pid_to_list(pid))
  end
end

defimpl Inspect, for: Reference do
  def inspect(ref, _opts) do
    '#Ref' ++ rest = :erlang.ref_to_list(ref)
    "#Reference" <> :erlang.iolist_to_binary(rest)
  end
end

# Finally, the Kernel module implements inspect, which calls Inspect.inspect with its
# parameter. This means that when you call inspect(self), it becomes a call to
# Inspect.inspect(self).

inspect self
