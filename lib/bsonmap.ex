defmodule BSONMap do
  @moduledoc """
    This module allows to apply map function to each document in a BSON file.

    Source file should be opened in :binary mode.

    ## Examples

        "sample.bson"
        |> File.open!([:read, :binary, :raw])
        |> BSONMap.map(&IO.inspect/1)
        |> File.close
  """

  @chunk_size 4096

  @spec map(IO.device, Func) :: IO.iodata | IO.nodata
  def map(io, func) when is_function(func) do
    map_portion({io, <<>>, func})
  end

  defp map_portion({io, <<>>, func}) do
    read_and_continue({io, <<>>, func})
  end

  defp map_portion({io, <<size::32-little-signed, _::binary>> = acc, func}) when byte_size(acc) > size do
    {doc, next} = decode(acc)

    func.(doc)

    map_portion({io, next, func})
  end

  defp map_portion({io, <<size::32-little-signed, _::binary>> = acc, func}) when byte_size(acc) == size do
    {doc, next} = decode(acc)

    func.(doc)

    read_and_continue({io, next, func})
  end

  defp map_portion({io, <<size::32-little-signed, _::binary>> = acc, func}) when byte_size(acc) < size do
    read_and_continue({io, acc, func})
  end

  defp read_and_continue({io, acc, func}, size \\ @chunk_size) do
    case IO.binread(io, size) do
      data when is_binary(data) ->
        map_portion({io, acc <> data, func})
      :eof ->
        io
      err ->
        io
    end
  end

  defp decode(acc) do
    Bson.Decoder.document(acc, %Bson.Decoder{})
  end
end
