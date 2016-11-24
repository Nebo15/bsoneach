defmodule BSONEach.Stream do
  @moduledoc """
  This module creates stream of Elixir structures from a BSON file with one or many documents.
  """
  import BSONEach.Reader
  import BSONEach.File

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
  def resource(path, on_corrupted \\ :stop, additional_data \\ nil) do
    case File.exists?(path) do
      true -> stream(path, on_corrupted, additional_data)
      false -> {:error, :enoent}
    end
  end

  defp stream(path, on_corrupted, additional_data) do
    Stream.resource(
      fn -> path |> open() end,
      &stream_reader(&1, on_corrupted, additional_data),
      &close/1
    )
  end

  defp stream_reader(io, :stop, additional_data) do
    case read(io) do
      {:ok, doc} ->
        make_resp(io, doc, additional_data)
      :eof ->
        {:halt, :eof}
      err ->
        {:halt, err}
    end
  end

  defp stream_reader(io, :skip, additional_data) do
    case read(io) do
      {:ok, doc} ->
        make_resp(io, doc, additional_data)
      :eof ->
        {:halt, :eof}
      _err ->
        stream_reader(io, :skip, additional_data)
    end
  end

  defp stream_reader(io, :report, additional_data) do
    case read(io) do
      {:ok, doc} ->
        make_resp(io, doc, additional_data)
      :eof ->
        {:halt, :eof}
      err ->
        {[err], io}
    end
  end

  defp make_resp(io, doc, nil), do: {[doc], io}
  defp make_resp(io, doc, additional_data), do: {[{doc, additional_data}], io}
end
