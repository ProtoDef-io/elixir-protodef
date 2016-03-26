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
  def preprocess(%{"count" => cnt}, _) when is_binary(cnt) do
    %__MODULE__{
      kind: :field,
      value: ProtoDef.Compiler.Preprocess.count_field_ref_dirup(cnt),
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

  # Decoder generator pass

  def decoder_ast(%__MODULE__{kind: :fixed} = cnt, ctx) do
    quote do
      {unquote(cnt.value), data}
    end
  end
  def decoder_ast(%__MODULE__{kind: :field} = cnt, ctx) do
    {container, field} = cnt.value
    container_var = Macro.var(container, nil)
    quote do
      {unquote(container_var)[unquote(field)], unquote(ProtoDef.Type.data_var)}
    end
  end
  def decoder_ast(%__MODULE__{kind: :prefix_type} = cnt, ctx) do
    ProtoDef.Compiler.GenAst.decoder(cnt.value, ctx)
  end

  # Encoder generator pass

  def encoder_ast(%__MODULE__{kind: :fixed} = cnt, count_var, ctx) do
    quote do
      if unquote(count_var) != unquote(cnt.value) do
        raise("Array expected a fixed count of #{unquote(count_var)}, got #{unquote(cnt.value)}")
      end
      []
    end
  end
  def encoder_ast(%__MODULE__{kind: :field} = cnt, _count_var, ctx) do
    quote do
      []
    end
  end
  def encoder_ast(%__MODULE__{kind: :prefix_type} = cnt, count_var, ctx) do
    encoder = ProtoDef.Compiler.GenAst.encoder(cnt.value, ctx)
    quote do
      with do
        unquote(@input_var) = unquote(count_var)
        unquote(encoder)
      end
    end
  end

end
