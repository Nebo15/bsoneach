defmodule EachBench do
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

  bench "read and iterate 1 document", [fixtures: get_fixtures()] do
    fixtures[:single]
    |> File.open!([:read, :binary, :raw])
    |> BSONEach.each(&foo/1)
    |> File.close
  end

  bench "read and iterate 30 documents", [fixtures: get_fixtures()] do
    fixtures[:small]
    |> File.open!([:read, :binary, :raw])
    |> BSONEach.each(&foo/1)
    |> File.close
  end

  bench "read and iterate 300 documents", [fixtures: get_fixtures()] do
    fixtures[:medium]
    |> File.open!([:read, :binary, :raw])
    |> BSONEach.each(&foo/1)
    |> File.close
  end

  bench "read and iterate 3_000 documents", [fixtures: get_fixtures()] do
    fixtures[:large]
    |> File.open!([:read, :binary, :raw])
    |> BSONEach.each(&foo/1)
    |> File.close
  end

  bench "read and iterate 30_000 documents", [fixtures: get_fixtures()] do
    fixtures[:xlarge]
    |> File.open!([:read, :binary, :raw])
    |> BSONEach.each(&foo/1)
    |> File.close
  end

  bench "stream and iterate 1 document", [fixtures: get_fixtures()] do
    fixtures[:single]
    |> File.stream!([:read, :binary, :raw], 4096)
    |> BSONEach.each(&foo/1)
    |> File.close
  end

  bench "stream and iterate 30 documents", [fixtures: get_fixtures()] do
    fixtures[:small]
    |> File.stream!([:read, :binary, :raw], 4096)
    |> BSONEach.each(&foo/1)
    |> File.close
  end

  bench "stream and iterate 300 documents", [fixtures: get_fixtures()] do
    fixtures[:medium]
    |> File.stream!([:read, :binary, :raw], 4096)
    |> BSONEach.each(&foo/1)
    |> File.close
  end

  bench "stream and iterate 3_000 documents", [fixtures: get_fixtures()] do
    fixtures[:large]
    |> File.stream!([:read, :binary, :raw], 4096)
    |> BSONEach.each(&foo/1)
    |> File.close
  end

  bench "stream and iterate 30_000 documents", [fixtures: get_fixtures()] do
    fixtures[:xlarge]
    |> File.stream!([:read, :binary, :raw], 4096)
    |> BSONEach.each(&foo/1)
    |> File.close
  end

  def foo(_) do
    :nothing
  end
end
