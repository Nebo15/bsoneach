defmodule IterativeBench do
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
    |> BSONEach.File.open
    |> BSONEach.each(&foo/1)
    |> File.close
  end

  bench "read and iterate 30 documents", [fixtures: get_fixtures()] do
    fixtures[:small]
    |> BSONEach.File.open
    |> BSONEach.each(&foo/1)
    |> File.close
  end

  bench "read and iterate 300 documents", [fixtures: get_fixtures()] do
    fixtures[:medium]
    |> BSONEach.File.open
    |> BSONEach.each(&foo/1)
    |> File.close
  end

  bench "read and iterate 3_000 documents", [fixtures: get_fixtures()] do
    fixtures[:large]
    |> BSONEach.File.open
    |> BSONEach.each(&foo/1)
    |> File.close
  end

  bench "read and iterate 30_000 documents", [fixtures: get_fixtures()] do
    fixtures[:xlarge]
    |> BSONEach.File.open
    |> BSONEach.each(&foo/1)
    |> File.close
  end

  def foo(_) do
    :nothing
  end
end
