defmodule ProtoDef.Type.Void do
  use ProtoDef.Type

  defstruct ident: nil

  def preprocess(nil, _ctx) do
    %__MODULE__{}
  end

  def structure(_, _ctx), do: :void

  def assign_vars(descr, num, ctx) do
    {ident, num} = ProtoDef.Compiler.AssignIdents.make_ident(num, ctx)
    descr = %{ descr |
      ident: ident,
    }
    {descr, ident, num}
  end

  def decoder_ast(descr, ctx) do
    quote do
      {nil, unquote(@data_var)}
    end
  end

  def encoder_ast(descr, ctx) do
    quote do
      <<>>
    end
  end
end
