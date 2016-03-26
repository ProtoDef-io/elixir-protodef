defmodule ProtoDef.Compiler.Structure do
  
  def gen_for_type({:type_ref, typ, _}, _ctx), do: {:type_ref, typ}
  def gen_for_type(type, ctx) do
    apply(type.__struct__, :structure, [type, ctx])
  end

end
