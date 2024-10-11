defmodule Approval.MixProject do
  use Mix.Project

  @version "0.1.0"

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
        extras: ["README.md"]
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
      files: ~w(lib priv .formatter.exs mix.exs README* readme* LICENSE*
                license* CHANGELOG* changelog* src),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/tmbb/approval"}
    ]
  end
end
