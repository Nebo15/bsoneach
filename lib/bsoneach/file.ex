defmodule BSONEach.File do
  @moduledoc """
  This module provides helper functions to correctly open files for BSONEach.

  Basically, it contains alias functions to `File` module with performance-tested modes.

  ## Examples

      "sample.bson"
      |> BSONEach.File.open

      "sample.bson"
      |> BSONEach.File.stream
  """

  @read_modes [:read, :binary, :raw, :read_ahead] # This modes showed best performance on benchmarks
  @buf_size 65_535 # Read files by 64 KB by-default

  @doc """
  Opens the given `path`.
  """
  @spec open(File.Path.t) :: {:ok, File.res} | {:error, File.posix}
  def open(path) do
    path
    |> File.open(@read_modes)
  end

  @doc """
  Returns a `File.Stream` for the given `path`.
  """
  @spec stream(File.Path.t) :: File.Stream.t | {:error, String.t}
  def stream(path) do
    try do
      path
      |> File.stream!(@read_modes, @buf_size)
    catch
      reason -> {:error, reason}
    end
  end
end
