defmodule Mix.Tasks.PrintRead do
  use Mix.Task
  alias CounterAgent

  @moduledoc """
  This module defines a task that loads a whole BSON fixture and increments counter on each document.

  ## Examples

      $ mix print_read test.bson
  """

  @shortdoc "Load a whole BSON fixture and increment counter on each document."

  def run(args) do
    [path] = args

    CounterAgent.new

    path
    |> File.read
    |> stream_decoder
    |> print_stream

    IO.inspect "Done parsing " <> Integer.to_string(CounterAgent.get) <> " documents."
  end

  @doc false
  def stream_decoder({:ok, bin}) do
    Stream.unfold(bin, &decode_element/1)
  end

  def stream_decoder({:error, reason}) do
    {:error, reason}
  end

  defp decode_element(<<>>) do
    nil
  end

  defp decode_element(acc) when is_binary(acc) do
    case Bson.Decoder.document(acc, %Bson.Decoder{}) do
      {%{} = doc, ""} -> {doc, <<>>}
      {%{} = doc, buf} -> {doc, buf}
      {_, ""} -> nil
    end
  end

  defp print_stream({:error, _} = error) do
    IO.inspect error
  end

  defp print_stream(stream) do
    stream
    |> Enum.map(&CounterAgent.click(&1))
  end
end
