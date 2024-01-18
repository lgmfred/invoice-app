defmodule InvoiceApp.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `InvoiceApp.Accounts` context.
  """

  alias Faker.Address
  alias Faker.Person.Fr
  alias Faker.Phone.PtPt

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def unique_username, do: "username#{System.unique_integer()}"
  def valid_user_password, do: "hello world!"

  def valid_address_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      country: Address.country(),
      city: Address.city(),
      street_address: Address.street_address(true),
      postal_code: Address.postcode(),
      phone_number: "0#{PtPt.number()}"
    })
  end

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password(),
      full_name: Fr.name(),
      username: unique_username()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> InvoiceApp.Accounts.register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
