# ProtoDef

ProtoDef compiler written in Elixir.

(mostly) Compatible with https://github.com/ProtoDef-io/ProtoDef.

## Installation

elixir-protodef is availible in [Hex](https://hex.pm/packages/proto_def). The package can be installed as:

  1. Add proto_def to your list of dependencies in `mix.exs`:

        def deps do
          [{:proto_def, "~> 0.0.1"}]
        end

  2. Ensure proto_def is started before your application:

        def application do
          [applications: [:proto_def]]
        end

