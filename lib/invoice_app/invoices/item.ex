defmodule InvoiceApp.Invoices.Item do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias InvoiceApp.Invoices.Item

  embedded_schema do
    field :name, :string
    field :price, :decimal, default: 0
    field :quantity, :integer, default: 1
    field :total, :decimal, default: 0
  end

  @doc false
  def changeset(%Item{} = item, attrs) do
    required_fields = [:name, :quantity, :price]

    item
    |> cast(attrs, required_fields)
    |> validate_required(required_fields)
    |> calculate_total()
    |> validate_number(:price, greater_than_or_equal_to: 0)
    |> validate_number(:quantity, greater_than_or_equal_to: 1)
  end

  def calculate_total(changeset) do
    price = get_field(changeset, :price, 0)
    quantity = get_field(changeset, :quantity, 1)

    changeset
    |> put_change(:total, Decimal.mult(price, quantity))
  end
end
