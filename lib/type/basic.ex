numeric_types = [
  # 8 bit
  {I8, [:integer, :signed]},
  {LI8, [:integer, :signed]},
  {U8, [:integer, :unsigned]},
  {LU8, [:integer, :unsigned]},
  # 16 bit
  {I16, [:integer, :signed]},
  {LI16, [:integer, :signed]},
  {U16, [:integer, :unsigned]},
  {LU16, [:integer, :unsigned]},
  # 32 bit
  {I32, [:integer, :signed]},
  {LI32, [:integer, :signed]},
  {U32, [:integer, :unsigned]},
  {LU32, [:integer, :unsigned]},
  # 64 bit
  {I64, [:integer, :signed]},
  {LI64, [:integer, :signed]},
  {U64, [:integer, :unsigned]},
  {LU64, [:integer, :unsigned]},
  # Float
  {F32, [:float]},
  {LF32, [:float]},
  {F64, [:float]},
  {LF64, [:float]},
]
for {mod_name, props} <- numeric_types do

  full_mod_name = Module.concat(ProtoDef.Type, mod_name)
  body = quote do
    #@behaviour ProtoDef.Type
    use ProtoDef.Type
    #@format unquote(Macro.escape(binary_format))

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

  end
  Module.create(full_mod_name, body, Macro.Env.location(__ENV__))

end

