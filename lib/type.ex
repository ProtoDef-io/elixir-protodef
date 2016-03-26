defmodule ProtoDef.Type do

  defmacro __using__(_opts) do
    quote do

      @behaviour ProtoDef.Type

      @data_var ProtoDef.Type.data_var
      @input_var ProtoDef.Type.input_var

      def assign_vars(descr, num, ctx) do
        {ident, num} = ProtoDef.Compiler.AssignIdents.make_ident(num, ctx)
        descr = put_in descr.ident, ident
        {descr, ident, num}
      end

      def resolve_references(descr, _parents, _ctx), do: descr

      defoverridable [assign_vars: 3, resolve_references: 3]

    end
  end

  @type structure_ast :: nil
  @type ctx :: %ProtoDef.Compiler.Context{}

  @callback preprocess(term, %ProtoDef.Compiler.Context{}) :: term
  @callback structure(%{}, ctx) :: term
  @callback assign_vars(struct, pos_integer, ctx) :: struct
  @callback resolve_references(struct, [atom], ctx) :: struct
  @callback decoder_ast(struct, ctx) :: term
  @callback encoder_ast(struct, ctx) :: term

  def data_var, do: {:data, [], nil}
  def input_var, do: {:input, [], nil}

end

defmodule ProtoDef.CompileError do
  defexception [message: nil]

  def message(exception) do
    "ProtoDef compilation error: #{exception.message}"
  end

end
