defimpl ProtoDef.Gen.Elixir.Protocol, for: ProtoDef.Type.Bool do

  @data_var ProtoDef.Type.data_var
  @input_var ProtoDef.Type.input_var

  def decoder(descr, ctx) do
    quote do
      with do
        <<val::unsigned-integer-1*8, unquote(@data_var)::binary>> = unquote(@data_var)
        {val == 1, unquote(@data_var)}
      end
    end
  end

  def encoder(descr, ctx) do
    quote do
      if unquote(@input_var) do
        <<1::1*8>>
      else
        <<0::1*8>>
      end
    end
  end

end
