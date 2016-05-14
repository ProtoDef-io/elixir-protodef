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

end
