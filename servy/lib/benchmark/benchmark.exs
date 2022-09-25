tasks_result =
  [
    Task.async(fn -> Enum.to_list(1..5) end),
    Task.async(fn -> Enum.to_list(1..10) end),
    # Task.async(fn -> Enum.to_list(1..50) end),
    # Task.async(fn -> Enum.to_list(1..100) end)
  ]
  |> Task.await_many()

numbers_list_map =
  # [:five, :ten, :fifty, :hundred]
  [:five, :ten ]
  |> Enum.zip(tasks_result)
  |> Enum.into(%{})

Benchee.run(%{
  # "thrice - five" => fn -> Servy.Recurse.thrice(numbers_list_map.five) end,
  "thrice - ten" => fn -> Servy.Recurse.thrice(numbers_list_map.ten) end,
  # "triple - five" => fn -> Servy.Recurse.triple(numbers_list_map.five) end,
  "triple - ten" => fn -> Servy.Recurse.triple(numbers_list_map.ten) end
})
