defimpl ProtoDef.Compiler.GenElixirAst, for: ProtoDef.Type.PString do

  @data_var ProtoDef.Type.data_var
  @input_var ProtoDef.Type.input_var

  def decoder(descr, ctx) do
    count_ast = ProtoDef.Compiler.Count.decoder_ast(descr.count, ctx)
    quote do
      with do
        {count, unquote(@data_var)} = unquote(count_ast)
        <<str::binary-size(count), unquote(@data_var)::binary>> = unquote(@data_var)
        {str, unquote(@data_var)}
      end
    end
  end

  def encoder(descr, ctx) do
    count_var = Macro.var(:count, ProtoDef.Type.PString)
    count_encoder = ProtoDef.Compiler.Count.encoder_ast(descr.count, count_var, ctx)
    quote do
      with do
        unquote(count_var) = byte_size(unquote(@input_var))
        count_head = unquote(count_encoder)
        [count_head, unquote(@input_var)]
      end
    end
  end

end
