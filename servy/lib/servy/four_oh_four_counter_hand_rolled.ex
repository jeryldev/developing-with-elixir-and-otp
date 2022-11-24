defmodule Servy.FOFCGenericServer do
  # Client Interface functions

  def start(callback_module, initial_state, name) do
    pid = spawn(__MODULE__, :listen_loop, [initial_state, callback_module])
    Process.register(pid, name)
    pid
  end

  # Helper Functions

  def call(pid, message) do
    send(pid, {:call, self(), message})

    receive do
      {:response, response} -> response
    end
  end

  def cast(pid, message) do
    send(pid, {:cast, message})
  end

  # Server Functions

  def listen_loop(state, callback_module) do
    receive do
      {:call, sender, message} when is_pid(sender) ->
        {response, new_state} = callback_module.handle_call(message, state)
        send(sender, {:response, response})
        listen_loop(new_state, callback_module)

      {:cast, message} ->
        new_state = callback_module.handle_cast(message, state)
        listen_loop(new_state, callback_module)

      unexpected ->
        IO.puts("Unexpected message: #{inspect(unexpected)}")
        listen_loop(state, callback_module)
    end
  end
end

defmodule Servy.FourOhFourCounterHandRolled do
  @name :four_oh_four_counter_hand_rolled

  alias Servy.FOFCGenericServer

  # Client Interface functions

  def start do
    IO.puts("Starting the 404 counter")
    FOFCGenericServer.start(__MODULE__, %{}, @name)
  end

  def bump_count(path), do: FOFCGenericServer.call(@name, {:bump_count, path})

  def get_count(path), do: FOFCGenericServer.call(@name, {:get_count, path})

  def get_counts(), do: FOFCGenericServer.call(@name, :get_counts)

  def reset, do: FOFCGenericServer.cast(@name, :reset)

  # Server Callbacks

  def handle_call({:bump_count, path}, state) do
    new_state = Map.update(state, path, 1, &(&1 + 1))
    {:ok, new_state}
  end

  def handle_call({:get_count, path}, state) do
    count = Map.get(state, path, 0)
    {count, state}
  end

  def handle_call(:get_counts, state) do
    {state, state}
  end

  def handle_cast(:reset, _state) do
    %{}
  end
end

# alias Servy.FourOhFourCounterHandRolled, as: Counter

# pid = Counter.start()

# send(pid, {:stop, "testing stop"})

# IO.inspect(Counter.bump_count("/bigfoot"))
# IO.inspect(Counter.bump_count("/nessie"))
# IO.inspect(Counter.bump_count("/nessie"))
# IO.inspect(Counter.bump_count("/bigfoot"))

# IO.inspect("Counter.get_counts()")
# IO.inspect(Counter.get_counts())
# IO.inspect("Counter.get_count(\"/nessie\")")
# IO.inspect(Counter.get_count("/nessie"))

# Counter.reset()

# IO.inspect(Counter.bump_count("/nessie"))
# IO.inspect("Counter.get_counts()")
# IO.inspect(Counter.get_counts())
# IO.inspect("Counter.get_count(\"/nessie\")")
# IO.inspect(Counter.get_count("/nessie"))
