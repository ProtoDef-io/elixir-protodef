defmodule ProtoDef.Type.Bool do
  use ProtoDef.Type

  defstruct ident: nil

  def preprocess(nil, ctx) do
    %__MODULE__{}
  end

  def structure(_descr, _ctx), do: __MODULE__

  def assign_vars(descr, num, ctx) do
    {ident, num} = ProtoDef.Compiler.AssignIdents.make_ident(num, ctx)
    descr = %{ descr | ident: ident }
    {descr, ident, num+1}
  end

end
