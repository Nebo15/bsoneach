defmodule BSON.Types.Regex do
  @moduledoc """
  Represents BSON Regex type
  """

  defstruct [:pattern, :options]

  defimpl Inspect do
    def inspect(%BSON.Types.Regex{pattern: pattern, options: nil}, _opts) do
      "#BSON.Types.Regex<#{inspect pattern}>"
    end

    def inspect(%BSON.Types.Regex{pattern: pattern, options: options}, _opts) do
      "#BSON.Types.Regex<#{inspect pattern}, #{inspect options}>"
    end
  end
end
