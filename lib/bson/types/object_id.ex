defmodule BSON.Types.ObjectId do
  @moduledoc """
  Represents BSON ObjectId type
  """
  defstruct [:value]

  @doc """
  Creates a new ObjectId from the consisting parts
  """
  def new(machine_id, proc_id, secs, counter) do
    value = <<secs       :: unsigned-big-32,
              machine_id :: unsigned-big-24,
              proc_id    :: unsigned-big-16,
              counter    :: unsigned-big-24>>
    %BSON.Types.ObjectId{value: value}
  end

  @doc """
  Converts string representation of ObjectId to a BSON.Types.ObjectId struct
  """
  def decode!(<< c0,  c1,  c2,  c3,  c4,  c5,
                c6,  c7,  c8,  c9,  c10, c11,
                c12, c13, c14, c15, c16, c17,
                c18, c19, c20, c21, c22, c23 >>) do
    << d(c0)::4,  d(c1)::4,  d(c2)::4,  d(c3)::4,
       d(c4)::4,  d(c5)::4,  d(c6)::4,  d(c7)::4,
       d(c8)::4,  d(c9)::4,  d(c10)::4, d(c11)::4,
       d(c12)::4, d(c13)::4, d(c14)::4, d(c15)::4,
       d(c16)::4, d(c17)::4, d(c18)::4, d(c19)::4,
       d(c20)::4, d(c21)::4, d(c22)::4, d(c23)::4 >>
  catch
    :throw, :error ->
      raise ArgumentError
  else
    value ->
      %BSON.Types.ObjectId{value: value}
  end

  @doc """
  Converts BSON.Types.ObjectId struct to a string representation
  """
  def encode!(%BSON.Types.ObjectId{value: value}), do: do_encode(value)

  def do_encode(<< l0::4, h0::4, l1::4, h1::4,  l2::4,  h2::4,  l3::4,  h3::4,
                   l4::4, h4::4, l5::4, h5::4,  l6::4,  h6::4,  l7::4,  h7::4,
                   l8::4, h8::4, l9::4, h9::4, l10::4, h10::4, l11::4, h11::4 >>) do
    << e(l0), e(h0), e(l1), e(h1), e(l2),  e(h2),  e(l3),  e(h3),
       e(l4), e(h4), e(l5), e(h5), e(l6),  e(h6),  e(l7),  e(h7),
       e(l8), e(h8), e(l9), e(h9), e(l10), e(h10), e(l11), e(h11) >>
  catch
    :throw, :error ->
      raise ArgumentError
  else
    value ->
      value
  end

  @compile {:inline, :d, 1}
  @compile {:inline, :e, 1}

  @chars Enum.concat(?0..?9, ?a..?f)

  for {char, int} <- Enum.with_index(@chars) do
    defp d(unquote(char)), do: unquote(int)
    defp e(unquote(int)),  do: unquote(char)
  end

  for {char, int} <- Enum.with_index(?A..?F) do
    defp d(unquote(char)), do: unquote(int)
  end

  defp d(_), do: throw :error

  defp e(_), do: throw :error

  defimpl Inspect do
    def inspect(objectid, _opts) do
      encoded = BSON.Types.ObjectId.encode!(objectid)
      "#BSON.Types.ObjectId<#{encoded}>"
    end
  end
end
