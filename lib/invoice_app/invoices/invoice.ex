defmodule InvoiceApp.Invoices.Invoice do
  use Ecto.Schema

  import Ecto.Changeset

  alias InvoiceApp.Invoices.BillFrom
  alias InvoiceApp.Invoices.BillTo
  alias InvoiceApp.Invoices.Item

  schema "invoices" do
    embeds_one :bill_from, InvoiceApp.Invoices.BillFrom, on_replace: :update
    embeds_one :bill_to, InvoiceApp.Invoices.BillTo, on_replace: :update
    embeds_many :items, InvoiceApp.Invoices.Item, on_replace: :delete
    field :status, Ecto.Enum, values: [:paid, :pending, :draft], default: :pending
    field :date, :date

    field :payment_term, Ecto.Enum,
      values: [net_1_day: 1, net_7_days: 7, net_14_days: 14, net_30_days: 30],
      default: :net_1_day

    field :project_description, :string
    belongs_to :user, InvoiceApp.Accounts.User, on_replace: :update

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(invoice, attrs) do
    required_fields = [:date, :status, :payment_term, :project_description]

    invoice
    |> cast(attrs, required_fields)
    |> validate_required(required_fields)
    |> assoc_constraint(:user)
    |> cast_embed(:bill_from, with: &BillFrom.changeset/2, required: true)
    |> cast_embed(:bill_to, with: &BillTo.changeset/2, required: true)
    |> cast_embed(:items, with: &Item.changeset/2, required: true)
  end
end
