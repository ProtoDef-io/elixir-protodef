defmodule ProtoDef.Compiler.AssignIdents do

  def assign({:type_ref, _, _} = ref, counter, ctx) do
    {ident, counter} = make_ident(counter, ctx)
    {ref, ident, counter}
  end
  def assign(descr, counter, ctx) do
    apply(descr.__struct__, :assign_vars, [descr, counter, ctx])
  end

  def assign_count(count, num, ctx) do
    ProtoDef.Compiler.Count.assign(count, num, ctx)
  end

  def make_ident(num, ctx) do
    {String.to_atom("field_#{num}"), num+1}
  end

end
