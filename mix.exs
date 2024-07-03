defmodule Lasso.MixProject do
  use Mix.Project

  @github "https://github.com/claytongentry/lasso"

  def project do
    [
      app: :lasso,
      version: "0.1.2",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "Lasso",
      source_url: @github
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
      {:bandit, "~> 1.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:req, "~> 0.3.0", only: :test}
    ]
  end

  defp description() do
    "Simulate remote HTTP services with local Bandit servers."
  end

  defp package() do
    [
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE.md CHANGELOG.md),
      licenses: ["MIT"],
      links: %{"GitHub" => @github}
    ]
  end
end
