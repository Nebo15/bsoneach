defmodule Mix.Tasks.CountStream do
  use Mix.Task
  alias BSONEach
  alias BSONEach.Mix.Utils.CounterAgent

  @moduledoc """
  This module defines a task that uses ```BSONEach.each(&IO.inspect/1)```
  to read bson file and increment counter on each document.

  ## Examples

      $ mix count_stream test.bson
  """

  @shortdoc "Parse a BSON fixture and increment counter on each document via BSONEach.each."

  def run(args) do
    [path] = args

    CounterAgent.new

    path
    |> File.open!([:read, :binary, :raw, :read_ahead])
    |> BSONEach.each(&CounterAgent.click(&1))
    |> File.close

    IO.puts "Done parsing " <> Integer.to_string(CounterAgent.get) <> " documents."
  end
end
