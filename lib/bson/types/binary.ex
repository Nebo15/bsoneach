defmodule BSON.Types.Binary do
  @moduledoc """
  Represents BSON binary type
  """

  defstruct [binary: nil, subtype: :generic]

  defimpl Inspect do
    def inspect(%BSON.Types.Binary{binary: value, subtype: :generic}, _opts) do
      "#BSON.Types.Binary<#{Base.encode16(value, case: :lower)}>"
    end

    def inspect(%BSON.Types.Binary{binary: value, subtype: subtype}, _opts) do
      "#BSON.Types.Binary<#{Base.encode16(value, case: :lower)}, #{subtype}>"
    end
  end
end
