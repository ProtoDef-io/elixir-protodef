defmodule ProtoDef.Type.Mapper do
  alias ProtoDef.Compiler.Preprocess

  use ProtoDef.Type

  defstruct type: nil, mappings: [], ident: nil, child_ident: nil
  defmodule Item do
    defstruct raw_match: nil, value: nil
  end

  # Preprocess pass

  def preprocess(args, ctx) do
    type = Preprocess.process_type(args["type"], ctx)

    mappings = args["mappings"]
    |> Enum.map(fn {match, value} ->
      %Item{
        raw_match: match,
        value: value,
      }
    end)

    %__MODULE__{
      type: type,
      mappings: mappings,
    }
  end

  # Assign pass

  def assign_vars(descr, num, ctx) do
    {type, type_ident, num} = ProtoDef.Compiler.AssignIdents.assign(descr.type, num, ctx)
    {ident, num} = ProtoDef.Compiler.AssignIdents.make_ident(num, ctx)
    descr = %{ descr |
      type: type,
      child_ident: type_ident,
      ident: ident,
    }
    {descr, ident, num+1}
  end

  # Structure pass

  def structure(descr, ctx) do
    :string
  end

  # Decoder pass

  #def decoder_ast(descr, ctx) do
  #  prefix_type = ProtoDef.Compiler.GenAst.decoder(descr.type, ctx)
  #  match_var = Macro.var(:match_var, __MODULE__)

  #  cases_ast = Enum.map
  #end

end
