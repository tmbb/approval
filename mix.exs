defmodule Approval.MixProject do
  use Mix.Project

  @version "0.2.1"

  def project do
    [
      app: :approval,
      version: @version,
      elixir: "~> 1.16",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [
        assets: %{"assets" => "assets"},
        extras: ["README.md"],
        main: "Approval"
      ],
      package: package(),
      name: "Approval",
      description: "Lightweight approval testing for Elixir",
      source_url: "https://github.com/tmbb/approval"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :eex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp package() do
    [
      # These are the default files included in the package
      files: ~w(lib priv .formatter.exs mix.exs README* LICENSE* CHANGELOG*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/tmbb/approval"}
    ]
  end
end
