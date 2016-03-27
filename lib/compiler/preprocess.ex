defmodule ProtoDef.Compiler.Preprocess do

  def from_type_def([type_id, args]), do: from_type_def({type_id, args})
  def from_type_def({type_id, args}), do: {type_id, args}
  def from_type_def(type_id), do: {type_id, nil}

  def process_type(nil, _ctx) do
    raise ProtoDef.CompileError, message: "Undefined type"
  end
  def process_type(type, ctx) do
    {type_id, args} = from_type_def(type)
    type_mod = ProtoDef.Compiler.Context.native_type(ctx, type_id)
    if type_mod do
      apply(type_mod, :preprocess, [args, ctx])
    else
      ProtoDef.Type.TypeRef.preprocess_typeref(type_id, args, ctx)
    end
  end

  def process_field_ref(field_ref, ctx, sibling_only \\ false) do
    proc_ref = count_field_ref_dirup(field_ref)
    if sibling_only do
      {0, _} = proc_ref
    else
      proc_ref
    end
  end

  def count_field_ref_dirup(str), do: count_field_ref_dirup(str, 0)
  defp count_field_ref_dirup("../" <> str, num), do: count_field_ref_dirup(str, num+1)
  defp count_field_ref_dirup(str, num), do: {num, String.to_atom(str)}

  def process_count(cont, ctx) do
    ProtoDef.Compiler.Count.preprocess(cont, ctx)
  end

  def process_get_arg(map, ctx, name) do
    map[name]
  end

end
