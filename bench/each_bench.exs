defmodule EachBench do
  use Benchfella

  defp get_fixtures do
    [
      single: "test/fixtures/1.bson",
      small: "test/fixtures/30.bson",
      medium: "test/fixtures/300.bson",
      large: "test/fixtures/30000.bson"
    ]
  end

  # before_each_bench _ do
  #   fixtures = get_fixtures()

  #   {:ok, tid}
  # end

  # after_each_bench tid do
  #   IO.inspect length(:ets.tab2list(tid))
  #   :ets.delete(tid)
  # end

  bench "map 1 document", [fixtures: get_fixtures()] do
    fixtures[:single]
    |> File.open!([:read, :binary, :raw])
    |> BSONEach.each(&foo/1)
    |> File.close
  end

  bench "map 30 documents", [fixtures: get_fixtures()] do
    fixtures[:small]
    |> File.open!([:read, :binary, :raw])
    |> BSONEach.each(&foo/1)
    |> File.close
  end

  bench "map 300 documents", [fixtures: get_fixtures()] do
    fixtures[:medium]
    |> File.open!([:read, :binary, :raw])
    |> BSONEach.each(&foo/1)
    |> File.close
  end

  bench "map 30_000 documents", [fixtures: get_fixtures()] do
    fixtures[:large]
    |> File.open!([:read, :binary, :raw])
    |> BSONEach.each(&foo/1)
    |> File.close
  end

  def foo(_) do
    :nothing
  end
end
