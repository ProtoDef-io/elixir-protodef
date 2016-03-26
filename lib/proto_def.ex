defmodule ProtoDef do
  alias ProtoDef.Type

  def default_types do
    %{
      # Conditionals
      :switch => Type.Switch,
      :option => Type.Option,

      # Basic numeric
      :u8 => Type.U8,
      :i8 => Type.I8,
      :u16 => Type.U16,
      :i16 => Type.I16,
      :u32 => Type.U32,
      :i32 => Type.I32,
      :u64 => Type.U64,
      :i64 => Type.I64,
      :f32 => Type.F32,
      :f64 => Type.F64,

      # Structures
      :container => Type.Container,
      :array => Type.Array,
      :count => Type.ArrayCount,

      # Utils
      :varint => Type.Varint,
      :bool => Type.Bool,
      :pstring => Type.PString,
      :buffer => Type.Buffer,
      :void => Type.Void,
      :bitfield => Type.BitField,
      :cstring => Type.CString,
    }
  end

  @spec context :: ProtoDef.Compiler.Context.t
  def context, do: context(default_types)
  def context(types) do
    %ProtoDef.Compiler.Context{
      native_types: types,
    }
  end

  @spec compile_json_type(term, ProtoDef.Compiler.Context.t) :: map
  def compile_json_type(json_type, ctx) do
    ProtoDef.Compiler.compile_json_type(json_type, ctx)
  end

end
