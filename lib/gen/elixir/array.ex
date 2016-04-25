defimpl ProtoDef.Compiler.GenElixirAst, for: ProtoDef.Type.Array do

  @data_var ProtoDef.Type.data_var
  @input_var ProtoDef.Type.input_var

  def decoder(descr, ctx) do
    count_ast = ProtoDef.Compiler.Count.decoder_ast(descr.count, ctx)
    type_ast = ProtoDef.Compiler.GenElixirAst.decoder(descr.type, ctx)
    quote do
      with do
        {count, unquote(@data_var)} = unquote(count_ast)
        {elems, unquote(@data_var)} = Enum.reduce(1..count, {[], unquote(@data_var)}, fn(_, {elems, unquote(@data_var)}) ->
          {new_elem, unquote(@data_var)} = unquote(type_ast)
          {[new_elem | elems], unquote(@data_var)}
        end)
        {Enum.reverse(elems), unquote(@data_var)}
      end
    end
  end

  def encoder(descr, ctx) do
    count_var = Macro.var(:count, ProtoDef.Type.Array)
    count_encoder = ProtoDef.Compiler.Count.encoder_ast(descr.count, count_var, ctx)
    item_encoder = ProtoDef.Compiler.GenElixirAst.encoder(descr.type, ctx)
    quote do
      with do
        unquote(count_var) = Enum.count(unquote(@input_var))
        count_head = unquote(count_encoder)
        array_body = Enum.map(unquote(@input_var), fn unquote(@input_var) ->
          unquote(item_encoder)
        end)
        [count_head, array_body]
      end
    end
  end

end

defimpl ProtoDef.Compiler.GenElixirAst, for: ProtoDef.Type.ArrayCount do

  @data_var ProtoDef.Type.data_var
  @input_var ProtoDef.Type.input_var

  def decoder(descr, ctx) do
    ProtoDef.Compiler.GenElixirAst.decoder(descr.type, ctx)
  end

  def encoder(descr, ctx) do
    {count_container_ident, count_field} = descr.count_for
    count_container = Macro.var(count_container_ident, nil)
    field_encoder = ProtoDef.Compiler.GenElixirAst.encoder(descr.type, ctx)
    quote do
      with do
        len_source = unquote(count_container)[unquote(count_field)]
        unquote(@input_var) = Enum.count(len_source)
        unquote(field_encoder)
      end
    end
  end

end
