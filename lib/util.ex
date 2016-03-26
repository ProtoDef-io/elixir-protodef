defmodule ProtoDef.Util do
  
  def string_to_existing_atom(string) when is_binary(string) do
    try do
      {:ok, String.to_existing_atom(string)}
    rescue
      e in ArgumentError -> :nonexistent
    end
  end

end
