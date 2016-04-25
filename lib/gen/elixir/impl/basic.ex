type_defs = [
  # 8 bit
  {I8, quote do: signed-integer-1*8},
  {LI8, quote do: little-signed-integer-1*8},
  {U8, quote do: unsigned-integer-1*8},
  {LU8, quote do: little-unsigned-integer-1*8},
  # 16 bit
  {I16, quote do: signed-integer-2*8},
  {LI16, quote do: little-signed-integer-2*8},
  {U16, quote do: unsigned-integer-2*8},
  {LU16, quote do: little-unsigned-integer-2*8},
  # 32 bit
  {I32, quote do: signed-integer-4*8},
  {LI32, quote do: little-signed-integer-4*8},
  {U32, quote do: unsigned-integer-4*8},
  {LU32, quote do: little-unsigned-integer-4*8},
  # 64 bit
  {I64, quote do: signed-integer-8*8},
  {LI64, quote do: little-signed-integer-8*8},
  {U64, quote do: unsigned-integer-8*8},
  {LU64, quote do: little-unsigned-integer-8*8},
  # Float
  {F32, quote do: float-4*8},
  {LF32, quote do: little-float-4*8},
  {F64, quote do: float-8*8},
  {LF64, quote do: little-float-8*8},
]

for {mod_name, binary_format} <- type_defs do
  full_mod_name = Module.concat(ProtoDef.Type, mod_name)

  body = quote do
    defimpl ProtoDef.Gen.Elixir.Protocol, for: unquote(full_mod_name) do

      @data_var ProtoDef.Type.data_var
      @input_var ProtoDef.Type.input_var

      @format unquote(Macro.escape(binary_format))

      def decoder(descr, _ctx) do
        quote do
          with do
            <<val::unquote(@format), unquote(@data_var)::binary>> = unquote(@data_var)
            {val, unquote(@data_var)}
          end
        end
      end

      def encoder(descr, _ctx) do
        quote do
          <<unquote(@input_var)::unquote(@format)>>
        end
      end

    end
  end

  body
  |> Code.eval_quoted([], file: __ENV__.file, line: __ENV__.line)

end
