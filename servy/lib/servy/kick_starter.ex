defmodule Servy.KickStarter do
  alias Application
  use GenServer

  # Client Interface

  def start_link(_args) do
    IO.puts("Starting the kickstarter...")
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def get_server do
    GenServer.call(__MODULE__, :get_server)
  end

  # Server Callbacks

  def init(:ok) do
    Process.flag(:trap_exit, true)

    server_pid = start_server()

    {:ok, server_pid}
  end

  def handle_call(:get_server, _from, state) do
    {:reply, state, state}
  end

  def handle_info({:EXIT, _pid, reason}, _state) do
    IO.puts("HttpServer exited (#{inspect(reason)})")

    server_pid = start_server()

    {:noreply, server_pid}
  end

  defp start_server do
    port = Application.get_env(:servy, :port)
    IO.puts("Starting the HTTP server on port #{port}...")
    server_pid = spawn_link(Servy.HttpServer, :start, [port])
    Process.register(server_pid, :http_server)
    server_pid
    #
    # server_pid = spawn(Servy.HttpServer, :start, [4000])
    # Process.link(server_pid)
    #
    # The code above  can be shortened by using 'spawn_link' like the one below
    #
    # server_pid = spawn_link(Servy.HttpServer, :start, [4000])
    # Process.register(server_pid, :http_server)
    # server_pid
    #
    # Aside from registering the server_pid to a process called :http_server,
    # we could also get the access to the current HttpServer process by creating
    # a client interface function named 'get_server' as shown in this module
  end
end
