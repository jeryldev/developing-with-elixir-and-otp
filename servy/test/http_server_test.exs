defmodule HttpServerTest do
  use ExUnit.Case

  alias Servy.HttpServer
  alias Servy.HttpClient

  test "accepts a request on a socket and sends back a response using HTTPoison" do
    spawn(HttpServer, :start, [4000])
    IO.puts("#{inspect(self())}: Server 4000 started!")

    parent = self()
    max_concurrent_requests = 5

    # Spawn the client processes
    for _ <- 1..max_concurrent_requests do
      # Send the request
      {:ok, response} = HTTPoison.get("http://localhost:4000/wildthings")

      # Send the response back to the parent
      send(parent, {:ok, response})
    end

    IO.inspect("Process.info(parent, :messages)")
    IO.inspect(Process.info(parent, :messages))

    for _ <- 1..max_concurrent_requests do
      receive do
        {:ok, response} ->
          assert response.status_code == 200
          assert response.body == "Bears, Lions, Tigers"
      end
    end
  end

  test "accepts a request on a socket and sends back a response" do
    pid = spawn(HttpServer, :start, [5678])
    IO.puts("#{inspect(self())}: Server 5678 started!")

    request = """
    GET /wildthings HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = HttpClient.send_request(request)

    assert response == """
           HTTP/1.1 200 OK\r
           Content-Type: text/html\r
           Content-Length: 20\r
           \r
           Bears, Lions, Tigers
           """
  end
end
