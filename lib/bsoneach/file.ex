defmodule BSONEach.File do
  @moduledoc """
  This module provides helper functions to correctly open files for BSONEach.

  Basically, it contains alias functions to `File` module with performance-tested modes.

  ## Examples

      "sample.bson"
      |> BSONEach.File.open
      #|> process_file_here
      |> BSONEach.File.close
  """

  @read_modes [:read, :binary, :raw, :read_ahead] # This modes showed best performance on benchmarks

  @doc """
  Opens the given `path`.
  """
  @spec open(File.Path.t) :: {:ok, File.res} | {:error, File.posix}
  def open(path) do
    path
    |> File.open(@read_modes)
  end

  @doc """
  Same as `File.close/0`.
  """
  @spec close(File.io_device) :: :ok | {:error, File.posix | :badarg | :terminated}
  def close(io) do
    io
    |> File.close
  end
end
