defmodule Servy.Plugins do
  require Logger

  alias Servy.Conv
  alias Servy.FourOhFourCounter

  @doc """
  Logs 404 requests
  """
  def track(%Conv{status: 404, path: path} = conv) do
    # Logger.warn("Warning: #{path} is on the loose!")
    if Mix.env() != :test do
      IO.puts("Warning: #{path} is on the loose!")
      FourOhFourCounter.bump_count(path)
    end

    conv
  end

  def track(conv), do: conv

  def rewrite_path(%Conv{path: "/wildlife"} = conv),
    do: %{conv | path: "/wildthings"}

  def rewrite_path(%Conv{path: path} = conv) do
    regex = ~r{\/(?<thing>\w+)/\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    rewrite_path_captures(conv, captures)
  end

  def rewrite_path(%Conv{} = conv), do: conv

  def rewrite_path_captures(%Conv{} = conv, %{"thing" => thing, "id" => id}) do
    %{conv | path: "/#{thing}/#{id}"}
  end

  def rewrite_path_captures(%Conv{} = conv, nil), do: conv

  def log(%Conv{} = conv), do: IO.inspect(conv)
end
