defprotocol ProtoDef.Gen.Javascript.Protocol do
  def decoder(descr, ctx)
  def encoder(descr, ctx)
end
