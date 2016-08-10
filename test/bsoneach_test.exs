defmodule BSONEachTest do
  use ExUnit.Case, async: true
  doctest BSONEach

  @single_fixture_document %{"AdditionalAttributes" => %{"additional_withdrawal" => false,
    "buy_back_available" => true, "credit_score" => 0.729,
    "current_debt_amount" => 2500, "current_dpd" => 10, "extended" => false,
    "max_dpd" => 10}, "actual_end_date" => "2016-08-15", "amount" => 22000,
  "apr" => 15.18,
  "borrower" => %{"addresses" => [%{"address_type" => "registration",
       "building" => "423", "city" => "Johnsonside", "country" => "SE",
       "flat" => "143", "region" => "catalonia", "street" => "93 Nash Neck",
       "zip" => "08878"}], "date_of_birth" => "1980-07-15",
    "document_id" => "123456FT", "email" => "ellis2059@johnson.biz",
    "first_name" => "Matt", "iban" => "ES9121000418450200051332",
    "id" => 36069373, "income_frequency" => 3, "last_name" => "Runolfsson",
    "mobile_phone" => "+380111234567", "residence" => "ES", "sex" => "M",
    "tax_id" => "74944509"}, "company_id" => 1, "company_name" => "vivus.es",
  "currency" => "EUR", "end_date" => "2016-08-15", "fee_amount" => 0,
  "id" => 44019998, "interest_amount" => 2000, "interest_rate" => 15,
  "payment_split" => [%{"amount" => 20000, "amount_eq" => 20000,
     "currency" => "EUR", "currency_rate" => 1, "id" => 30095100,
     "paid_date" => "2016-08-01", "status" => "EXECUTED",
     "type" => "PRINCIPAL"}], "principal_amount" => 20000,
  "product_type" => "PDL",
  "schedule" => [%{"actual_date" => "2016-08-15", "amount" => 22000,
     "currency" => "EUR", "due_date" => "2016-08-15", "fee_amount" => 0,
     "id" => 74854355, "interest_amount" => 2000, "outstanding_amount" => 22000,
     "outstanding_fee_amount" => 0, "outstanding_interest_amount" => 2000,
     "outstanding_principal_amount" => 20000, "principal_amount" => 20000,
     "status" => "Waiting"}], "sell_date" => "2016-08-15",
  "start_date" => "2016-07-15", "status" => "ACTIVE", "term" => 30,
  "term_unit" => "days"}

  @fixtures [
    notfound: "test/fixtures/x.bson",
    empty: "test/fixtures/0.bson",
    single: "test/fixtures/1.bson",
    multiple: "test/fixtures/3.bson",
    many: "test/fixtures/30.bson",
    corrupted_single: "test/fixtures/1_corrupted.bson",
    corrupted_multiple: "test/fixtures/1_corrupted.bson",
    corrupted_multiple_mid: "test/fixtures/3_corrupted_mid.bson",
    corrupted_length: "test/fixtures/1_corrupted_length.bson",
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

  test "stream and iterate empty file" do
    try do
      Process.put(:enum_test_each, [])

      @fixtures[:empty]
      |> BSONEach.File.stream
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
    |> BSONEach.each(&assert_document(&1, @single_fixture_document))
    |> File.close
  end

  test "stream and iterate 1 document" do
    @fixtures[:single]
    |> BSONEach.File.stream
    |> BSONEach.each(&assert_document(&1, @single_fixture_document))
    |> File.close
  end

  test "read and iterate multiple documents" do
    try do
      Process.put(:enum_test_each, [])

      @fixtures[:multiple]
      |> BSONEach.File.open
      |> BSONEach.each(&accumulate_structs(&1))
      |> File.close

      assert Enum.count(Process.get(:enum_test_each)) == 3
    after
      Process.delete(:enum_test_each)
    end
  end

  test "stream and iterate multiple documents" do
    try do
      Process.put(:enum_test_each, [])

      @fixtures[:multiple]
      |> BSONEach.File.stream
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

  test "read and iterate multiple corrupted documents" do
    assert {:parse_error, :corrupted_document} = @fixtures[:corrupted_multiple]
    |> BSONEach.File.open
    |> BSONEach.each(&IO.inspect/1)

    assert {:parse_error, :corrupted_document} = @fixtures[:corrupted_multiple_mid]
    |> BSONEach.File.open
    |> BSONEach.each(fn(_) -> :ok end)
  end

  test "stream and iterate multiple corrupted documents" do
    assert {:parse_error, :corrupted_document} = @fixtures[:corrupted_multiple]
    |> BSONEach.File.stream
    |> BSONEach.each(&IO.inspect/1)
  end

  test "cancel processing from a callback" do
    assert {:error, :callback_canceled} = @fixtures[:multiple]
    |> BSONEach.File.stream
    |> BSONEach.each(fn _ -> :stop end)
  end

  def assert_document(%{} = parse_result, %{} = document) do
    assert parse_result == document
  end

  def accumulate_structs(%{} = parse_result) do
    Process.put(:enum_test_each, [parse_result | Process.get(:enum_test_each)])
  end
end
