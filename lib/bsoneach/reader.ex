defmodule BSONEach.Reader do
  @moduledoc """
  Helper module that allows to read and decode documents from IO stream one-by-one.
  """

  @doc """
  Read and decode BSON document from IO stream.

  It returns:

    * `{:ok, document}` - document is parsed successfully.
    * `:eof` - when IO stream reached to end of file.
    * `{:parse_error, reason}` - in case there was an error while parsing BSON document. Eg.: `:corrupted_document`.
    * `{:error, reason}` - in case [IO.binstream](http://elixir-lang.org/docs/stable/elixir/IO.html#binread/2)
    returned an error.

  Also it will pass all

  """
  @spec read(File.res | {:ok, File.res} | {:error, any}) :: {:ok, any} | :eof | {:parse_error, any} | {:error, any}
  def read({:error, _reason} = err), do: err
  def read({:ok, io}), do: read(io)
  def read({:file_descriptor, :prim_file, _} = io) do
    io
    |> IO.binread(4)
    |> read_body(io)
  end

  defp read_body(:eof, _io), do: :eof
  defp read_body({:error, reason}, _io), do: {:error, reason}
  defp read_body(<<size::32-little-signed>> = binsize, io) do
    body = io
    |> IO.binread(size - 4)

    binsize
    |> concat_body(body)
    |> decode
  end

  defp concat_body(<<_::32-little-signed>>, :eof), do: :eof
  defp concat_body(<<_::32-little-signed>>, {:error, reason}), do: {:error, reason}
  defp concat_body(<<_::32-little-signed>> = size, <<_::binary>> = body) do
    size <> body
  end

  defp decode(<<_size::32-little-signed, _body::binary>> = acc) do
    res = try do
      BSON.Decoder.document(acc)
    rescue
      _ -> {:parse_error, :corrupted_document}
    end

    case res do
      {document, <<>>} ->
        {:ok, document}
      {:parse_error, reason} ->
        {:parse_error, reason}
      {:error, _} ->
        {:parse_error, :corrupted_document}
    end
  end
end
