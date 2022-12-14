defmodule Servy.Handler do
  @moduledoc """
  Handles HTTP requests.
  """

  alias Servy.Conv
  alias Servy.BearController
  # alias Servy.VideoCam
  # alias Servy.Tracker
  alias Servy.PledgeController
  alias Servy.FourOhFourCounter

  @pages_path Path.expand("pages", File.cwd!())

  # import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Plugins, only: [rewrite_path: 1, track: 1]
  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [handle_file: 2]
  # import Servy.View, only: [render: 3]

  @doc """
  Transforms the request into a response
  """
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    # |> log
    |> route
    |> track
    |> put_content_length
    |> format_response
  end

  def route(%Conv{method: "GET", path: "/404s"} = conv) do
    counts = FourOhFourCounter.get_counts()
    %{conv | status: 200, resp_body: inspect(counts)}
  end

  def route(%Conv{method: "GET", path: "/pledges/new"} = conv) do
    PledgeController.new(conv)
  end

  def route(%Conv{method: "POST", path: "/pledges"} = conv) do
    PledgeController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/pledges"} = conv) do
    PledgeController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/sensors"} = conv) do
    sensor_data = Servy.SensorServer.get_sensor_data()

    %{conv | status: 200, resp_body: inspect(sensor_data)}
    # render(conv, "sensors.eex", snapshots: snapshots, location: where_is_bigfoot)
  end

  def route(%Conv{method: "GET", path: "/kaboom"} = _conv) do
    raise "Kaboom!"
  end

  def route(%Conv{method: "GET", path: "/hibernate/" <> time} = conv) do
    time |> String.to_integer() |> :timer.sleep()

    %{conv | status: 200, resp_body: "Awake!"}
  end

  def route(%Conv{method: "GET", path: "/pages/" <> name} = conv) do
    test =
      @pages_path
      |> Path.join("#{name}.md")

    IO.inspect(test)

    @pages_path
    |> Path.join("#{name}.md")
    |> File.read()
    |> handle_file(conv)
    |> markdown_to_html()
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    Servy.Api.BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "POST", path: "/api/bears"} = conv) do
    Servy.Api.BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "DELETE", path: "/bears/" <> _id} = conv) do
    BearController.delete(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read()
    |> handle_file(conv)
  end

  # def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
  #   @pages_path
  #   |> Path.join("form.html")
  #   |> File.read()
  #   |> handle_file(conv)
  # end

  # def route(%Conv{method: "GET", path: "/pages/" <> file} = conv) do
  #   @pages_path
  #   |> Path.join(file <> ".html")
  #   |> File.read()
  #   |> handle_file(conv)
  # end

  def route(%Conv{path: path} = conv) do
    %{conv | status: 404, resp_body: "No #{path} here!"}
  end

  def format_response(%Conv{resp_body: resp_body} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    #{format_response_headers(conv)}
    \r
    #{resp_body}
    """
  end

  defp put_content_length(%Conv{resp_headers: resp_headers, resp_body: resp_body} = conv) do
    headers = Map.put(resp_headers, "Content-Length", byte_size(resp_body))
    %{conv | resp_headers: headers}
  end

  defp format_response_headers(%Conv{resp_headers: resp_headers} = _conv) do
    for {key, value} <- resp_headers do
      "#{key}: #{value}\r"
    end
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.join("\n")
  end

  defp markdown_to_html(%Conv{status: 200, resp_body: resp_body} = conv) do
    %{conv | resp_body: Earmark.as_html!(resp_body)}
  end

  defp markdown_to_html(%Conv{} = conv), do: conv
end
