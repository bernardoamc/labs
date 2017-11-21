defmodule TelnetTest do
  use ExUnit.Case
  doctest Telnet

  test "accepts multiple connections" do
    {:ok, _socket} = create_client()
    {:ok, _socket} = create_client()
  end

  test "acknowledges command sent" do
    {:ok, socket} = create_client()
    :gen_tcp.send(socket, "COMMAND\n")

    assert "Command acknowledged\n" == receive_message(socket)
  end

  test "broadcasts to everyone except the sender" do
    {:ok, socket_1} = create_client()
    {:ok, socket_2} = create_client()
    {:ok, socket_3} = create_client()

    assert :ok == flush_sockets([socket_1, socket_2, socket_3])

    :ok = :gen_tcp.send(socket_3, "Yup!\n")

    assert "> Yup!\n" == receive_message(socket_1)
    assert "> Yup!\n" == receive_message(socket_2)
    refute "> Yup!\n" == receive_message(socket_3)
  end

  test "broadcasts when clients joins" do
    {:ok, socket_1} = create_client()
    {:ok, _socket_2} = create_client()

    assert "> Someone joined...\n" == receive_message(socket_1)
  end

  test "broadcasts when clients quits" do
    {:ok, socket_1} = create_client()
    {:ok, socket_2} = create_client()

    assert "> Someone joined...\n" == receive_message(socket_1)
    :gen_tcp.close(socket_1)
    assert "> Someone quit...\n" == receive_message(socket_2)
  end

  defp create_client do
    opts = [:binary, packet: :line, active: false]
    :gen_tcp.connect({127,0,0,1}, 4040, opts)
  end

  defp receive_message(socket) do
    {:ok, message} = :gen_tcp.recv(socket, 0, 1000)
    message
  end

  defp flush_sockets([]), do: :ok
  defp flush_sockets([socket | rest]) do
    flush_socket(socket)
    flush_sockets(rest)
  end

  defp flush_socket(socket) do
    case :gen_tcp.recv(socket, 0, 1000) do
      {:ok, _} ->
        flush_socket(socket)
      _ ->
        :ok
    end
  end
end
