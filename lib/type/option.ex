defmodule ProtoDef.Type.Option do
  use ProtoDef.Type

  alias ProtoDef.Compiler.Preprocess
  alias ProtoDef.Compiler.Structure

  defstruct type: nil, ident: nil

  def preprocess(args, ctx) do
    %__MODULE__{
      type: Preprocess.process_type(args, ctx),
    }
  end

  def structure(descr, ctx) do
    {:or, [:void, Structure.gen_for_type(descr.type, ctx)]}
  end

  def assign_vars(descr, num, ctx) do
    {type, ident, num} = ProtoDef.Compiler.AssignIdents.assign(descr.type, num, ctx)
    descr = %{ descr | type: type, ident: ident }
    {descr, ident, num+1}
  end

  def resolve_references(descr, parents, ctx) do
    type = ProtoDef.Compiler.Resolve.run(descr.type, parents, ctx)
    %{ descr |
      type: type,
    }
  end

  def decoder_ast(descr, ctx) do
    item_ast = ProtoDef.Compiler.GenAst.decoder(descr.type, ctx)
    quote do
      with do
        <<has_field::unsigned-integer-1*8, unquote(@data_var)::binary>> = unquote(@data_var)
        if has_field == 1 do
          unquote(item_ast)
        else
          {nil, unquote(@data_var)}
        end
      end
    end
  end

  def encoder_ast(descr, ctx) do
    item_ast = ProtoDef.Compiler.GenAst.encoder(descr.type, ctx)
    quote do
      with do
        has_field = if unquote(@input_var), do: 1, else: 0
        if has_field == 1 do
          [<<has_field::1*8>>, unquote(item_ast)]
        else
          <<has_field::1*8>>
        end
      end
    end
  end

end
