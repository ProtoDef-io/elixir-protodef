defmodule ProtoDef.Type.BitField do
  @behaviour ProtoDef.Type

  @field_keys_message "Each field in bitfield must contain name, size and signed"
  @field_size_total_message "The sum of all fields in a bitfield must be dividable by 8"

  defstruct fields: []

  defmodule Field do
    defstruct name: nil, size: nil, signed: nil
  end
  
  def preprocess(args, ctx) do
    fields = Enum.map(args, &(preprocess_field(&1, ctx)))
    
    if !rem(Enum.reduce(fields, 0, &(&1 + &2)), 8) do
      raise ProtoDef.CompileError, message: @field_size_total_message
    end

    %__MODULE__{
      fields: fields,
    }
  end

  def preprocess_field(field, ctx) do
    name = field["name"]
    size = field["size"]
    signed = field["signed"]

    preprocess_field_make(name, size, signed)
  end

  def preprocess_field_make(name, size, signed) when is_binary(name) and is_integer(size) and size > 0 and is_boolean(signed) do
    %Field{
      name: name,
      size: size,
      signed: signed,
    }
  end
  def preprocess_field_make(_, _, _) do
    raise ProtoDef.CompileError, message: @field_keys_message
  end

end
