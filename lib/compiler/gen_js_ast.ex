defprotocol ProtoDef.Compiler.GenJsAst do
  def decoder(descr, ctx)
  def encoder(descr, ctx)
end
