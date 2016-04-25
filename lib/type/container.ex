defmodule ProtoDef.Type.Container do
  alias ProtoDef.Compiler.Preprocess
  alias ProtoDef.Compiler.AssignIdents

  use ProtoDef.Type

  @name_and_anon_unset_error "Either name or anon must be set on a container item"
  @name_and_anon_set_error "Both name and anon was set on a container item"
  @no_type_error "Container item was without a type field"

  defstruct items: [], ident: nil

  # Preprocess pass

  def preprocess(args, ctx) do
    types = Enum.map(args, &(preprocess_item(&1, ctx)))
    %__MODULE__{
      items: types,
    }
  end
  defp preprocess_item(item, ctx) do
    name = Preprocess.process_get_arg(item, ctx, "name")
    name = item["name"]
    anon = item["anon"] == true
    type = item["type"]

    if !name && !anon do
      raise ProtoDef.CompileError, message: @name_and_anon_unset_error
    end
    if name && anon do
      raise ProtoDef.CompileError, message: @name_and_anon_set_error
    end
    if !type do
      raise ProtoDef.CompileError, message: @no_type_error
    end
    if name == "nil" do
      raise ProtoDef.CompileError, message: "Keys can't be named nil"
    end

    %{
      anon: anon,
      name: (if name, do: ctx.parse_name.(name)),
      type: Preprocess.process_type(type, ctx),
      ident: nil,
    }
  end

  # Struct pass

  def structure(type, ctx) do
    type.items
    |> Enum.flat_map(&(structure_field(&1, ctx)))
    |> Enum.into(%{})
  end
  def structure_field(item = %{anon: true}, ctx) do
    fields = ProtoDef.Compiler.Structure.gen_for_type(item.type, ctx)
    true = is_map(fields)
    Enum.into(fields, [])
  end
  def structure_field(item = %{anon: false}, ctx) do
    field = ProtoDef.Compiler.Structure.gen_for_type(item.type, ctx)
    [{item.name, field}]
  end

  # Assign pass

  def assign_vars(descr, num, ctx) do
    {items, num} = Enum.reduce(descr.items, {[], num}, fn(item, {items, num}) ->
      {item, num} = assign_field(item, num, ctx)
      {[item | items], num}
    end)
    items = items |> Enum.reverse

    {ident, num} = AssignIdents.make_ident(num, ctx)
    descr = %{ descr |
      items: items,
      ident: ident,
    }

    {descr, ident, num}
  end
  def assign_field(item, num, ctx) do
    {descr, ident, num} = AssignIdents.assign(item.type, num, ctx)
    item = %{ item |
      ident: ident,
      type: descr,
    }
    {item, num}
  end

  # Resolve pass

  def resolve_references(descr, parents, ctx) do
    parents = [descr.ident | parents]
    items = Enum.map(descr.items, &(resolve_field(&1, parents, ctx)))
    %{ descr |
      items: items,
    }
  end
  def resolve_field(item, parents, ctx) do
    type = ProtoDef.Compiler.Resolve.run(item.type, parents, ctx)
    %{ item |
      type: type,
    }
  end


end

