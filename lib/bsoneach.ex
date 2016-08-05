defmodule BSONEach do
  @moduledoc """
    This module allows to apply each function to each document in a BSON file.

    Source file should be opened in :binary mode.

    ## Examples

        "sample.bson"
        |> File.open!([:read, :binary, :raw])
        |> BSONEach.each(&IO.inspect/1)
        |> File.close
  """

  @chunk_size 4096

  @spec each(IO.device, Func) :: IO.iodata | IO.nodata
  def each(io, func) when is_function(func) do
    iterate({io, <<>>, func})
  end

  defp iterate({io, <<size::32-little-signed, _::binary>> = acc, func}) when byte_size(acc) >= size do
    {doc, next} = decode(acc)
    func.(doc)
    iterate({io, next, func})
  end

  defp iterate({{:file_descriptor, :prim_file, _} = io, <<_::binary>> = acc, func}) do
    case IO.binread(io, @chunk_size) do
      data when is_binary(data) ->
        iterate({io, acc <> data, func})
      :eof ->
        io
      _err ->
        io
    end
  end

  defp decode(acc) do
    Bson.Decoder.document(acc, %Bson.Decoder{})
  end
end
