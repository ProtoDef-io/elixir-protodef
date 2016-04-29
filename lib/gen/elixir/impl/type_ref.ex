defimpl ProtoDef.Gen.Elixir.Protocol, for: ProtoDef.Type.TypeRef do

  @data_var ProtoDef.Type.data_var
  @input_var ProtoDef.Type.input_var

  def decoder(%{kind: :simple} = descr, _ctx) do
    {module, name} = descr.decode
    quote do
      apply(unquote(module), unquote(name), [unquote(@data_var)])
    end
  end

  def encoder(%{kind: :simple} = descr, _ctx) do
    {module, name} = descr.encode
    quote do
      apply(unquote(module), unquote(name), [unquote(@input_var)])
    end
  end

end
