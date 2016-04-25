defmodule ProtoDef.Type.CString do
  use ProtoDef.Type

  defstruct ident: nil

  def preprocess(nil, _ctx) do
    %__MODULE__{}
  end

  def structure(_, _), do: __MODULE__

end
