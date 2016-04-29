type_defs = [
  # 8 bit
  {I8, "readInt8", "writeInt8"},
  {LI8, "readInt8LE", "writeInt8LE"},
  {U8, "readUInt8", "writeUInt8"},
  {LU8, "readUInt8LE", "writeUInt8LE"},
  # 16 bit
  {I16, "readInt16", "writeInt16"},
  {LI16, "readInt16LE", "writeInt16LE"},
  {U16, "readUInt16", "writeUInt16"},
  {LU16, "readUInt16LE", "writeUInt16LE"},
  # 32 bit
  {I32, "readInt32", "writeInt32"},
  {LI32, "readInt32LE", "writeInt32LE"},
  {U32, "readUInt32", "writeUInt32"},
  {LU32, "readUInt32LE", "writeUInt32LE"},
  # 32 bit
  {I64, "readInt64", "writeInt64"},
  {LI64, "readInt64LE", "writeInt64LE"},
  {U64, "readUInt64", "writeUInt64"},
  {LU64, "readUInt64LE", "writeUInt64LE"},
  # Float
  {F32, "readFloatBE", "writeFloatBE"},
  {LF32, "readFloatLE", "writeFloatLE"},
  {F64, "readDoubleBE", "writeDoubleBE"},
  {LF64, "readDoubleLE", "writeDoubleLE"},
]

for {mod_name, read_fun, write_fun} <- type_defs do
  full_mod_name = Module.concat(ProtoDef.Type, mod_name)

  body = quote do
    defimpl ProtoDef.Gen.Javascript.Protocol, for: unquote(full_mod_name) do

      alias ESTree.Tools.Builder

      @buffer_var Builder.identifier("buffer")
      @offset_var Builder.identifier("offset")

      @read_fun unquote(Macro.escape(read_fun))
      @write_fun unquote(Macro.escape(write_fun))

      def decoder(descr, _ctx) do
        nil
      end

      def encoder(descr, _ctx) do
        fun_ident = Builder.identifier(@write_fun)
        member = Builder.member_expression(@buffer_var, fun_ident)
        expr = Builder.call_expression(member, [@offset_var])
        Builder.expression_statement(expr)
      end

    end
  end

  body
  |> Code.eval_quoted([], file: __ENV__.file, line: __ENV__.line)
end
