defmodule ProtoDef.Compiler.Resolve do
  alias ProtoDef.Compiler.Count

  def run(descr, parents, ctx) do
    apply(descr.__struct__, :resolve_references, [descr, parents, ctx])
  end

  def resolve_parent({0, ident}, [result | _], _ctx), do: {result, ident}
  def resolve_parent({num_up, ident}, [_ | rest], ctx) do
    resolve_parent({num_up-1, ident}, rest, ctx)
  end

  def resolve_count(cnt, parents, ctx) do
    ProtoDef.Compiler.Count.resolve(cnt, parents, ctx)
  end

end
