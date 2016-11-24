defmodule BSONEach.StreamTest do
  use ExUnit.Case, async: true
  import Test.Support.DocumentAssertions
  doctest BSONEach.Stream

  setup_all do
    [
      notfound: "test/fixtures/x.bson",
      empty: "test/fixtures/0.bson",
      single: "test/fixtures/1.bson",
      three: "test/fixtures/3.bson",
      corrupted_single: "test/fixtures/1_corrupted.bson",
      # This file contains damaged document on 3-d position
      corrupted_three: "test/fixtures/3_corrupted.bson",
      # This file contains damaged document on 2-d position
      corrupted_three_mid: "test/fixtures/3_corrupted_mid.bson",
    ]
  end

  test "stream on non existent file", fixtures do
    assert {:error, :enoent} = fixtures[:notfound]
    |> BSONEach.Stream.resource
  end

  test "stream on empty file", fixtures do
    assert [] = fixtures[:empty]
    |> BSONEach.stream
    |> Enum.map(&throw/1)
  end

  test "stream on single document", fixtures do
    documents = fixtures[:single]
    |> BSONEach.Stream.resource(:stop, "some additional data")
    |> Enum.map(fn {document, additional_data} ->
      assert additional_data == "some additional data"
      assert_document document
    end)

    assert is_list(documents)
    assert length(documents) == 1
  end

  test "stream on three documents", fixtures do
    documents = fixtures[:three]
    |> BSONEach.Stream.resource
    |> Enum.map(fn document ->
      assert_document document
    end)

    assert is_list(documents)
    assert length(documents) == 3
  end

  test "stream on single corrupted document with :stop strategy", fixtures do
    documents = fixtures[:corrupted_single]
    |> BSONEach.Stream.resource
    |> Enum.map(&throw/1)

    assert is_list(documents)
    assert length(documents) == 0
  end

  test "stream on three corrupted documents with :stop strategy", fixtures do
    documents = fixtures[:corrupted_three]
    |> BSONEach.Stream.resource
    |> Enum.map(fn document ->
      assert_document document
    end)

    assert is_list(documents)
    assert length(documents) == 2
  end

  test "stream on three corrupted in middle documents with :stop strategy", fixtures do
    documents = fixtures[:corrupted_three_mid]
    |> BSONEach.Stream.resource
    |> Enum.map(fn document ->
      assert_document document
    end)

    assert is_list(documents)
    assert length(documents) == 1
  end

  test "stream on single corrupted document with :skip strategy", fixtures do
    documents = fixtures[:corrupted_single]
    |> BSONEach.Stream.resource(:skip)
    |> Enum.map(&throw/1)

    assert is_list(documents)
    assert length(documents) == 0
  end

  test "stream on three corrupted documents with :skip strategy", fixtures do
    documents = fixtures[:corrupted_three]
    |> BSONEach.Stream.resource(:skip)
    |> Enum.map(fn document ->
      assert_document document
    end)

    assert is_list(documents)
    assert length(documents) == 2
  end

  test "stream on three corrupted in middle documents with :skip strategy", fixtures do
    documents = fixtures[:corrupted_three_mid]
    |> BSONEach.Stream.resource(:skip)
    |> Enum.map(fn document ->
      assert_document document
    end)

    assert is_list(documents)
    assert length(documents) == 2
  end

  test "stream on single corrupted document with :report strategy", fixtures do
    documents = fixtures[:corrupted_single]
    |> BSONEach.Stream.resource(:report)
    |> Enum.map(&assert_document_or_error/1)

    assert is_list(documents)
    # Length is unpredictable here
  end

  test "stream on three corrupted documents with :report strategy", fixtures do
    documents = fixtures[:corrupted_three]
    |> BSONEach.Stream.resource(:report)
    |> Enum.map(&assert_document_or_error/1)

    assert is_list(documents)
    assert length(documents) == 3
  end

  test "stream on three corrupted in middle documents with :report strategy", fixtures do
    documents = fixtures[:corrupted_three_mid]
    |> BSONEach.Stream.resource(:report)
    |> Enum.map(&assert_document_or_error/1)

    assert is_list(documents)
    assert length(documents) == 3
  end

  defp assert_document_or_error({:error, reason}), do: {:error, reason}
  defp assert_document_or_error({:parse_error, reason}), do: {:parse_error, reason}
  defp assert_document_or_error(%{} = document), do: assert_document(document)
end
