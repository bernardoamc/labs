defmodule TelnetTest do
  use ExUnit.Case
  doctest Telnet

  test "accepts multiple connections" do
    {:ok, _socket} = :gen_tcp.connect({127,0,0,1}, 4040, [])
    {:ok, _socket} = :gen_tcp.connect({127,0,0,1}, 4040, [])
  end

  test "acknowledges command sent" do
    {:ok, socket} = :gen_tcp.connect({127,0,0,1}, 4040, [])
    :gen_tcp.send(socket, "COMMAND\n")

    assert_receive {:tcp, ^socket, 'Command acknowledged\n'}, 2_000
  end

  test "broadcasts to everyone except the sender" do
    {:ok, socket_1} = :gen_tcp.connect({127,0,0,1}, 4040, [])
    {:ok, socket_2} = :gen_tcp.connect({127,0,0,1}, 4040, [])
    {:ok, socket_3} = :gen_tcp.connect({127,0,0,1}, 4040, [])

    Telnet.ClientsRegistry.broadcast(socket_3, "Yo!\n")

    socket_1_messages = messages_received(socket_1, timeout: 5_000)
    IO.inspect socket_1_messages
    assert String.contains?(
      socket_1_messages,
      "> Yo!\n"
    )

    socket_2_messages = messages_received(socket_2, timeout: 5_000)
    IO.inspect socket_2_messages
    assert String.contains?(
      socket_2_messages,
      "> Yo!\n"
    )

    socket_3_messages = messages_received(socket_3, timeout: 5_000)
    IO.inspect socket_3_messages
    refute String.contains?(
      socket_3_messages,
      "> Yo!\n"
    )
  end

  test "broadcasts when clients joins" do
    {:ok, socket_1} = :gen_tcp.connect({127,0,0,1}, 4040, [])
    {:ok, _socket_2} = :gen_tcp.connect({127,0,0,1}, 4040, [])

    assert_receive {:tcp, ^socket_1, '> Someone joined...\n'}, 3_000
  end

  test "broadcasts when clients quits" do
    {:ok, socket_1} = :gen_tcp.connect({127,0,0,1}, 4040, [])
    {:ok, socket_2} = :gen_tcp.connect({127,0,0,1}, 4040, [])

    :gen_tcp.close(socket_1)

    assert String.contains?(
      messages_received(socket_2, timeout: 5_000),
      "> Someone quit...\n"
    )
  end

 test "broadcats message sent by a client" do
    {:ok, socket_1} = :gen_tcp.connect({127,0,0,1}, 4040, [])
    {:ok, socket_2} = :gen_tcp.connect({127,0,0,1}, 4040, [])

    Telnet.Command.parse(socket_1, "Yo!\n")

    assert String.contains?(
      messages_received(socket_2, timeout: 5_000),
      "> Yo!\n"
    )
  end

  defp messages_received(pid, timeout: timeout) do
    List.to_string(
      messages_received(pid, timeout, [])
    )
  end

  defp messages_received(pid, timeout, messages) do
    receive do
      {:tcp, ^pid, message} ->
        messages = List.insert_at(messages, -1, message)
        messages_received(pid, timeout, messages)
      after
        timeout ->
          messages
    end
  end
end
