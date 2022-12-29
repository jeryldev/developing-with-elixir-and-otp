defmodule Servy.Application do
  use Application

  def start(type, args) do
    IO.inspect("type: #{type}")
    message = Keyword.get(args, :message)
    target = Keyword.get(args, :target)
    default_interval = Keyword.get(args, :default_interval)
    IO.inspect(message)
    IO.inspect(target)
    IO.inspect(default_interval)
    IO.puts("Starting the application...")
    Servy.Supervisor.start_link()
  end
end
