defimpl ProtoDef.Compiler.GenElixirAst, for: ProtoDef.Type.CString do

  @data_var ProtoDef.Type.data_var
  @input_var ProtoDef.Type.input_var

  def decoder(_descr, _ctx) do
    quote do
      with do
        {:ok, {str, rest}} = ProtoDef.Type.CString.decode_string(unquote(@data_var))
        {str, rest}
      end
    end
  end

  def encoder(_descr, _ctx) do
    quote do
      with do
        # This makes sure there are no null bytes in the string
        :error = ProtoDef.Type.CString.decode_string(unquote(@input_var))
        [unquote(@input_var), 0]
      end
    end
  end

  def decode_string(bin, num \\ 0) do
    case bin do
      <<str::binary-size(num), 0, rest::binary>> -> {:ok, {str, rest}}
      _ when byte_size(bin) > num -> decode_string(bin, num+1)
      _ -> :error
    end
  end

end
