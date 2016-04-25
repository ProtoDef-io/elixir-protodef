defimpl ProtoDef.Gen.Elixir.Protocol, for: ProtoDef.Type.BitField do

  @data_var ProtoDef.Type.data_var
  @input_var ProtoDef.Type.input_var

  # Decoder AST pass

  def decoder(descr, ctx) do
    field_decoders = Enum.map(descr.fields, &item_decoder_ast(&1, ctx))
    field_assigners = Enum.map(descr.fields, &item_decoder_assigner_ast(&1, ctx))
    quote do
      with do
        <<unquote_splicing(field_decoders), _::unquote(descr.pad), unquote(@data_var)::binary>> = unquote(@data_var)
        ret = %{unquote_splicing(field_assigners)}
        {ret, unquote(@data_var)}
      end
    end
  end
  def item_decoder_ast(%{signed: true} = item, _ctx) do
    var = Macro.var(item.name, __MODULE__)
    quote do: unquote(var)::signed-integer-unquote(item.size)
  end
  def item_decoder_ast(%{signed: false} = item, _ctx) do
    var = Macro.var(item.name, __MODULE__)
    quote do: unquote(var)::unsigned-integer-unquote(item.size)
  end
  def item_decoder_assigner_ast(item, _ctx) do
    var = Macro.var(item.name, __MODULE__)
    {item.name, var}
  end

  # Encoder AST pass

  def encoder(descr, ctx) do
    field_encoders = Enum.map(descr.fields, &item_encoder_ast(&1, ctx))
    quote do
      <<unquote_splicing(field_encoders), 0::unquote(descr.pad)>>
    end
  end
  def item_encoder_ast(%{signed: true} = item, _ctx) do
    quote do: unquote(@input_var)[unquote(item.name)]::signed-integer-unquote(item.size)
  end
  def item_encoder_ast(%{signed: false} = item, _ctx) do
    quote do: unquote(@input_var)[unquote(item.name)]::unsigned-integer-unquote(item.size)
  end

end
