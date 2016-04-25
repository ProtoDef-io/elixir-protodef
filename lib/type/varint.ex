defmodule ProtoDef.Type.Varint do
  use ProtoDef.Type

  defstruct ident: nil

  def preprocess(nil, _ctx) do
    %__MODULE__{}
  end

  def structure(_type, _ctx), do: __MODULE__

  def assign_vars(descr, num, ctx) do
    {ident, num} = ProtoDef.Compiler.AssignIdents.make_ident(num, ctx)
    descr = %{ descr |
      ident: ident,
    }
    {descr, ident, num}
  end

end
