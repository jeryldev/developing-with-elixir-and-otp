defmodule Servy.PledgeServer do
  @name :pledge_server

  use GenServer

  defmodule State do
    defstruct cache_size: 3, pledges: []
  end

  # Client Interface Functions

  def start do
    IO.puts("Starting the pledge server...")

    case GenServer.start(__MODULE__, %State{}, name: @name) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      error -> error
    end
  end

  def create_pledge(name, amount),
    do: GenServer.call(@name, {:create_pledge, name, amount})

  def recent_pledges(),
    do: GenServer.call(@name, :recent_pledges)

  def total_pledged(),
    do: GenServer.call(@name, :total_pledged)

  def clear(),
    do: GenServer.cast(@name, :clear)

  def set_cache_size(size),
    do: GenServer.cast(@name, {:set_cache_size, size})

  # Server Callbacks

  def init(state) do
    pledges = fetch_recent_pledges_from_service()
    new_state = %{state | pledges: pledges}
    {:ok, new_state}
  end

  def handle_call(:total_pledged, _from, state) do
    total = Enum.map(state.pledges, &elem(&1, 1)) |> Enum.sum()
    {:reply, total, state}
  end

  def handle_call(:recent_pledges, _from, state) do
    {:reply, state.pledges, state}
  end

  def handle_call({:create_pledge, name, amount}, _from, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent_pledges = Enum.take(state.pledges, state.cache_size - 1)
    cached_pledges = [{name, amount} | most_recent_pledges]
    new_state = %{state | pledges: cached_pledges}
    {:reply, id, new_state}
  end

  def handle_cast(:clear, state) do
    {:noreply, %{state | pledges: []}}
  end

  def handle_cast({:set_cache_size, size}, state) do
    resized_cache = Enum.take(state.pledges, size)
    new_state = %{state | cache_size: size, pledges: resized_cache}
    {:noreply, new_state}
  end

  def handle_info(message, state) do
    IO.puts("Can't touch this! #{inspect(message)}")
    {:noreply, state}
  end

  defp send_pledge_to_service(_name, _amount) do
    # CODE GOES HERE TO SEND PLEDGE TO EXTERNAL SERVICE
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

  defp fetch_recent_pledges_from_service do
    # CODE GOES HERE TO FETCH RECENT PLEDGES FROM EXTERNAL SERVICE

    # Example return value:
    [{"wilma", 15}, {"fred", 25}]
  end
end

# alias Servy.PledgeServer
# result = PledgeServer.start()

# case result do
#   {:ok, pid} ->
#     IO.inspect("pid")
#     IO.inspect(pid)
#     :sys.trace(pid, true) |> IO.inspect()
#     :sys.get_status(pid) |> IO.inspect()
#     send(pid, {:stop, "hammertime"})

#     PledgeServer.set_cache_size(4)

#     :sys.get_state(pid) |> IO.inspect()
#     IO.inspect(PledgeServer.create_pledge("ara", 300))
#     :sys.get_state(pid) |> IO.inspect()
#     # PledgeServer.clear()
#     # IO.inspect(PledgeServer.create_pledge("moe", 20))
#     # IO.inspect(PledgeServer.create_pledge("curly", 30))
#     # IO.inspect(PledgeServer.create_pledge("daisy", 40))
#     # IO.inspect(PledgeServer.create_pledge("grace", 50))

#     # IO.inspect(PledgeServer.create_pledge("grace", 50))

#     IO.inspect(PledgeServer.recent_pledges())

#     IO.inspect(PledgeServer.total_pledged())

#   error ->
#     IO.inspect("error")
#     IO.inspect(error)
# end
