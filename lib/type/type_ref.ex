defmodule ProtoDef.Type.TypeRef do

  defstruct type_id: nil, args: nil, ident: nil

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

  def decoder_ast(descr, ctx) do
    type_descr = ProtoDef.Compiler.Context.type(ctx, descr.type_id)

    if type_descr == nil do
      raise ProtoDef.CompileError, message: "No TypeRef type found: #{descr.type_id}"
    end

    type_descr.gen_decoder.(descr.args, ctx)
  end

end
