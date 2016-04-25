defmodule ProtoDef.Type.Array do
  alias ProtoDef.Compiler.Preprocess

  use ProtoDef.Type

  @no_type_error "Array was without type field"

  defstruct type: nil, count: nil,
  ident: nil, count_ident: nil, child_ident: nil

  def preprocess(args, ctx) do
    type = args["type"]

    if !type do
      raise ProtoDef.CompileError, message: @no_type_error
    end

    %__MODULE__{
      type: Preprocess.process_type(type, ctx),
      count: Preprocess.process_count(args, ctx),
    }
  end

  def structure(descr, ctx) do
    {:array, ProtoDef.Compiler.Structure.gen_for_type(descr.type, ctx)}
  end

  def assign_vars(descr, num, ctx) do
    {child_descr, child_ident, num} = 
        ProtoDef.Compiler.AssignIdents.assign(descr.type, num, ctx)
    {count_descr, count_ident, num} =
        ProtoDef.Compiler.AssignIdents.assign_count(descr.count, num, ctx)
    {ident, num} = ProtoDef.Compiler.AssignIdents.make_ident(num, ctx)
    descr = %{ descr |
      ident: ident,
      count_ident: count_ident,
      count: count_descr,
      #count_type: count_descr,
      child_ident: child_ident,
      type: child_descr,
    }
    {descr, ident, num}
  end

  def resolve_references(descr, parents, ctx) do
    type = ProtoDef.Compiler.Resolve.run(descr.type, parents, ctx)
    count = ProtoDef.Compiler.Resolve.resolve_count(descr.count, parents, ctx)
    %{ descr |
      type: type,
      count: count,
    }
  end

end

defmodule ProtoDef.Type.ArrayCount do
  alias ProtoDef.Compiler.Preprocess

  use ProtoDef.Type

  defstruct type: nil, count_for_selector: nil, count_for: nil, ident: nil

  def preprocess(args, ctx) do
    %__MODULE__{
      type: Preprocess.process_type(args["type"], ctx),
      count_for_selector: Preprocess.process_field_ref(args["countFor"], ctx, true),
    }
  end

  def structure(type, ctx), do: __MODULE__

  def assign_vars(descr, num, ctx) do
    {type, ident, num} = ProtoDef.Compiler.AssignIdents.assign(descr.type, num, ctx)
    descr = %{ descr |
      ident: ident,
      type: type,
    }
    {descr, ident, num}
  end

  def resolve_references(descr, parents, ctx) do
    type = ProtoDef.Compiler.Resolve.run(descr.type, parents, ctx)
    %{ descr |
      type: type,
      count_for: ProtoDef.Compiler.Resolve.resolve_parent(descr.count_for_selector, parents, ctx)
    }
  end

end
