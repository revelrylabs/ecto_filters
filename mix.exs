defmodule Ecto.Filters.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecto_filters,
      version: "0.2.1",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      name: "Ecto Filters",
      source_url: "https://github.com/revelrylabs/ecto_filters",
      homepage_url: "https://github.com/revelrylabs/ecto_filters",
      docs: [main: "readme", extras: ["README.md"]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    "Adds function to transform request params into ecto query expressions."
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.1.1", only: [:test]},
      {:ex_doc, ">= 0.0.0", only: [:dev, :test]},
      {:mix_test_watch, "~> 0.8", only: [:dev, :test], runtime: false}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE", "CHANGELOG.md"],
      maintainers: ["Revelry Labs"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/revelrylabs/ecto_filters"
      },
      build_tools: ["mix"]
    ]
  end
end
