defmodule ProtoDef.Type.Buffer do
  use ProtoDef.Type

  alias ProtoDef.Compiler.Preprocess

  defstruct count: nil, ident: nil, count_ident: nil

  def preprocess(args, ctx) do
    %__MODULE__{
      count: Preprocess.process_count(args, ctx),
    }
  end

  def structure(_descr, _ctx), do: __MODULE__

  def assign_vars(descr, num, ctx) do
    {count, count_ident, num} = ProtoDef.Compiler.AssignIdents.assign_count(descr.count, num, ctx)
    {ident, num} = ProtoDef.Compiler.AssignIdents.make_ident(num, ctx)
    descr = %{ descr |
      ident: ident,
      count_ident: count_ident,
      count: count,
    }
    {descr, ident, num}
  end

  def resolve_references(descr, parents, ctx) do
    count = ProtoDef.Compiler.Resolve.resolve_count(descr.count, parents, ctx)
    %{ descr |
      count: count,
    }
  end

end
