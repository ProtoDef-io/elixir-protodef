numeric_types = [
  # 8 bit
  {I8, [:integer, :signed], quote do: signed-integer-1*8},
  {U8, [:integer, :unsigned], quote do: unsigned-integer-1*8},
  {LI8, [:integer, :signed], quote do: signed-integer-1*8},
  {LU8, [:integer, :unsigned], quote do: unsigned-integer-1*8},
  # 16 bit
  {I16, [:integer, :signed], quote do: signed-integer-2*8},
  {LI16, [:integer, :signed], quote do: little-signed-integer-2*8}
  {U16, [:integer, :unsigned], quote do: unsigned-integer-2*8},
  {LU16, [:integer, :unsigned], quote do: little-unsigned-integer-2*8}
  # 32 bit
  {I32, [:integer, :signed], quote do: signed-integer-4*8},
  {LI32, [:integer, :signed], quote do: little-signed-integer-4*8},
  {U32, [:integer, :unsigned], quote do: unsigned-integer-4*8},
  {LU32, [:integer, :unsigned], quote do: little-unsigned-integer-4*8},
  # 64 bit
  {I64, [:integer, :signed], quote do: signed-integer-8*8},
  {LI64, [:integer, :signed], quote do: little-signed-integer-8*8},
  {U64, [:integer, :unsigned], quote do: unsigned-integer-8*8},
  {LU64, [:integer, :unsigned], quote do: little-unsigned-integer-8*8},
  # Float
  {F32, [:float], quote do: float-4*8},
  {LF32, [:float], quote do: little-float-4*8},
  {F64, [:float], quote do: float-8*8},
  {LF64, [:float], quote do: little-float-8*8},
]
for {mod_name, props, binary_format} <- numeric_types do

  full_mod_name = Module.concat(ProtoDef.Type, mod_name) 
  body = quote do
    #@behaviour ProtoDef.Type
    use ProtoDef.Type
    @format unquote(Macro.escape(binary_format))

    defstruct ident: nil

    def preprocess(nil, _ctx), do: %__MODULE__{}

    def structure(type, ctx), do: unquote(Macro.escape(full_mod_name))

    def assign_vars(descr, num, ctx) do
      {ident, num} = ProtoDef.Compiler.AssignIdents.make_ident(num, ctx)
      descr = %{ descr |
        ident: ident,
      }
      {descr, ident, num}
    end

    def decoder_ast(descr, _ctx) do
      quote do
        with do
          <<val::unquote(@format), unquote(@data_var)::binary>> = unquote(@data_var)
          {val, unquote(@data_var)}
        end
      end
    end

    def encoder_ast(descr, _ctx) do
      quote do
        <<unquote(@input_var)::unquote(@format)>>
      end
    end

  end
  Module.create(full_mod_name, body, Macro.Env.location(__ENV__))

end

