defimpl ProtoDef.Compiler.GenElixirAst, for: ProtoDef.Type.Container do

  @data_var ProtoDef.Type.data_var
  @input_var ProtoDef.Type.input_var

  # Decoder AST pass

  def decoder(descr, ctx) do
    var = Macro.var(descr.ident, nil)
    fields = Enum.map(descr.items, &item_decoder_ast(&1, var, ctx))

    quote do
      with do
        unquote(var) = %{}
        unquote_splicing(ProtoDef.AstUtils.merge_blocks(fields))
        {unquote(var), unquote(@data_var)}
      end
    end
  end
  def item_decoder_ast(%{anon: true} = item, var, ctx) do
    item_decoder = ProtoDef.Compiler.GenElixirAst.decoder(item.type, ctx)
    quote do
      {field_val, unquote(@data_var)} = unquote(item_decoder)
      unquote(var) = Map.merge(unquote(var), field_val)
    end
  end
  def item_decoder_ast(%{anon: false} = item, var, ctx) do
    item_decoder = ProtoDef.Compiler.GenElixirAst.decoder(item.type, ctx)
    quote do
      {field_val, unquote(@data_var)} = unquote(item_decoder)
      unquote(var) = Map.put(unquote(var), unquote(item.name), field_val)
    end
  end

  # Encoder AST pass

  def encoder(descr, ctx) do
    var = Macro.var(descr.ident, nil)
    fields = Enum.map(descr.items, &item_encoder_ast(&1, var, ctx))

    quote do
      with do
        result = []
        unquote(var) = unquote(@input_var)
        unquote_splicing(ProtoDef.AstUtils.merge_blocks(fields))
        result
      end
    end
  end
  def item_encoder_ast(%{anon: true} = item, var, ctx) do
    item_encoder = ProtoDef.Compiler.GenElixirAst.encoder(item.type, ctx)
    quote do
      unquote(@input_var) = unquote(var)
      result = [result, unquote(item_encoder)]
    end
  end
  def item_encoder_ast(%{anon: false} = item, var, ctx) do
    item_encoder = ProtoDef.Compiler.GenElixirAst.encoder(item.type, ctx)
    quote do
      unquote(@input_var) = unquote(var)[unquote(item.name)]
      result = [result, unquote(item_encoder)]
    end
  end

end
