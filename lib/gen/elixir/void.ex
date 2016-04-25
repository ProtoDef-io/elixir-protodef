defimpl ProtoDef.Compiler.GenElixirAst, for: ProtoDef.Type.Void do

  @data_var ProtoDef.Type.data_var
  @input_var ProtoDef.Type.input_var

  def decoder(descr, ctx) do
    quote do
      {nil, unquote(@data_var)}
    end
  end

  def encoder(descr, ctx) do
    quote do
      <<>>
    end
  end

end
