defmodule ProtoDef.Type.CString do
  use ProtoDef.Type

  defstruct ident: nil

  def preprocess(nil, _ctx) do
    %__MODULE__{}
  end

  def structure(_, _), do: __MODULE__

  def decoder_ast(_descr, _ctx) do
    quote do
      with do
        {:ok, {str, rest}} = ProtoDef.Type.CString.decode_string(unquote(@data_var))
        {str, rest}
      end
    end
  end

  def encoder_ast(_descr, _ctx) do
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
