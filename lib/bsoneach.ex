defmodule BSONEach do
  @moduledoc """
  This module allows to apply ```callback``` function to each document in a BSON file.

  Source file should be opened in :binary mode.

  ## Examples

      "sample.bson"
      |> BSONEach.File.open
      |> BSONEach.each(&IO.inspect/1)
      |> File.close

  Callback function can return `:stop` atom to tell BSONEach to stop reading file and exit with error.
  Any other result will be counted as :ok.

  ### Examples

      def callback do
        :stop # Tell BSONEach to stop parsing file
      end

  """

  @buf_size 65_535 # Read files by 64 KB by-default

  @doc """
  This method allows to apply ```callback``` function to each document in a BSON file.

  Source file should be opened in `:binary`, `:raw` modes. BSONEach can accept file streams.

  It returns:

  * `io_device` - when file is parsed successfully.
  * `{:parse_error, reason}` - in case there was an error while parsing BSON document.
  Possible reasons: `:corrupted_document`.
  * `{:io_error, reason}` - in case [IO.binstream](http://elixir-lang.org/docs/stable/elixir/IO.html#binread/2)
  returned an error.
  * `{:error, :callback_canceled}` - in cases when callback function returned `:stop` atom to canceled file processing.

  ## Examples

      "sample.bson"
      |> File.open!([:read, :binary, :raw])
      |> BSONEach.each(&IO.inspect/1)
      |> File.close
  """
  @spec each(IO.device | File.Stream.t, Func) :: IO.iodata | IO.nodata
  def each({:ok, io}, func) do
    case each(io, func) do
      {:parse_error, _} = err -> err
      {:io_error, _} = err -> err
      io -> {:ok, io}
    end
  end

  def each({:error, reason}, _) do
    {:error, reason}
  end

  def each(io, func) when is_function(func) do
    iterate(io, <<>>, func)
  end

  defp iterate(io, buf, func, index \\ 0)

  defp iterate(io, <<size::32-little-signed, _::binary>> = acc, func, index) when byte_size(acc) == size do
    case decode(acc, func) do
      {:ok, _} -> iterate(io, <<>>, func, index)
      error -> error
    end
  end

  defp iterate(io, <<size::32-little-signed, _::binary>> = acc, func, index) when byte_size(acc) > size do
    <<doc::binary-size(size), next::binary>> = acc

    case decode(doc, func) do
      {:ok, _} -> iterate(io, next, func, index)
      error -> error
    end
  end

  defp iterate({:file_descriptor, :prim_file, _} = io, <<_::binary>> = acc, func, _) do
    case IO.binread(io, @buf_size) do
      data when is_binary(data) ->
        iterate(io, acc <> data, func)
      :eof ->
        io
      {:error, reason} ->
        {:io_error, reason}
    end
  end

  defp iterate(%File.Stream{} = io, <<_::binary>> = acc, func, index) do
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
