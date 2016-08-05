defmodule Mix.Tasks.PrintEach do
  use Mix.Task
  alias BSONEach

  @moduledoc """
    This module defines a task that uses ```BSONEach.each(&IO.inspect/1)``` to print all documents in a sample BSON file.

    ## Examples

        $ mix print_each test.bson
  """

  @shortdoc "Parse a BSON fixture and print out all documents via BSONEach.each function."

  def run(args) do
    [path] = args

    path
    |> File.open!([:read, :binary, :raw])
    |> BSONEach.each(&IO.inspect/1)
    |> File.close

    IO.inspect "Done"
  end
end
