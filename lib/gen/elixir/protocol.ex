defprotocol ProtoDef.Gen.Elixir.Protocol do
  def decoder(descr, ctx)
  def encoder(descr, ctx)
end
