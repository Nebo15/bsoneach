defmodule BSONEach do
  @moduledoc """
  This module allows to apply ```callback``` function to each document in a BSON file.

  Source file should be opened in :binary mode.

  ## Examples

      "sample.bson"
      |> File.open!([:read, :binary, :raw])
      |> BSONEach.each(&IO.inspect/1)
      |> File.close
  """

  @chunk_size 4096

  @doc """
  This module allows to apply ```callback``` function to each document in a BSON file.

  Source file should be opened in `:binary`, `:raw` modes. BSONEach can accept file streams.

  It returns:

  * `io_device` - when file is parsed successfully.
  * `{:parse_error, reason}` - in case there was an error while parsing BSON document.
  Possible reasons: `:corrupted_document`.
  * `{:io_error, reason}` - in case [IO.binstream](http://elixir-lang.org/docs/stable/elixir/IO.html#binread/2)
  returned an error.

  ## Examples

      "sample.bson"
      |> File.open!([:read, :binary, :raw])
      |> BSONEach.each(&IO.inspect/1)
      |> File.close
  """
  @spec each(IO.device, Func) :: IO.iodata | IO.nodata
  def each(io, func) when is_function(func) do
    iterate({io, <<>>, func})
  end

  defp iterate(recursion_data, index \\ 0)

  defp iterate({io, <<size::32-little-signed, _::binary>> = acc, func}, index) when byte_size(acc) >= size do
    case decode(acc) do
      {doc, next} ->
        func.(doc)
        iterate({io, next, func}, index)
      %Bson.Decoder.Error{what: error} ->
        get_error(error)
    end
  end

  defp iterate({{:file_descriptor, :prim_file, _} = io, <<_::binary>> = acc, func}, _) do
    case IO.binread(io, @chunk_size) do
      data when is_binary(data) ->
        iterate({io, acc <> data, func})
      :eof ->
        io
      {:error, reason} ->
        {:io_error, reason}
    end
  end

  defp iterate({%File.Stream{} = io, <<_::binary>> = acc, func}, index) do
    case Enum.at(io, index, :none) do
      data when is_binary(data) ->
        iterate({io, acc <> data, func}, index+1)
      :none ->
        io
      ^index ->
        io
    end
  end

  defp decode(acc) do
    Bson.Decoder.document(acc, %Bson.Decoder{})
  end

  defp get_error(_error) do
    # TODO: Map possible error reasons
    # [_ | :"document size"] = _error
    {:parse_error, :corrupted_document}
  end
end
