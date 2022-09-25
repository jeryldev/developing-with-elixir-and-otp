defmodule Servy.Recurse do
  def loopy([head | tail]) do
    IO.puts("Head: #{head} Tail: #{inspect(tail)}")
    loopy(tail)
  end

  def loopy([]), do: IO.puts("Done!")

  def sum(_list_of_numbers, total \\ 0)

  def sum([head | tail], total) do
    sum(tail, total + head)
  end

  def sum([], total), do: total

  # Without_accumulator
  def thrice([head | tail]) do
    [head * 3 | triple(tail)]
  end

  def thrice([]), do: []

  # With Accumulator
  def triple(_list_of_numbers, current_list \\ [])

  def triple([head | tail], current_list) do
    triple(tail, [head * 3 | current_list])
  end

  def triple([], current_list), do: current_list |> Enum.reverse()

  def my_map([head | tail], fun) do
    [fun.(head) | my_map(tail, fun)]
  end

  def my_map([], _fun), do: []
end

# Servy.Recurse.loopy([1, 2, 3, 4, 5])
# sum_1 = Servy.Recurse.sum([1, 2, 3, 4, 5])
# sum_2 = Servy.Recurse.sum([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])

# IO.inspect(sum_1)
# IO.inspect(sum_2)

# my_map_1 = Servy.Recurse.my_map([1, 2, 3, 4, 5], &(&1 * 5))

# IO.inspect(my_map_1)
