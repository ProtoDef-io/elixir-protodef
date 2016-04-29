defmodule ProtoDef.Mixfile do
  use Mix.Project

  def project do
    [app: :proto_def,
     version: "0.0.3",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     description: description,
     package: package]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:poison, "~> 2.0"},
     {:estree, "~> 2.3"}] # TODO: Make this optional in some way (know about :optional, logistics?)
  end

  defp description do
    """
    ProtoDef compiler for Elixir.
    (mostly) Compatible with https://github.com/ProtoDef-io/ProtoDef.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["hansihe"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/ProtoDef-io/elixir-protodef"},
    ]
  end
end
