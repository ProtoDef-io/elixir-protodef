defmodule ProtoDef.Type.BitField do
  use ProtoDef.Type

  @field_keys_message "Each field in bitfield must contain name, size and signed"
  @field_size_total_message "The sum of all fields in a bitfield must be dividable by 8"

  defstruct fields: [], pad: nil, ident: nil

  defmodule Field do
    defstruct name: nil, size: nil, signed: nil
  end

  # Preprocess pass

  def preprocess(args, ctx) do
    fields = Enum.map(args, &(preprocess_field(&1, ctx)))

    pad = rem(Enum.reduce(fields, 0, &(&1.size + &2)), 8)

    %__MODULE__{
      fields: fields,
      pad: pad,
    }
  end

  def preprocess_field(field, ctx) do
    name = field["name"]
    size = field["size"]
    signed = field["signed"]

    preprocess_field_make(name, size, signed, ctx)
  end

  def preprocess_field_make(name, size, signed, ctx) when is_binary(name) and is_integer(size) and size > 0 and is_boolean(signed) do
    %Field{
      name: ctx.parse_name.(name),
      size: size,
      signed: signed,
    }
  end
  def preprocess_field_make(_, _, _) do
    raise ProtoDef.CompileError, message: @field_keys_message
  end

  # Struct pass

  def structure(type, _ctx) do
    {:bitfield, Enum.map(type.fields, &(&1.name))}
  end

  # Assign pass

  def assign_vars(descr, num, ctx) do
    {ident, num} = ProtoDef.Compiler.AssignIdents.make_ident(num, ctx)
    descr = %{ descr |
      ident: ident,
    }
    {descr, ident, num}
  end

end
