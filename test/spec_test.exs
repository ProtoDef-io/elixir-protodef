defmodule SpecTest.Utils do
  use Bitwise

  def parse_buffer_entry("0x" <> hex) do
    Base.decode16!(hex, case: :mixed)
  end

  def buffer_to_binary(list) do
    IO.iodata_to_binary(buffer_to_binary(list, []))
  end
  def buffer_to_binary([], data), do: data
  def buffer_to_binary([head | tail], data) do
    buffer_to_binary(tail, [data, parse_buffer_entry(head)])
  end

  def spec_num_from_num_list([p1, p2]) do
    p2 + (p1 <<< 32)
  end

  def value_eq?(decoded, spec) when is_map(decoded) and is_map(spec) do
    spec_proc = spec
    |> Enum.map(fn {name, value} ->
      snake_name = ProtoDef.Util.camel_string_to_snake_atom(name)
      value_eq?(value, decoded[snake_name])
    end)
    |> Enum.all?
  end
  def value_eq?(decoded, spec) when is_number(decoded) and is_list(spec) do
    decoded == spec_num_from_num_list(spec)
  end
  def value_eq?(decoded, spec) when is_binary(decoded) and is_list(spec) do
    decoded == buffer_to_binary(spec)
  end
  def value_eq?(decoded, spec), do: decoded == spec
end

defmodule SpecTest do
  use ExUnit.Case, async: true

  spec_test_dir = to_string(:code.priv_dir(:proto_def)) <> "/protodef-spec/test"
  spec_test_files = ["conditional", "numeric", "structures", "utils"]

  gen_testcase = fn(file, test_case) ->
    test_descr = if test_case["description"] do
      "spec: #{test_case["description"]}"
    else
      "spec: #{file} #{test_case["type"]}"
    end

    escaped_type = Macro.escape(test_case["type"])
    values = Enum.map(test_case["values"], fn %{"buffer" => buf, "value" => value} ->
      buffer = SpecTest.Utils.buffer_to_binary(buf)
      quote do
        in_data = unquote(buffer)

        {{decode_result, decode_rest}, _} = Code.eval_quoted(compiled.decoder_ast, [data: in_data])
        #IO.inspect {unquote(test_descr), decode_result, unquote(Macro.escape(value))}
        assert SpecTest.Utils.value_eq?(decode_result, unquote(Macro.escape(value)))

        {encode_iol, _} = Code.eval_quoted(compiled.encoder_ast, [input: decode_result])
        encode_data = IO.iodata_to_binary(encode_iol)
        assert encode_data == in_data
      end
    end)

    quote do
      test unquote(test_descr) do
        ctx = ProtoDef.context
        compiled = ProtoDef.Compiler.compile_json_type(unquote(escaped_type), ctx)
        unquote(values)
      end
    end
  end

  for test_file <- spec_test_files do
    file_name = "#{spec_test_dir}/#{test_file}.json"
    file_data = Poison.Parser.parse!(File.read!(file_name))

    for test_group <- file_data do
      if test_group["subtypes"] do
        Enum.map(test_group["subtypes"], &gen_testcase.(test_file, &1))
      else
        gen_testcase.(test_file, test_group)
      end
    end
  end
  |> Code.eval_quoted([], __ENV__)

end
