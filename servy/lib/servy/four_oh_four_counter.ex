defmodule Servy.FourOhFourCounter do
  @name :four_oh_four_counter

  use GenServer

  # Client Interface functions

  def start_link(_args) do
    IO.puts("Starting the 404 counter...")

    case GenServer.start_link(__MODULE__, %{}, name: @name) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      error -> error
    end
  end

  def bump_count(path) do
    GenServer.call(@name, {:bump_count, path})
  end

  def get_count(path) do
    GenServer.call(@name, {:get_count, path})
  end

  def get_counts() do
    GenServer.call(@name, :get_counts)
  end

  def reset() do
    GenServer.cast(@name, :reset)
  end

  # Server Callbacks

  def init(state) do
    {:ok, state}
  end

  def handle_call({:bump_count, path}, _from, state) do
    new_state = Map.update(state, path, 1, &(&1 + 1))
    {:reply, :ok, new_state}
  end

  def handle_call({:get_count, path}, _from, state) do
    count = Map.get(state, path, 0)
    {:reply, count, state}
  end

  def handle_call(:get_counts, _from, state) do
    {:reply, state, state}
  end

  def handle_cast(:reset, _state) do
    {:noreply, %{}}
  end

  def handle_info(message, state) do
    IO.puts("Unexpected Message: #{inspect(message)}")
    {:noreply, state}
  end
end

# alias Servy.FourOhFourCounter, as: Counter

# case Counter.start() do
#   {:ok, pid} ->
#     send(pid, {:stop, "testing stop"})

#     IO.inspect(Counter.bump_count("/bigfoot"))
#     IO.inspect(Counter.bump_count("/nessie"))
#     IO.inspect(Counter.bump_count("/nessie"))
#     IO.inspect(Counter.bump_count("/bigfoot"))

#     IO.inspect("Counter.get_counts()")
#     IO.inspect(Counter.get_counts())
#     IO.inspect("Counter.get_count(\"/nessie\")")
#     IO.inspect(Counter.get_count("/nessie"))

#     Counter.reset()

#     IO.inspect(Counter.bump_count("/nessie"))
#     IO.inspect("Counter.get_counts()")
#     IO.inspect(Counter.get_counts())
#     IO.inspect("Counter.get_count(\"/nessie\")")
#     IO.inspect(Counter.get_count("/nessie"))

#   error ->
#     IO.inspect("error")
#     IO.inspect(error)
# end
