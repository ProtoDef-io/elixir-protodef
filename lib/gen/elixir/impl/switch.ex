defmodule ProtoDef.Gen.Elixir.Impl.Switch do

  # TODO: This is bad. Figure this out statically
  def javascript_eq("0x" <> hex, val) when is_integer(val) do
    {num, ""} = Integer.parse(hex, 16)
    num == val
  end
  def javascript_eq(str_num, val) when is_integer(val) do
    {num, ""} = Integer.parse(str_num)
    num == val
  end
  def javascript_eq(bin, val) when is_binary(val) do
    bin == val
  end
  def javascript_eq(match, val) when is_boolean(val) do
    (match == "true") == val
  end

end

defimpl ProtoDef.Gen.Elixir.Protocol, for: ProtoDef.Type.Switch do

  @data_var ProtoDef.Type.data_var
  @input_var ProtoDef.Type.input_var

  # Decoder generator pass

  def decoder(descr, ctx) do
    {comp_container_ident, comp_field} = descr.compare_to
    comp_container_var = Macro.var(comp_container_ident, nil)

    match_var = Macro.var(:match_var, __MODULE__)
    cases_ast = Enum.map(descr.fields, &(decoder_ast_case(&1, match_var, ctx)))
    default_case_ast = decoder_ast_default_case(descr.default, ctx)

    cases = cases_ast ++ default_case_ast

    quote do
      unquote(match_var) = unquote(comp_container_var)[unquote(comp_field)]
      cond do
        unquote(cases)
      end
    end
  end
  def decoder_ast_default_case(item, ctx) do
    item_ast = ProtoDef.Gen.Elixir.Protocol.decoder(item.type, ctx)
    quote do
      true -> unquote(item_ast)
    end
  end
  def decoder_ast_case(item, match_var, ctx) do
    match_ast = Macro.escape(item.match)
    item_ast = ProtoDef.Gen.Elixir.Protocol.decoder(item.type, ctx)
    quote do
      ProtoDef.Gen.Elixir.Impl.Switch.javascript_eq(unquote(match_ast), unquote(match_var)) -> unquote(item_ast)
    end
    |> hd
  end


  # Encoder generator pass

  def encoder(descr, ctx) do
    {comp_container_ident, comp_field} = descr.compare_to
    comp_container_var = Macro.var(comp_container_ident, nil)

    match_var = Macro.var(:match_var, __MODULE__)
    cases_ast = Enum.map(descr.fields, &(encoder_ast_case(&1, match_var, ctx)))
    default_case_ast = encoder_ast_default_case(descr.default, ctx)

    cases = cases_ast ++ default_case_ast

    quote do
      unquote(match_var) = unquote(comp_container_var)[unquote(comp_field)]
      cond do
        unquote(cases)
      end
    end
  end
  def encoder_ast_default_case(item, ctx) do
    item_ast = ProtoDef.Gen.Elixir.Protocol.encoder(item.type, ctx)
    quote do
      true -> unquote(item_ast)
    end
  end
  def encoder_ast_case(item, match_var, ctx) do
    match_ast = Macro.escape(item.match)
    item_ast = ProtoDef.Gen.Elixir.Protocol.encoder(item.type, ctx)
    quote do
      ProtoDef.Gen.Elixir.Impl.Switch.javascript_eq(unquote(match_ast), unquote(match_var)) -> unquote(item_ast)
    end
    |> hd
  end

end
