defmodule BSONEach.Mixfile do
  use Mix.Project

  @version "0.3.1"

  def project do
    [app: :bsoneach,
     description: "Applies a function to each document in a BSON file.",
     package: package,
     version: @version,
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: [coveralls: :test],
     docs: [source_ref: "v#{@version}", main: "readme", extras: ["README.md"]]]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:faker, "~> 0.6", only: [:dev, :test]},
     {:benchfella, "~> 0.3", only: [:dev, :test]},
     {:ex_doc, ">= 0.0.0", only: [:dev, :test]},
     {:excoveralls, "~> 0.5", only: [:dev, :test]},
     {:dogma, "> 0.1.0", only: [:dev, :test]},
     {:credo, ">= 0.4.8", only: [:dev, :test]}]
  end

  defp package do
    [contributors: ["Andrew Dryga"],
     maintainers: ["Andrew Dryga"],
     licenses: ["MIT"],
     links: %{github: "https://github.com/Nebo15/bsoneach"},
     files: ~w(lib LICENSE.md mix.exs README.md)]
  end
end
