defmodule Servy.BearController do
  alias Servy.Bear
  alias Servy.Wildthings
  alias Servy.BearView

  # import Servy.View, only: [render: 3]

  def index(conv) do
    bears =
      Wildthings.list_bears()
      |> Enum.sort(&Bear.order_asc_by_name/2)

    # render(conv, "index.eex", bears: bears)
    %{conv | status: 200, resp_body: BearView.index(bears)}
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)

    # render(conv, "show.eex", bear: bear)
    %{conv | status: 200, resp_body: BearView.show(bear)}
  end

  def create(conv, %{"type" => type, "name" => name}) do
    %{
      conv
      | status: 201,
        resp_body: "Create a #{type} bear named #{name}!"
    }
  end

  def create(conv, %{}), do: conv

  def delete(conv, _params) do
    %{conv | status: 403, resp_body: "Deleting a bear is forbidden!"}
  end
end
