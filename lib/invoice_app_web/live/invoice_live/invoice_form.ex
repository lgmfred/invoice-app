defmodule InvoiceAppWeb.InvoiceLive.InvoiceForm do
  use Ecto.Schema

  import Ecto.Changeset

  alias InvoiceApp.Invoices.Invoice
  alias InvoiceAppWeb.InvoiceLive.InvoiceForm

  alias InvoiceApp.Invoices.BillFrom
  alias InvoiceApp.Invoices.BillTo
  alias InvoiceApp.Invoices.Item

  @valid_terms [1, 7, 14, 30]

  embedded_schema do
    embeds_one :bill_from, InvoiceApp.Invoices.BillFrom, on_replace: :update
    embeds_one :bill_to, InvoiceApp.Invoices.BillTo, on_replace: :update
    embeds_many :items, InvoiceApp.Invoices.Item, on_replace: :delete
    field :status, Ecto.Enum, values: [:paid, :pending, :draft], default: :pending
    field :date, :date
    field :payment_term, :integer, default: 1
    field :project_description, :string
    belongs_to :user, InvoiceApp.Accounts.User, on_replace: :update

    # # Helper fields for adding/deleting order
    # field :item_sort, {:array, :integer}
    # field :item_drop, {:array, :integer}
  end

  def new do
    default_attrs = %{
      bill_from: Map.from_struct(%BillFrom{}),
      bill_to: Map.from_struct(%BillTo{}),
      items: [Map.from_struct(%Item{})]
    }

    %InvoiceForm{}
    |> changeset(default_attrs)
  end

  def new(%Invoice{} = invoice) do
    %InvoiceForm{
      bill_from: invoice.bill_from,
      bill_to: invoice.bill_to,
      items: invoice.items,
      status: invoice.status,
      date: invoice.date,
      payment_term: invoice.payment_term,
      project_description: invoice.project_description
    }
    |> changeset(%{})
  end

  @doc false
  def changeset(invoice, attrs) do
    required_fields = [:date, :status, :payment_term, :project_description]

    invoice
    |> cast(attrs, required_fields)
    |> validate_required(required_fields)
    |> validate_inclusion(:payment_term, @valid_terms)
    |> cast_embed(:bill_from, with: &BillFrom.changeset/2, required: true)
    |> cast_embed(:bill_to, with: &BillTo.changeset/2, required: true)
    |> cast_embed(:items, with: &Item.changeset/2, required: true)
  end

  def validate(form, params) do
    form.source.data
    |> changeset(params)
    |> Map.put(:action, :validate)
  end

  def submit(form, invoice_params) do
    form.source.data
    |> changeset(invoice_params)
    |> apply_action(:insert)
    |> format_result()
  end

  defp format_result({:ok, data}) do
    output =
      %{
        invoice: %{
          bill_from: Map.from_struct(data.bill_from),
          bill_to: Map.from_struct(data.bill_to),
          items: Enum.map(data.items, &Map.from_struct/1),
          status: data.status,
          date: data.date,
          payment_term: data.payment_term,
          project_description: data.project_description
        }
      }

    {:ok, output}
  end

  defp format_result(error), do: error

  def change_invoice_form(%InvoiceForm{} = invoice, attrs \\ %{}) do
    InvoiceForm.changeset(invoice, attrs)
  end
end
