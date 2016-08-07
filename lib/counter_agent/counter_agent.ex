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
