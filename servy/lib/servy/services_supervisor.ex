defmodule Servy.ServicesSupervisor do
  use Supervisor

  def start_link(_args) do
    IO.puts("Starting the services supervisor...")
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      Servy.PledgeServer,
      # %{
      #   id: Servy.SensorServer,
      #   start: {Servy.SensorServer, :start_link, [[interval: 60, target: "bigfoot"]]}
      # }
      {Servy.SensorServer, :infrequent},
      Servy.FourOhFourCounter
    ]

    opts = [strategy: :one_for_one]

    Supervisor.init(children, opts)
  end
end
