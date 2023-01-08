defmodule TcpEcho do

  require Logger

  @spec start_link(Keyword.t) :: {:ok, pid}
  def start_link(opts) do
    {:ok, spawn_link(__MODULE__, :init, [opts])}
  end

  @spec init(Keyword.t) :: no_return
  def init(opts) do
    port = Keyword.get(opts, :port, 4050)

    {:ok, socket} = :gen_tcp.listen(port, [:binary, active: false])

    accept_loop(socket)
  end

  @spec accept_loop(socket :: :gen_tcp.socket()) :: :ok | {:error, any()}
  def accept_loop(socket) do
    {:ok, connection} = :gen_tcp.accept(socket)
    echo_loop(connection)
    accept_loop(socket)
  end

  @spec echo_loop(connection :: :gen_tcp.socket()) :: :ok | {:error, any()}
  def echo_loop(connection) do
    case :gen_tcp.recv(connection, 0) do
      {:ok, packet} ->
        Logger.debug recv: packet
        :gen_tcp.send(connection, packet)
        echo_loop(connection)
      {:error, error} ->
        Logger.error error: error
    end
  end

end
