defmodule FourOhFourCounterHandRolledTest do
  use ExUnit.Case

  alias Servy.FourOhFourCounterHandRolled, as: Counter

  test "reports counts of missing path requests" do
    IO.inspect("Servy.FourOhFourCounterHandRolled")
    Counter.start()

    Counter.bump_count("/bigfoot")
    Counter.bump_count("/nessie")
    Counter.bump_count("/nessie")
    Counter.bump_count("/bigfoot")
    Counter.bump_count("/nessie")

    assert Counter.get_count("/nessie") == 3
    assert Counter.get_count("/bigfoot") == 2

    assert Counter.get_counts() == %{"/bigfoot" => 2, "/nessie" => 3}
  end
end
