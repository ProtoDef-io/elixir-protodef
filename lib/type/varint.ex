defmodule ProtoDef.Type.Varint do
  use ProtoDef.Type
  use Bitwise

  defstruct ident: nil

  def preprocess(nil, _ctx) do
    %__MODULE__{}
  end

  def structure(_type, _ctx), do: __MODULE__

  def assign_vars(descr, num, ctx) do
    {ident, num} = ProtoDef.Compiler.AssignIdents.make_ident(num, ctx)
    descr = %{ descr |
      ident: ident,
    }
    {descr, ident, num}
  end

  def decoder_ast(_descr, _ctx) do
    quote do
      ProtoDef.Type.Varint.decode_varint!(unquote(@data_var))
    end
  end
  def encoder_ast(_descr, _ctx) do
    quote do
      ProtoDef.Type.Varint.encode_varint(unquote(@input_var))
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

  def encode_varint(num) when num <= 127, do: <<num>>
  def encode_varint(num) when num >= 128 do
    <<1::1, band(num, 127)::7, encode_varint(num >>> 7)::binary>>
  end

end
