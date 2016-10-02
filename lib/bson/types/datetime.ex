defmodule BSON.Types.DateTime do
  @moduledoc """
  Represents BSON DateTime type
  """

  defstruct [:utc]

  @epoch :calendar.datetime_to_gregorian_seconds({{1970, 1, 1}, {0, 0, 0}})

  @doc """
  Converts `BSON.Types.DateTime` into a `{{year, month, day}, {hour, min, sec, usec}}`
  tuple.
  """
  def to_datetime(%BSON.Types.DateTime{utc: utc}) do
    seconds = div(utc, 1000) + @epoch
    usec = rem(utc, 1000) * 1000
    {date, {hour, min, sec}} = :calendar.gregorian_seconds_to_datetime(seconds)
    {date, {hour, min, sec, usec}}
  end

  @doc """
  Converts `{{year, month, day}, {hour, min, sec, usec}}` into a `BSON.Types.DateTime`
  struct.
  """
  def from_datetime({date, {hour, min, sec, usec}}) do
    greg_secs = :calendar.datetime_to_gregorian_seconds({date, {hour, min, sec}})
    epoch_secs = greg_secs - @epoch
    %BSON.Types.DateTime{utc: epoch_secs * 1000 + div(usec, 1000)}
  end

  @doc """
  Converts `BSON.Types.DateTime` to its ISO8601 representation
  """
  def to_iso8601(%BSON.Types.DateTime{} = datetime) do
    {{year, month, day}, {hour, min, sec, usec}} = to_datetime(datetime)

    str = zero_pad(year, 4) <> "-" <> zero_pad(month, 2) <> "-" <> zero_pad(day, 2) <> "T" <>
          zero_pad(hour, 2) <> ":" <> zero_pad(min, 2) <> ":" <> zero_pad(sec, 2)

    case usec do
      0 -> str <> "Z"
      _ -> str <> "." <> zero_pad(usec, 6) <> "Z"
    end
  end

  defp zero_pad(val, count) do
    num = Integer.to_string(val)
    :binary.copy("0", count - byte_size(num)) <> num
  end

  defimpl Inspect do
    def inspect(%BSON.Types.DateTime{} = datetime, _opts) do
      "#BSON.Types.DateTime<#{BSON.Types.DateTime.to_iso8601(datetime)}>"
    end
  end
end
