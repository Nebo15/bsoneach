defmodule BSON.Types.Timestamp do
  @moduledoc """
  Represents BSON Timestamp type
  """

  defstruct [:value]

  defimpl Inspect do
    def inspect(%BSON.Types.Timestamp{value: value}, _opts) do
      "#BSON.Types.Timestamp<#{value}>"
    end
  end
end
