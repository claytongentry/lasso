defmodule Lasso.MixProject do
  use Mix.Project

  def project do
    [
      app: :lasso,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Lasso.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bandit, "~> 1.0-pre"},
      {:thousand_island, "~> 1.0-pre"},
      {:req, "~> 0.3.0", only: :test}
    ]
  end
end
