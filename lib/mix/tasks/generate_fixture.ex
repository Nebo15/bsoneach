defmodule Mix.Tasks.GenerateFixture do
  use Mix.Task
  import BSONEach.Mix.Utils

  @moduledoc """
  This module defines a task to generate sample BSON file that can be used as fixture.

  ## Examples

      $ mix generate_fixture 100 test.bson
  """

  @shortdoc "Generate a BSON fixture."

  def run(args) do
    [size, path] = args
    {size, _} = Integer.parse(size) || 100
    Faker.start
    create_fixture(path, size, &create_list_record/1)
    IO.puts "Generated a fixture with " <> Integer.to_string(size) <> " document(s)."
  end

  defp create_list_record(index) do
    %{
      "id" => to_string(index),
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
        "id" => "borrower:" <> to_string(index),
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
    }
  end
end
