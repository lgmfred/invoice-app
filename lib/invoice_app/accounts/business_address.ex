defmodule InvoiceApp.Accounts.BusinessAddress do
  @moduledoc """
  User business address embedded schema
  """
  use Ecto.Schema
  import Ecto.Changeset

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
  def changeset(%__MODULE__{} = address, attrs \\ %{}) do
    address
    |> cast(attrs, [:country, :city, :street_address, :postal_code, :phone_number])
    |> validate_required([:country, :city, :street_address, :postal_code, :phone_number])
  end
end
