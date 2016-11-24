defmodule BSONEach.Iterative do
  @moduledoc """
  This module provides recursive reader that applies a callback function for each document in a BSON file.
  """

  @buf_size 65_535 # Read files by 64 KB by-default

  @doc """
  This method allows to apply `callback` function to each document in a BSON file
  by iterating over document contents till `:eol` is reached.

  See `BSONEach.each/2` for more info.
  """
  def iterate(io, buf, func, index \\ 0)

  def iterate(io, <<size::32-little-signed, _::binary>> = acc, func, index) when byte_size(acc) == size do
    case decode(acc, func) do
      {:ok, _} -> iterate(io, <<>>, func, index)
      error -> error
    end
  end

  def iterate(io, <<size::32-little-signed, _::binary>> = acc, func, index) when byte_size(acc) > size do
    <<doc::binary-size(size), next::binary>> = acc

    case decode(doc, func) do
      {:ok, _} -> iterate(io, next, func, index)
      error -> error
    end
  end

  def iterate({:file_descriptor, :prim_file, _} = io, <<_::binary>> = acc, func, _) do
    case IO.binread(io, @buf_size) do
      data when is_binary(data) ->
        iterate(io, acc <> data, func)
      :eof ->
        io
      {:error, reason} ->
        {:io_error, reason}
    end
  end

  def iterate(%File.Stream{} = io, <<_::binary>> = acc, func, index) do
    case Enum.at(io, index, :none) do
      data when is_binary(data) ->
        iterate(io, acc <> data, func, index + 1)
      ^index ->
        io
    end
  end

  defp decode(acc, func) do
    res = try do
      BSON.Decoder.decode(acc)
    rescue
      _ -> {:parse_error, :corrupted_document}
    end

    case res do
      %{} = doc ->
        apply_callback(doc, func)
      {:parse_error, reason} ->
        {:parse_error, reason}
      {:error, _} ->
        {:parse_error, :corrupted_document}
    end
  end

  defp apply_callback(doc, func) do
    case func.(doc) do
      :stop -> {:error, :callback_canceled}
      _ -> {:ok, :applied}
    end
  end
end
