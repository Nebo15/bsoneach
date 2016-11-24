defmodule StreamBench do
  use Benchfella

  defp get_fixtures do
    [
      single: "test/fixtures/1.bson",
      small: "test/fixtures/30.bson",
      medium: "test/fixtures/300.bson",
      large: "test/fixtures/3000.bson",
      xlarge: "test/fixtures/30000.bson"
    ]
  end

  # Warning: you may need to set higher ulimit to run this bench on Mac OS:
  # $ sudo launchctl limit maxfiles 512 unlimited
  # bench "stream and iterate 1 document", [fixtures: get_fixtures()] do
  #   fixtures[:single]
  #   |> BSONEach.stream
  #   |> Enum.each(&foo/1)
  # end

  # bench "stream and iterate 30 documents", [fixtures: get_fixtures()] do
  #   fixtures[:small]
  #   |> BSONEach.stream
  #   |> Enum.each(&foo/1)
  # end

  bench "stream and iterate 300 documents", [fixtures: get_fixtures()] do
    fixtures[:medium]
    |> BSONEach.stream
    |> Enum.each(&foo/1)
  end

  bench "stream and iterate 3_000 documents", [fixtures: get_fixtures()] do
    fixtures[:large]
    |> BSONEach.stream
    |> Enum.each(&foo/1)
  end

  bench "stream and iterate 30_000 documents", [fixtures: get_fixtures()] do
    fixtures[:xlarge]
    |> BSONEach.stream
    |> Enum.each(&foo/1)
  end

  def foo(_) do
    :nothing
  end
end
