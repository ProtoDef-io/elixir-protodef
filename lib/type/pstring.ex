defmodule ProtoDef.Type.PString do
  alias ProtoDef.Compiler.Preprocess

  @behaviour ProtoDef.Type

  defstruct count: nil

  def preprocess(args, ctx) do
    %__MODULE__{
      count: Preprocess.process_count(args, ctx),
    }
  end
end
