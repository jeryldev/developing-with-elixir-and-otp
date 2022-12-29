defmodule Servy.MixProject do
  use Mix.Project

  def project do
    [
      app: :servy,
      description: "A humble HTTP server",
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :eex],
      # mod will start the Servy app when iex session is started (iex -S mix)
      # run 'mix run --no-halt' if we want to run the application at will
      mod:
        {Servy.Application,
         [
           message: "mix.exs > application function is called",
           target: "bigfoot",
           default_interval: 60
         ]},
      # add port 4000 to the _build/dev/lib/servy/ebin/servy.app
      # we can get the port through Application.get_env(:servy, :port)
      # or if we want to change the port: elixir --erl "-servy port 5000" -S mix run --no-halt
      env: [port: 4000]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:benchee, "~> 1.0", only: :dev},
      {:poison, "~> 5.0"},
      {:earmark, "~> 1.4"},
      {:httpoison, "~> 1.8"}
    ]
  end
end
