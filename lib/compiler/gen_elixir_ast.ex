#defmodule ProtoDef.Compiler.GenElixirAst do
#
#  def decoder(descr, ctx) do
#    apply(descr.__struct__, :decoder_ast, [descr, ctx])
#  end
#
#  def encoder(descr, ctx) do
#    apply(descr.__struct__, :encoder_ast, [descr, ctx])
#  end
#
#end

defprotocol ProtoDef.Compiler.GenElixirAst do
  def decoder(descr, ctx)
  def encoder(descr, ctx)
end
