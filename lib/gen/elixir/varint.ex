defmodule ProtoDef.Gen.Elixir.Varint do
  use Bitwise

  def decode_varint_signed!(data) do
    {:ok, ret} = decode_varint_signed(data)
    ret
  end
  def decode_varint_signed(data) do
    case decode_varint(data) do
      {:ok, {num, rest}} ->
        num = if (num &&& (1 <<< 31)) == 0 do
          num
        else
          num - (1 <<< 32)
        end
        {:ok, {num, rest}}
      err -> err
    end
  end

  def decode_varint!(data) do
    {:ok, ret} = decode_varint(data)
    ret
  end
  def decode_varint(data) do
    inner_decode_varint(data, 0, 0)
  end
  defp inner_decode_varint(<<1::1, curr::7, rest::binary>>, num, acc) when num < (64-7) do
    inner_decode_varint(rest, num+7, (curr <<< num) + acc)
  end
  defp inner_decode_varint(<<0::1, curr::7, rest::binary>>, num, acc) do
    {:ok, {(curr <<< num) + acc, rest}}
  end
  defp inner_decode_varint(_, num, _) when num >= (64-7), do: :too_big
  defp inner_decode_varint("", _, _), do: :incomplete
  defp inner_decode_varint(_, _, _), do: :error

  def encode_varint_signed(data) do
    if data < 0 do
      encode_varint(data + (1 <<< 32))
    else
      encode_varint(data)
    end
  end

  def encode_varint(num) when num <= 127, do: <<num>>
  def encode_varint(num) when num >= 128 do
    <<1::1, band(num, 127)::7, encode_varint(num >>> 7)::binary>>
  end

end

defimpl ProtoDef.Compiler.GenElixirAst, for: ProtoDef.Type.Varint do
  @data_var ProtoDef.Type.data_var
  @input_var ProtoDef.Type.input_var

  def decoder(_descr, _ctx) do
    quote do
      ProtoDef.Gen.Elixir.Varint.decode_varint_signed!(unquote(@data_var))
    end
  end
  def encoder(_descr, _ctx) do
    quote do
      ProtoDef.Gen.Elixir.Varint.encode_varint_signed(unquote(@input_var))
    end
  end

end
