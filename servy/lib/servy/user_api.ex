defmodule Servy.UserApi do
  def query(id) when is_binary(id) do
    api_url(id)
    |> HTTPoison.get()
    |> handle_response
  end

  def query(_id), do: IO.puts("id should be a binary.")

  defp api_url(id) do
    "https://jsonplaceholder.typicode.com/users/#{URI.encode(id)}"
  end

  defp handle_response({:ok, %{status_code: 200, body: body}}) do
    city = Poison.Parser.parse!(body, %{}) |> get_in(["address", "city"])

    {:ok, city}
  end

  defp handle_response({:ok, %{status_code: _status_code, body: body}}) do
    message = Poison.Parser.parse!(body, %{}) |> get_in(["message"])

    {:error, message}
  end
end
