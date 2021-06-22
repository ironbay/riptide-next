defmodule Riptide.MixProject do
  use Mix.Project
  @version "0.5.1"

  def project do
    [
      app: :riptide,
      version: @version,
      description: "A data first framework for building realtime applications",
      package: [
        maintainers: ["thdxr", "ironbay"],
        licenses: ["MIT"],
        links: %{
          github: "https://github.com/ironbay/riptide-next",
          docs: "https://riptide.ironbay.co"
        }
      ],
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs()
    ]
  end

  def version_patch() do
    {result, 0} = System.cmd("git", ["rev-parse", "--short", "HEAD"])
    String.trim(result)
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Riptide.Application, []}
    ]
  end

  defp docs do
    [
      main: Riptide,
      logo: "logo.svg",
      canonical: "http://hexdocs.pm/riptide",
      extra_section: "Pages",
      source_url_pattern:
        "https://github.com/ironbay/riptide/tree/master/packages/elixir/%{path}#L%{line}",
      extras: [
        "guides/introduction/overview.md",
        "guides/introduction/getting-started.md"
      ],
      groups_for_extras: [
        Introduction: ~r/guides\/introduction\/.?/,
        "Core Concepts": ~r/guides\/core\/.?/
      ],
      nest_modules_by_prefix: [Riptide.Store],
      groups_for_modules: [
        Stores: [
          # Riptide.Store.Composite,
          # Riptide.Store.LMDB,
          # Riptide.Store.Memory,
          # Riptide.Store.Multi,
          # Riptide.Store.Postgres,
          # Riptide.Store.Riptide
        ]
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 2.7"},
      {:jason, "~> 1.1"},
      {:dynamic, "~> 0.1.2"},
      {:brine, "~> 0.2.2"},
      {:websockex, "~> 0.4.2"},
      {:bridge_lmdb, "~> 0.1.4", optional: true},
      {:postgrex, "~> 0.15.3", optional: true},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:credo, "~> 0.10.0", only: [:dev, :test], runtime: false}
    ]
  end
end
