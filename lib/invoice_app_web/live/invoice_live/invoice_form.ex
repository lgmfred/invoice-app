defmodule InvoiceAppWeb.InvoiceLive.InvoiceForm do
  use Ecto.Schema

  import Ecto.Changeset

  alias InvoiceApp.Invoices.Invoice
  alias InvoiceAppWeb.InvoiceLive.InvoiceForm

  alias InvoiceApp.Invoices.BillFrom
  alias InvoiceApp.Invoices.BillTo
  alias InvoiceApp.Invoices.Item

  @valid_terms [1, 7, 14, 30]
  @default_attrs %{
    bill_from: Map.from_struct(%BillFrom{}),
    bill_to: Map.from_struct(%BillTo{}),
    date: Date.utc_today(),
    items: [Map.from_struct(%Item{})]
  }

  embedded_schema do
    embeds_one :bill_from, InvoiceApp.Invoices.BillFrom, on_replace: :update
    embeds_one :bill_to, InvoiceApp.Invoices.BillTo, on_replace: :update
    embeds_many :items, InvoiceApp.Invoices.Item, on_replace: :delete
    field :status, Ecto.Enum, values: [:paid, :pending, :draft], default: :pending
    field :date, :date
    field :payment_term, :integer, default: 1
    field :project_description, :string
    belongs_to :user, InvoiceApp.Accounts.User, on_replace: :update
  end

  def new(invoice \\ %InvoiceForm{}) do
    attrs = if invoice == %InvoiceForm{}, do: @default_attrs, else: %{}
    new_changeset(invoice, attrs)
  end

  def new_changeset(%Invoice{} = invoice, attrs) do
    %InvoiceForm{
      bill_from: invoice.bill_from,
      bill_to: invoice.bill_to,
      items: invoice.items,
      status: invoice.status,
      date: invoice.date,
      payment_term: invoice.payment_term,
      project_description: invoice.project_description
    }
    |> changeset(attrs)
  end

  def new_changeset(%InvoiceForm{} = invoice, attrs) do
    invoice
    |> changeset(attrs)
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
    |> cast_embed(:items,
      with: &Item.changeset/2,
      required: true,
      sort_param: :item_sort,
      drop_param: :item_drop
    )
  end

  def validate(form, params) do
    form.source.data
    |> calculate_items_totals()
    |> changeset(params)
    |> Map.put(:action, :validate)
  end

  def submit(form, invoice_params) do
    form.source.data
    |> calculate_items_totals()
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

  defp calculate_items_totals(invoice) do
    %InvoiceForm{invoice | items: Enum.map(invoice.items, &item_total/1)}
  end

  def item_total(item) do
    %Item{item | total: Decimal.mult(item.price, item.quantity)}
  end

  def change_invoice_form(%InvoiceForm{} = invoice, attrs \\ %{}) do
    InvoiceForm.changeset(invoice, attrs)
  end
end
