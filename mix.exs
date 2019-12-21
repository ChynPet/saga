defmodule Saga.MixProject do
  use Mix.Project

  def project do
    [
      app: :saga,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      applications: [
        :kafka_ex, :grpc
      ],
      mod: {Saga.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:grpc, github: "elixir-grpc/grpc"},
      {:gen_state_machine, "~> 2.0"},
      {:poison, "~> 3.1"},
      {:kafka_ex, "~> 0.10"}
    ]
  end
end
