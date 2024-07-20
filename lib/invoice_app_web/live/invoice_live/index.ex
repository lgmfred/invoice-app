defmodule InvoiceAppWeb.InvoiceLive.Index do
  use InvoiceAppWeb, :live_view

  alias InvoiceApp.Invoices
  alias InvoiceApp.Invoices.Invoice
  alias InvoiceAppWeb.InvoiceLive.InvoiceForm

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(:invoices, Invoices.list_invoices())
     |> assign(:filter, %{status: ""})}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    invoice = Invoices.get_invoice!(id)
    changeset = InvoiceForm.new(invoice)

    socket
    |> assign(:page_title, "Edit Invoice")
    |> assign(:invoice, invoice)
    |> assign_form(changeset)
  end

  defp apply_action(socket, :new, _params) do
    changeset = InvoiceForm.new()

    socket
    |> assign(:page_title, "New Invoice")
    |> assign(:invoice, %Invoice{})
    |> assign_form(changeset)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Invoices")
    |> assign(:invoice, nil)
  end

  @impl true
  def handle_info({InvoiceAppWeb.InvoiceLive.FormComponent, {:saved, invoice}}, socket) do
    {:noreply, stream_insert(socket, :invoices, invoice)}
  end

  def assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  def badge_colors(:paid), do: "bg-green-100 text-green-500"
  def badge_colors(:pending), do: "bg-orange-100 text-orange-500"
  def badge_colors(:draft), do: "bg-gray-100 text-gray-500"

  def circle_fill(:paid), do: "fill-green-500"
  def circle_fill(:pending), do: "fill-orange-500"
  def circle_fill(:draft), do: "fill-gray-500"

  def badge_text(:paid), do: "Paid"
  def badge_text(:pending), do: "Pending"
  def badge_text(:draft), do: "Draft"

  defp status_options do
    [
      Filter: "",
      Paid: "paid",
      Pending: "pending",
      Draft: "draft"
    ]
  end

  def count_invoices([]), do: 0
  def count_invoices([_]), do: 1
  def count_invoices(invoices), do: Enum.count(invoices)

  defp total_amount(items) do
    items
    |> Enum.reduce(0, fn item, acc -> Decimal.add(acc, item.total) end)
  end
end
