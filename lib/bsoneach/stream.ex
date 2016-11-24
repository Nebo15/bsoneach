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
  @spec resource(Path.t, atom) :: Enum.t
  def resource(path, on_corrupted \\ :stop) do
    case File.exists?(path) do
      true -> stream(path, on_corrupted)
      false -> {:error, :enoent}
    end
  end

  defp stream(path, on_corrupted) do
    Stream.resource(
      fn -> path |> open() end,
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
