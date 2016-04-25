defmodule ProtoDef.Gen.Elixir.Count do
  alias ProtoDef.Compiler.Count, as: CCount

  # Decoder generator pass

  def decoder(%CCount{kind: :fixed} = cnt, ctx) do
    quote do
      {unquote(cnt.value), unquote(ProtoDef.Type.data_var)}
    end
  end
  def decoder(%CCount{kind: :field} = cnt, ctx) do
    {container, field} = cnt.value
    container_var = Macro.var(container, nil)
    quote do
      {unquote(container_var)[unquote(field)], unquote(ProtoDef.Type.data_var)}
    end
  end
  def decoder(%CCount{kind: :prefix_type} = cnt, ctx) do
    ProtoDef.Gen.Elixir.Protocol.decoder(cnt.value, ctx)
  end

  # Encoder generator pass

  def encoder(%CCount{kind: :fixed} = cnt, count_var, ctx) do
    quote do
      if unquote(count_var) != unquote(cnt.value) do
        raise("Array expected a fixed count of #{unquote(count_var)}, got #{unquote(cnt.value)}")
      end
      []
    end
  end
  def encoder(%CCount{kind: :field} = cnt, _count_var, ctx) do
    quote do
      []
    end
  end
  def encoder(%CCount{kind: :prefix_type} = cnt, count_var, ctx) do
    encoder = ProtoDef.Gen.Elixir.Protocol.encoder(cnt.value, ctx)
    quote do
      with do
        unquote(ProtoDef.Type.input_var) = unquote(count_var)
        unquote(encoder)
      end
    end
  end

end
