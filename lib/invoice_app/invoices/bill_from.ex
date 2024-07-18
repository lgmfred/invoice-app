defmodule InvoiceApp.Invoices.BillFrom do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias InvoiceApp.Invoices.BillFrom

  embedded_schema do
    field :city, :string
    field :country, :string
    field :post_code, :string
    field :street_address, :string
  end

  @doc false
  def changeset(%BillFrom{} = from_address, attrs) do
    required_fields = [:street_address, :city, :post_code, :country]

    from_address
    |> cast(attrs, required_fields)
    |> validate_required(required_fields)
  end
end
