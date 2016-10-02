defmodule BSONEach.ReaderTest do
  use ExUnit.Case, async: true
  import Test.Support.DocumentAssertions
  doctest BSONEach.Reader

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

  test "read non existent file", fixtures do
    assert {:error, :enoent} = fixtures[:notfound]
    |> BSONEach.File.open
    |> BSONEach.Reader.read
  end

  test "read empty file", fixtures do
    file = fixtures[:empty]
    |> BSONEach.File.open

    assert :eof == BSONEach.Reader.read(file)

    file
    |> BSONEach.File.close
  end

  test "read single document", fixtures do
    file = fixtures[:single]
    |> BSONEach.File.open

    assert {:ok, document} = file
    |> BSONEach.Reader.read

    assert_document document

    assert :eof == BSONEach.Reader.read(file)

    file
    |> BSONEach.File.close
  end

  test "read three documents", fixtures do
    file = fixtures[:three]
    |> BSONEach.File.open

    Enum.each(1..3, fn _ ->
      assert {:ok, document} = file
      |> BSONEach.Reader.read

      assert_document document
    end)

    assert :eof == BSONEach.Reader.read(file)

    file
    |> BSONEach.File.close
  end

  test "read single corrupted document", fixtures do
    file = fixtures[:corrupted_single]
    |> BSONEach.File.open

    assert {:parse_error, :corrupted_document} = file
    |> BSONEach.Reader.read

    file
    |> BSONEach.File.close
  end

  test "read three corrupted documents", fixtures do
    file = fixtures[:corrupted_three]
    |> BSONEach.File.open

    assert {:ok, document} = file
    |> BSONEach.Reader.read

    assert_document document

    assert {:ok, document} = file
    |> BSONEach.Reader.read

    assert_document document

    assert {:parse_error, :corrupted_document} = file
    |> BSONEach.Reader.read

    assert :eof == BSONEach.Reader.read(file)

    file
    |> BSONEach.File.close
  end

  test "read three corrupted in middle documents", fixtures do
    file = fixtures[:corrupted_three_mid]
    |> BSONEach.File.open

    assert {:ok, document} = file
    |> BSONEach.Reader.read

    assert_document document

    assert {:parse_error, :corrupted_document} = file
    |> BSONEach.Reader.read

    assert {:ok, document} = file
    |> BSONEach.Reader.read

    assert_document document

    assert :eof == BSONEach.Reader.read(file)

    file
    |> BSONEach.File.close
  end
end
