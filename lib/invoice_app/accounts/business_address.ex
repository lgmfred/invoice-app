defmodule InvoiceApp.Accounts.BusinessAddress do
  @moduledoc """
  User business address embedded schema
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias InvoiceApp.Accounts.BusinessAddress

  embedded_schema do
    field :country, :string
    field :city, :string
    field :street_address, :string
    field :postal_code, :string
    field :phone_number, :string
  end

  @doc """
  A business address changeset for registration.
  """
  def changeset(%BusinessAddress{} = address, attrs \\ %{}) do
    required_fields = [:country, :city, :street_address, :postal_code, :phone_number]

    address
    |> cast(attrs, required_fields)
    |> validate_required(required_fields)
  end
end
