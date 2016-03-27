defmodule ProtoDef.Util do
  
  def string_to_existing_atom(string) when is_binary(string) do
    try do
      {:ok, String.to_existing_atom(string)}
    rescue
      e in ArgumentError -> :nonexistent
    end
  end

  def camel_string_to_snake_atom(name), do: name |> Macro.underscore |> String.to_atom

end
