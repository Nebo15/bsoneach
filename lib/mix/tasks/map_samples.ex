defmodule Mix.Tasks.MapSamples do
  use Mix.Task
  alias BSONMap

  @moduledoc """
    This module defines a task to IO.inspect all documents in a sample BSON file.

    ## Examples

        $ mix map_samples test.bson
  """

  @shortdoc "Parse a sample BSON file and print out all documents with a BSONMap.map function."

  def run(args) do
    [path] = args

    path
    |> File.open!([:read, :binary, :raw])
    |> BSONMap.map(&IO.inspect/1)
    |> File.close

    IO.inspect "Done"
  end
end
