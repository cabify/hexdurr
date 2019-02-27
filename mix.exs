defmodule Hexdurr.MixProject do
  use Mix.Project

  def project do
    [
      app: :hexdurr,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      escript: [main_module: Hexdurr.CLI],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :inets, :ssl]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:hex_core, github: "hexpm/hex_core", branch: "emj/add-org-api"},
      {:yamerl, "~> 0.7.0"}
    ]
  end
end
