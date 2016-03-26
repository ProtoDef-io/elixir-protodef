defmodule ProtoDef.Type.CString do
  @behaviour ProtoDef.Type

  defstruct []

  def preprocess(nil, _ctx) do
    %__MODULE__{}
  end
end
