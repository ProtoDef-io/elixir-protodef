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

  def decoder_ast(descr, ctx) do
    quote do
      with do
        <<val::unsigned-integer-1*8, unquote(@data_var)::binary>> = unquote(@data_var)
        {val == 1, unquote(@data_var)}
      end
    end
  end

  def encoder_ast(descr, ctx) do
    quote do
      if unquote(@input_var) do
        <<1::1*8>>
      else
        <<0::1*8>>
      end
    end
  end

end
