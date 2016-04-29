defmodule ProtoDef.Type.TypeRef do

  use ProtoDef.Type

  defstruct kind: nil, make_encoder: nil, make_decoder: nil, args: nil, ident: nil,
  type_id: nil, encode: nil, decode: nil

  def preprocess_typeref(type_id, args, ctx) do
    type = ProtoDef.Compiler.Context.type(ctx, type_id)
    if type == nil do
      raise "Undefined typeref: #{type_id}"
    end
    inner_preprocess_typeref(type, type_id, args, ctx)
  end

  defp inner_preprocess_typeref({:inline, type}, _type_id, _args, ctx) do
    ProtoDef.Compiler.Preprocess.process_type(type, ctx)
  end
  defp inner_preprocess_typeref({:simple_gen, make_encoder, make_decoder}, type_id, args, ctx) do
    %__MODULE__{
      kind: :simple_gen,
      make_encoder: make_encoder,
      make_decoder: make_decoder,
      args: args,
      type_id: type_id,
    }
  end
  defp inner_preprocess_typeref({:simple, encode, decode}, type_id, args, ctx) do
    %__MODULE__{
      kind: :simple,
      encode: encode,
      decode: decode,
      args: args,
      type_id: type_id,
    }
  end

  def structure(type, _ctx), do: {:type_ref, type.type_id}

  def assign_vars(descr, num, ctx) do
    {ident, num} = ProtoDef.Compiler.AssignIdents.make_ident(num, ctx)
    descr = %{ descr |
      ident: ident,
    }
    {descr, ident, num}
  end

  def resolve_references(descr, _parents, _ctx) do
    descr
  end

end
