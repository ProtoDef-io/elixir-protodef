defmodule ProtoDef.Compiler.Count do

  defstruct kind: nil, value: nil, ident: nil

  # Preprocess pass
  def preprocess(%{"count" => _, "countType" => _}, _) do
    raise ProtoDef.CompileError, message: "Both count and countType specified on type"
  end
  def preprocess(%{"count" => cnt}, _) when is_integer(cnt) do
    %__MODULE__{
      kind: :fixed,
      value: cnt,
    }
  end
  def preprocess(%{"count" => cnt}, ctx) when is_binary(cnt) do
    %__MODULE__{
      kind: :field,
      value: ProtoDef.Compiler.Preprocess.process_field_ref(cnt, ctx),
    }
  end
  def preprocess(%{"countType" => type}, ctx) when type != nil do
    %__MODULE__{
      kind: :prefix_type,
      value: ProtoDef.Compiler.Preprocess.process_type(type, ctx),
    }
  end
  def preprocess(_, ctx) do
    raise ProtoDef.CompileError, message: "Incorrect count configuration on type"
  end

  # Assign pass

  def assign(%__MODULE__{kind: :prefix_type} = cnt, num, ctx) do
    {type, ident, num} = ProtoDef.Compiler.AssignIdents.assign(cnt.value, num, ctx)
    cnt = %{ cnt |
      value: type,
      ident: ident,
    }
    {cnt, ident, num}
  end
  def assign(cnt, num, ctx) do
    {ident, num} = ProtoDef.Compiler.AssignIdents.make_ident(num, ctx)
    cnt = %{ cnt |
      ident: ident,
    }
    {cnt, ident, num}
  end

  # Resolve pass
  def resolve(%__MODULE__{kind: :field} = cnt, parents, ctx) do
    %{ cnt |
      value: ProtoDef.Compiler.Resolve.resolve_parent(cnt.value, parents, ctx),
    }
  end
  def resolve(%__MODULE__{} = cnt, _parents, _ctx), do: cnt

end
