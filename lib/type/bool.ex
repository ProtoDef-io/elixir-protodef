defmodule ProtoDef.Type.Bool do
  use ProtoDef.Type

  defstruct ident: nil

  def preprocess(nil, ctx) do
    %__MODULE__{}
  end

  def structure(_descr, _ctx), do: :bool

  def assign_vars(descr, num, ctx) do
    {ident, num} = ProtoDef.Compiler.AssignIdents.make_ident(num, ctx)
    descr = %{ descr | ident: ident }
    {descr, ident, num+1}
  end

  def decoder_ast(descr, ctx) do
    quote do
      with do
        <<val::unsigned-integer-1*8, data::binary>> = data
        {val == 1, data}
      end
    end
  end

end
