defmodule BSONEach.Stream do
  import BSONEach.Reader
  import BSONEach.File

  @moduledoc """
  This module creates stream of Elixir structures from a BSON file with one or many documents.
  """

  @doc """
  Create a documents stream from batch to BSON file.

  You can define different strategies when dealing with corrupted documents:

    * `:stop` - stop stream when corrupted document is found.
    * `:skip` - try to skip corrupted documents and continue reading file.
    *Warning:* this option can have performance issues, since there will be
    up to `file_size/4` reads from corrupted file. Also, Enum length will not correspond to real documents count.
    * `:report` - same as `:skip` but errors with their reasons will be returned as Stream elements.
  """
  @spec resource(File.Path.t, atom) :: Stream.t
  def resource(path, on_corrupted \\ :stop) do
    path
    |> open
    |> from_iostream(on_corrupted)
  end

  defp from_iostream({:error, reason}, _on_corrupted), do: {:error, reason}
  defp from_iostream({:ok, io_stream}, on_corrupted) do
    Stream.resource(
      fn -> io_stream end,
      &stream_reader(&1, on_corrupted),
      &close/1
    )
  end

  defp stream_reader(io, :stop) do
    case read(io) do
      {:ok, doc} ->
        {[doc], io}
      :eof ->
        {:halt, :eof}
      err ->
        {:halt, err}
    end
  end

  defp stream_reader(io, :skip) do
    case read(io) do
      {:ok, doc} ->
        {[doc], io}
      :eof ->
        {:halt, :eof}
      _err ->
        stream_reader(io, :skip)
    end
  end

  defp stream_reader(io, :report) do
    case read(io) do
      {:ok, doc} ->
        {[doc], io}
      :eof ->
        {:halt, :eof}
      err ->
        {[err], io}
    end
  end
end
