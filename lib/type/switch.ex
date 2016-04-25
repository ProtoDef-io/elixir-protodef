defmodule ProtoDef.Type.Switch do
  alias ProtoDef.Compiler.Preprocess
  alias ProtoDef.Compiler.Structure
  alias ProtoDef.Compiler.Resolve

  use ProtoDef.Type

  @no_compare_to "No compareTo field in switch"
  @fields_list_length "Switch must have at least one item in fields"

  defstruct compare_to_raw: nil, compare_to: nil, fields: [], default: nil, ident: nil
  defmodule Field do
    defstruct match: nil, type: nil, ident: nil
  end

  # Preprocess pass

  def preprocess(args, ctx) do
    compare_to = args["compareTo"]
    fields = args["fields"]
    default = args["default"]

    if compare_to == nil do
      raise ProtoDef.CompileError, message: @no_compare_to
    end
    if !is_map(fields) || (Enum.count(fields) < 1) do
      raise ProtoDef.CompileError, message: @fields_list_length
    end

    default_field = if default do
      %Field{
        type: preprocess_item(default, ctx),
      }
    else
      %Field{
        type: %ProtoDef.Type.Void{},
      }
    end

    %__MODULE__{
      compare_to_raw: Preprocess.process_field_ref(compare_to, ctx),
      fields: Enum.map(fields, fn {match, type} ->
        %Field{
          match: match, 
          type: preprocess_item(type, ctx),
        }
      end),
      default: default_field,
    }
  end
  def preprocess_item(item, ctx) do
    Preprocess.process_type(item, ctx)
  end

  # Structure pass

  def structure(descr, ctx) do
    {:or, structure_types(descr, ctx)}
  end
  def structure_types(descr, ctx) do
    field_types = Enum.map(descr.fields, fn item -> Structure.gen_for_type(item.type, ctx) end)
    case descr.default do
      nil -> field_types
      typ -> [Structure.gen_for_type(typ.type, ctx) | field_types]
    end
    |> Enum.dedup
  end

  def map_fields(descr, fun) do
    default = if descr.default, do: fun.(descr.default)
    fields = Enum.map(descr.fields, fun)
    %{ descr |
      default: default,
      fields: fields,
    }
  end

  # Assign pass

  def assign_vars(descr, num, ctx) do
    {default_item, ctx} = assign_item(descr.default, num, ctx)
    {fields, num} = Enum.reduce(descr.fields, {[], num}, fn(field, {fields, num}) ->
      {field, num} = assign_item(field, num, ctx)
      {[field | fields], num}
    end)
    fields = fields |> Enum.reverse
    {default, num} = if descr.default do
      assign_item(descr.default, num, ctx)
    else
      {nil, num}
    end
    {ident, num} = ProtoDef.Compiler.AssignIdents.make_ident(num, ctx)
    descr = %{ descr |
      default: default,
      fields: fields,
      ident: ident,
    }
    {descr, ident, num+1}
  end
  def assign_item(nil, num, ctx), do: {nil, ctx}
  def assign_item(field, num, ctx) do
    {type, ident, num} = ProtoDef.Compiler.AssignIdents.assign(field.type, num, ctx)
    field = %{ field |
      type: type,
      ident: ident,
    }
    {field, num}
  end

  # Resolve pass

  def resolve_references(descr, parents, ctx) do
    descr = map_fields(descr, fn field ->
      put_in field.type, Resolve.run(field.type, parents, ctx)
    end)
    put_in descr.compare_to, Resolve.resolve_parent(descr.compare_to_raw, parents, ctx)
  end

end
