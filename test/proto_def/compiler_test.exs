defmodule ProtoDef.CompilerTest do
  use ExUnit.Case, async: true

  def compile(definition) do
    ctx = ProtoDef.context
    ProtoDef.Compiler.compile_json_type(definition, ctx)
  end
  def test_transpose(definition, binary_data, structure_data) do
    compiled = compile(definition)

    # Test decoding
    {{decode_result, decode_rest}, _} = Code.eval_quoted(compiled.decoder_ast, [data: binary_data])
    assert decode_rest == ""
    assert decode_result == structure_data

    # Test encoding
    {encode_iol, _} = Code.eval_quoted(compiled.encoder_ast, [input: structure_data])
    encode_result = IO.iodata_to_binary(encode_iol)
    assert encode_result == binary_data
  end

  test "transpose container" do
    definition = ["container", [
        %{"name" => "int", "type" => "i8"},
        %{"name" => "sec", "type" => "i16"},
      ]]
    data = <<12, 0, 8>>
    res = %{int: 12, sec: 8}
    test_transpose(definition, data, res)
  end

  test "transpose anon container" do
    definition = ["container", [
        %{"anon" => true, "type" => ["container", [
              %{"name" => "int", "type" => "i8"},
            ]]},
      ]]
    data = <<12>>
    res = %{int: 12}
    test_transpose(definition, data, res)
  end

  test "transpose array with field count" do
    definition = ["container", [
        %{"name" => "cnt", "type" => ["count", %{"type" => "i8", "countFor" => "arr"}]},
        %{"name" => "arr", "type" => ["array", %{"type" => "i8", "count" => "cnt"}]},
      ]]
    data = <<2, 9, 6>>
    res = %{cnt: 2, arr: [9, 6]}
    test_transpose(definition, data, res)
  end

end
