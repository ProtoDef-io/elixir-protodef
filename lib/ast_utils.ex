defmodule ProtoDef.AstUtils do
  
  def merge_blocks(blocks) do
    blocks
    |> Enum.map(fn {:__block__, _, exprs} -> exprs end)
    |> Enum.concat
  end

  def extract_block({:__block__, _, [expr]}), do: expr

end
