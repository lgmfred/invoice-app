defmodule InvoiceApp.InvoicesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `InvoiceApp.Invoices` context.
  """

  alias Faker.Address
  alias Faker.Internet
  alias Faker.Lorem
  alias Faker.Person

  @doc """
  Generate a invoice.
  """
  def invoice_fixture(user, attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        bill_from: %{
          city: Address.city(),
          country: Address.country_code(),
          post_code: Address.postcode(),
          street_address: Address.street_address()
        },
        bill_to: %{
          city: Address.city(),
          name: Person.name(),
          country: Address.country_code(),
          email: Internet.email(),
          post_code: Address.postcode(),
          street_address: Address.street_address()
        },
        items: [
          %{
            name: Lorem.word(),
            quantity: Enum.random(1..5),
            price: Enum.random(10..200),
            total: Enum.random(100..1000)
          }
        ],
        date: Date.utc_today(),
        payment_term: Enum.random([1, 7, 14, 30]),
        project_description: Lorem.paragraph(1),
        email_preferences: %{newsletter: true, payment_reminder: true, sign_in: true}
      })

    {:ok, invoice} = InvoiceApp.Invoices.create_invoice(user, attrs)

    invoice
  end
end
