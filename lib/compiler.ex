defmodule ProtoDef.Compiler do

  defmodule CustomType do
    defstruct gen_decoder: nil, gen_encoder: nil
  end

  defmodule Context do
    defstruct native_types: %{}, params: %{}, types: %{}, 
    parse_name: &ProtoDef.Util.camel_string_to_snake_atom/1


    @type t :: %__MODULE__{}

    def native_type(ctx, type_id) when is_atom(type_id) do
      ctx.native_types[type_id]
    end
    def native_type(ctx, type_id_str) when is_binary(type_id_str) do
      case ProtoDef.Util.string_to_existing_atom(type_id_str) do
        :nonexistent -> nil
        {:ok, atom} ->
          native_type(ctx, atom)
      end
    end

    def native_type_add(ctx, type_id, definition = %{__struct__: _}) do
      %{ ctx | 
        native_types: Map.put(ctx.native_types, type_id, definition)
      }
    end

    def type(ctx, type_name) do
      ctx.types[type_name]
    end

    def type_add(ctx, type_name, definition) do
      %{ ctx |
        types: Map.put(ctx.types, type_name, definition),
      }
    end
  end

  def compile_json_type(json_type, ctx) do
    # Preprocess the json data structure into something easier to work with
    descr = ProtoDef.Compiler.Preprocess.process_type(json_type, ctx)

    # Assign identifiers to all the fields
    {descr, ident, _count} = ProtoDef.Compiler.AssignIdents.assign(descr, 1, ctx)

    # Resolve field references
    descr = ProtoDef.Compiler.Resolve.run(descr, [], ctx)

    # Generate structure
    structure = ProtoDef.Compiler.Structure.gen_for_type(descr, ctx)

    # Generate the Elixir AST
    #decoder_ast = ProtoDef.Compiler.GenAst.decoder(descr, ctx)
    #encoder_ast = ProtoDef.Compiler.GenAst.encoder(descr, ctx)
    decoder_ast = ProtoDef.Compiler.GenElixirAst.decoder(descr, ctx)
    encoder_ast = ProtoDef.Compiler.GenElixirAst.encoder(descr, ctx)

    %{
      descr: descr,
      structure: structure,
      decoder_ast: decoder_ast,
      encoder_ast: encoder_ast,
    }
  end

end
