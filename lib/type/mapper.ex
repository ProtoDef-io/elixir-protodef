defmodule ProtoDef.Type.Mapper do
  alias ProtoDef.Compiler.Preprocess

  @behaviour ProtoDef.Type

  defstruct type: nil, mappings: %{}
  defmodule Item do
    defstruct raw_match: nil, type: nil
  end

  def preprocess(args, ctx) do
    type = Preprocess.process_type(args["type"], ctx)

    mappings = args["mappings"]
    |> Enum.map(fn {match, value} ->
      %Item{
        raw_match: match,
        type: Preprocess.process_type(value, ctx),
      }
    end)

    %__MODULE__{
      type: type,
      mappings: mappings,
    }
  end

end
