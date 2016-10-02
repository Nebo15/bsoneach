defmodule BSON.TypesTest do
  use ExUnit.Case, async: true

  test "inspect BSON.Types.Binary" do
    value = %BSON.Types.Binary{binary: <<1, 2, 3>>}
    assert inspect(value) == "#BSON.Types.Binary<010203>"

    value = %BSON.Types.Binary{binary: <<1, 2, 3>>, subtype: :uuid}
    assert inspect(value) == "#BSON.Types.Binary<010203, uuid>"
  end

  @objectid %BSON.Types.ObjectId{value: <<29, 32, 69, 244, 101, 119, 228, 28, 61, 24, 21, 215>>}
  @string   "1d2045f46577e41c3d1815d7"

  test "inspect BSON.Types.ObjectId" do
    assert inspect(@objectid) == "#BSON.Types.ObjectId<#{@string}>"
  end

  test "BSON.Types.ObjectId.encode!/1" do
    assert BSON.Types.ObjectId.encode!(@objectid) == @string

    assert_raise FunctionClauseError, fn ->
      BSON.Types.ObjectId.encode!("")
    end
  end

  test "BSON.Types.ObjectId.decode!/1" do
    assert BSON.Types.ObjectId.decode!(@string) == @objectid

    assert_raise FunctionClauseError, fn ->
      BSON.Types.ObjectId.decode!("")
    end
  end

  test "inspect BSON.Types.DateTime" do
    value = %BSON.Types.DateTime{utc: 1437940203000}
    assert inspect(value) == "#BSON.Types.DateTime<2015-07-26T19:50:03Z>"
  end

  test "inspect BSON.Types.Regex" do
    value = %BSON.Types.Regex{pattern: "abc"}
    assert inspect(value) == ~S(#BSON.Types.Regex<"abc">)

    value = %BSON.Types.Regex{pattern: "abc", options: "i"}
    assert inspect(value) == ~S(#BSON.Types.Regex<"abc", "i">)
  end

  test "inspect BSON.Types.JavaScript" do
    value = %BSON.Types.JavaScript{code: "this === null"}
    assert inspect(value) == ~S(#BSON.Types.JavaScript<"this === null">)

    value = %BSON.Types.JavaScript{code: "this === value", scope: %{value: nil}}
    assert inspect(value) == ~S(#BSON.Types.JavaScript<"this === value", %{value: nil}>)
  end

  test "inspect BSON.Types.Timestamp" do
    value = %BSON.Types.Timestamp{value: 1412180887}
    assert inspect(value) == "#BSON.Types.Timestamp<1412180887>"
  end
end
