defmodule BSON.Types.JavaScript do
  @moduledoc """
  Represents BSON JavaScript (with and without scope) types
  """

  defstruct [:code, :scope]

  defimpl Inspect do
    def inspect(%BSON.Types.JavaScript{code: code, scope: nil}, _opts) do
      "#BSON.Types.JavaScript<#{inspect code}>"
    end

    def inspect(%BSON.Types.JavaScript{code: code, scope: scope}, _opts) do
      "#BSON.Types.JavaScript<#{inspect code}, #{inspect(scope)}>"
    end
  end
end
