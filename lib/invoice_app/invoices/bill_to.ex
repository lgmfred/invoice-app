defmodule InvoiceApp.Invoices.BillTo do
  use Ecto.Schema

  import Ecto.Changeset

  alias InvoiceApp.Invoices.BillTo

  embedded_schema do
    field :city, :string
    field :name, :string
    field :country, :string
    field :email, :string
    field :post_code, :string
    field :street_address, :string
  end

  @doc false
  def changeset(%BillTo{} = to_address, attrs) do
    required_fields = [:name, :email, :street_address, :city, :post_code, :country]

    to_address
    |> cast(attrs, required_fields)
    |> validate_required(required_fields)
  end
end
