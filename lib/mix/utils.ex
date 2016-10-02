defmodule BSONEach.Mix.Utils do
  @moduledoc """
  Helper module that provides an easy way to write BSON fixtures generator.
  """

  defmodule CounterAgent do
    @moduledoc false

    @doc false
    def new do
      Agent.start_link(fn -> 0 end, name: __MODULE__)
    end

    @doc false
    def click(_) do
      click
    end

    @doc false
    def click do
      Agent.get_and_update(__MODULE__, fn(n) -> {n + 1, n + 1} end)
    end

    @doc false
    def set(new_value) do
      Agent.update(__MODULE__, fn(_n) -> new_value end)
    end

    @doc false
    def get do
      Agent.get(__MODULE__, fn(n) -> n end)
    end
  end

  @doc """
  Creates fixture file with `count` elements of BSON records.
  Document contents are derived from `record_cb` function.

  `record_cb` function will receive element index as first argument.
  """
  def create_fixture(path, count, record_cb) when is_binary(path) and is_integer(count) and is_function(record_cb) do
    file = File.open!(path, [:write, :binary, :raw])

    count
    |> create_list(record_cb)
    |> Enum.map(&BSON.Encoder.encode/1)
    |> Enum.each(&IO.binwrite(file, &1))

    File.close file
  end

  defp create_list(count, record_cb) do
    count
    |> (&Range.new(1, &1)).()
    |> Stream.map(record_cb)
  end
end
