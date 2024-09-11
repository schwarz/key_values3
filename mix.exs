defmodule KeyValues3.MixProject do
  use Mix.Project

  @version "0.1.1"
  @url "https://github.com/schwarz/key_values3"
  def project do
    [
      app: :key_values3,
      version: @version,
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Parse KeyValues3 into Elixir values",
      package: package(),
      source_url: @url
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:nimble_parsec, "~> 1.4"}
    ]
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @url}
    ]
  end
end
