defmodule ProtoDef.Type.CString do
  use ProtoDef.Type

  defstruct ident: nil

  def preprocess(nil, _ctx) do
    %__MODULE__{}
  end

  def structure(_, _), do: __MODULE__

  # FIXME FIXME FIXME
  def decode_string(bin, num \\ 0) do
    case bin do
      <<str::binary-size(num), 0, rest::binary>> -> {:ok, {str, rest}}
      _ when byte_size(bin) > num -> decode_string(bin, num+1)
      _ -> :error
    end
  end
end
