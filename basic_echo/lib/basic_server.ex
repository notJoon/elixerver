defmodule TcpEcho do
  use GenServer

  defmodule State do
    defstruct [:port, :socket]
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  def init(opts) do
    port = Keyword.get(opts, :port, 4050)
    send(self(), :init)

    {:ok, %State{port: port}}
  end

  @impl true
  def handle_info(:init, state) do
    {:ok, socket} = :gen_tcp.listen(state.port, [:binary, active: false, packet: 4])
    accept_loop(socket)
  end

  def accept_loop(socket) do
    {:ok, connection} = :gen_tcp.accept(socket)
    :gen_tcp.send(connection, "Hello, world!")
    :gen_tcp.close(connection)
    accept_loop(socket)
  end
end
