defmodule BSONEach.EachReadTest do
  use ExUnit.Case, async: true
  import Test.Support.DocumentAssertions
  doctest BSONEach

  @fixtures [
    notfound: "test/fixtures/x.bson",
    empty: "test/fixtures/0.bson",
    single: "test/fixtures/1.bson",
    three: "test/fixtures/3.bson",
    many: "test/fixtures/30.bson",
    corrupted_single: "test/fixtures/1_corrupted.bson",
    corrupted_three: "test/fixtures/1_corrupted.bson",
    corrupted_three_mid: "test/fixtures/3_corrupted_mid.bson",
  ]

  test "read and iterate non existent file" do
    assert {:error, :enoent} = @fixtures[:notfound]
    |> BSONEach.File.open
    |> BSONEach.each(&IO.inspect/1)
  end

  test "read and iterate empty file" do
    try do
      Process.put(:enum_test_each, [])

      @fixtures[:empty]
      |> BSONEach.File.open
      |> BSONEach.each(&accumulate_structs(&1))
      |> File.close

      assert Enum.count(Process.get(:enum_test_each)) == 0
    after
      Process.delete(:enum_test_each)
    end
  end

  test "read and iterate 1 document" do
    @fixtures[:single]
    |> BSONEach.File.open
    |> BSONEach.each(&assert_document(&1))
    |> File.close
  end

  test "read and iterate three documents" do
    try do
      Process.put(:enum_test_each, [])

      @fixtures[:three]
      |> BSONEach.File.open
      |> BSONEach.each(&accumulate_structs(&1))
      |> File.close

      assert Enum.count(Process.get(:enum_test_each)) == 3
    after
      Process.delete(:enum_test_each)
    end
  end

  test "read and iterate many documents" do
    try do
      Process.put(:enum_test_each, [])

      @fixtures[:many]
      |> BSONEach.File.open
      |> BSONEach.each(&accumulate_structs(&1))
      |> File.close

      assert Enum.count(Process.get(:enum_test_each)) == 30
    after
      Process.delete(:enum_test_each)
    end
  end

  test "read and iterate single corrupted document" do
    assert {:parse_error, :corrupted_document} = @fixtures[:corrupted_single]
    |> BSONEach.File.open
    |> BSONEach.each(&IO.inspect/1)
  end

  test "read and iterate three corrupted documents" do
    assert {:parse_error, :corrupted_document} = @fixtures[:corrupted_three]
    |> BSONEach.File.open
    |> BSONEach.each(&IO.inspect/1)

    assert {:parse_error, :corrupted_document} = @fixtures[:corrupted_three_mid]
    |> BSONEach.File.open
    |> BSONEach.each(fn(_) -> :ok end)
  end

  test "cancel processing from a callback" do
    assert {:ok, {:error, :callback_canceled}} = @fixtures[:three]
    |> BSONEach.File.open
    |> BSONEach.each(fn _ -> :stop end)
  end

  def accumulate_structs(%{} = parse_result) do
    Process.put(:enum_test_each, [parse_result | Process.get(:enum_test_each)])
  end
end
