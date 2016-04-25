defimpl ProtoDef.Compiler.GenElixirAst, for: ProtoDef.Type.Option do

  @data_var ProtoDef.Type.data_var
  @input_var ProtoDef.Type.input_var

  def decoder(descr, ctx) do
    item_ast = ProtoDef.Compiler.GenElixirAst.decoder(descr.type, ctx)
    quote do
      with do
        <<has_field::unsigned-integer-1*8, unquote(@data_var)::binary>> = unquote(@data_var)
        if has_field == 1 do
          unquote(item_ast)
        else
          {nil, unquote(@data_var)}
        end
      end
    end
  end

  def encoder(descr, ctx) do
    item_ast = ProtoDef.Compiler.GenElixirAst.encoder(descr.type, ctx)
    quote do
      with do
        has_field = if unquote(@input_var), do: 1, else: 0
        if has_field == 1 do
          [<<has_field::1*8>>, unquote(item_ast)]
        else
          <<has_field::1*8>>
        end
      end
    end
  end

end
