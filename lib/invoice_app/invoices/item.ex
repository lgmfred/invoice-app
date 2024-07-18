defmodule InvoiceApp.Invoices.Item do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias InvoiceApp.Invoices.Item

  embedded_schema do
    field :name, :string
    field :price, :decimal
    field :quantity, :integer
    field :total, :decimal
  end

  @doc false
  def changeset(%Item{} = item, attrs) do
    required_fields = [:name, :quantity, :price, :total]

    item
    |> cast(attrs, required_fields)
    |> validate_required(required_fields)
    |> validate_number(:price, greater_than: 0)
    |> validate_number(:quantity, greater_than: 0)
    |> validate_number(:total, greater_than: 0)
  end
end
