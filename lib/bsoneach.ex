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
  import BSONEach.Iterative

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

  @doc """
  See `BSONEach.Stream.resource/1`.
  """
  defdelegate stream(path, on_corrupted \\ :stop), to: BSONEach.Stream, as: :resource
end
