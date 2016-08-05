defmodule Mix.Tasks.GenerateFixture do
  use Mix.Task

  @moduledoc """
    This module defines a task to generate sample BSON file that can be used as fixture.

    ## Examples

        $ mix generate_fixture 3 test.bson
  """

  @shortdoc "Generate a BSON fixture."

  def run(args) do
    [size, path] = args
    {size, _} = Integer.parse(size) || 100
    file = File.open!(path, [:write, :binary, :raw])

    Faker.start

    size
    |> create_sample_list
    |> Enum.map(&Bson.encode/1)
    |> Enum.each(&IO.binwrite(file, &1))

    File.close file

    IO.inspect "Generated a fixture with " <> Integer.to_string(size) <> " document(s)."
  end

  def create_list_record() do
    %{
      "id" => trunc(:rand.uniform()*100000000),
      "company_name" => "vivus.es",
      "company_id" => 1,
      "currency" => "EUR",
      "product_type" => "PDL",
      "term" => 30,
      "term_unit" => "days",
      "amount" => 22000,
      "start_date" => "2016-07-15",
      "end_date" => "2016-08-15",
      "actual_end_date" => "2016-08-15",
      "sell_date" => "2016-08-15",
      "principal_amount" => 20000,
      "interest_amount" => 2000,
      "fee_amount" => 0,
      "interest_rate" => 15,
      "apr" => 15.18,
      "status" => "ACTIVE",
      "AdditionalAttributes" => %{
        "buy_back_available" => true,
        "extended" => false,
        "additional_withdrawal" => false,
        "credit_score" => 0.729,
        "current_dpd" => 10,
        "max_dpd" => 10,
        "current_debt_amount" => 2500
      },
      "borrower" => %{
        "id" => trunc(:rand.uniform()*100000000),
        "first_name" => Faker.Name.first_name,
        "last_name" => Faker.Name.last_name,
        "date_of_birth" => "1980-07-15",
        "sex" => "M",
        "email" => Faker.Internet.email,
        "mobile_phone" => "+380111234567",
        "tax_id" => Faker.Code.issn,
        "residence" => "ES",
        "document_id" => "123456FT",
        "iban" => "ES9121000418450200051332",
        "income_frequency" => trunc(:rand.uniform()*10),
        "addresses" => [
          %{
            "address_type" => "registration",
            "zip" => Faker.Address.zip_code,
            "country" => Faker.Address.country_code,
            "region" => "catalonia",
            "city" => Faker.Address.city,
            "street" => Faker.Address.street_address,
            "building" => Faker.Address.building_number,
            "flat" => "143"
          }
        ]
      },
      "schedule" => [
        %{
          "id" => trunc(:rand.uniform()*100000000),
          "currency" => "EUR",
          "amount" => 22000,
          "outstanding_amount" => 22000,
          "principal_amount" => 20000,
          "outstanding_principal_amount" => 20000,
          "interest_amount" => 2000,
          "outstanding_interest_amount" => 2000,
          "fee_amount" => 0,
          "outstanding_fee_amount" => 0,
          "due_date" => "2016-08-15",
          "actual_date" => "2016-08-15",
          "status" => "Waiting"
        }
      ],
      "payment_split" => [
        %{
          "id" => trunc(:rand.uniform()*100000000),
          "currency" => "EUR",
          "paid_date" => "2016-08-01",
          "amount" => 20000,
          "amount_eq" => 20000,
          "currency_rate" => 1,
          "type" => "PRINCIPAL",
          "status" => "EXECUTED"
        }
      ]
    }
  end

  def create_sample_list(i) when i > 0 do
    i
    |> (&Range.new(1, &1)).()
    |> Stream.map(fn _ -> create_list_record() end)
  end
end
