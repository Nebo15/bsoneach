ExUnit.start()
ExUnit.configure(exclude: [bson_wip: true])

defmodule Test.Support.DocumentAssertions do
  use ExUnit.Case

  def assert_document(%{} = document) do
    assert %{
      "id" => _,
      "currency" => "EUR",
      "product_type" => "PDL",
      "term" => 30,
      "term_unit" => "DAYS",
      "sell_date" => "2016-08-19T09:51:32.915Z",
      "principal_amount" => 20.25,
      "status" => "ACTIVE",
      "additional_attributes" => %{
        "buy_back_available" => true
      },
      "borrower" => %{
        "id" => "borrower:" <> _,
        "first_name" => "John",
        "last_name" => "Smith",
        "attributes" => [
          %{
            "name" => "group",
            "value" => "VIP"
          }
        ],
        "addresses" => [
          %{
            "address_type" => "REGISTRATION",
            "zip" => "90001",
            "country" => "ES",
            "region" => "catalonia",
            "city" => "barcelona"
          }
        ]
      }
    } = document
  end
end
