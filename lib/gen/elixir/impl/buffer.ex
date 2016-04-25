defimpl ProtoDef.Gen.Elixir.Protocol, for: ProtoDef.Type.Buffer do

  @data_var ProtoDef.Type.data_var
  @input_var ProtoDef.Type.input_var

  def decoder(descr, ctx) do
    count_ast = ProtoDef.Gen.Elixir.Count.decoder(descr.count, ctx)
    quote do
      with do
        {count, unquote(@data_var)} = unquote(count_ast)
        <<val::binary-size(count), unquote(@data_var)::binary>> = unquote(@data_var)
        {val, unquote(@data_var)}
      end
    end
  end

  def encoder(descr, ctx) do
    count_var = Macro.var(:count, ProtoDef.Type.Buffer)
    count_encoder = ProtoDef.Gen.Elixir.Count.encoder(descr.count, count_var, ctx)
    quote do
      with do
        unquote(count_var) = IO.iodata_length(unquote(@input_var))
        count_head = unquote(count_encoder)
        [count_head, unquote(@input_var)]
      end
    end
  end

end
