defmodule InvoiceAppWeb.InvoiceLive.Index do
  use InvoiceAppWeb, :live_view

  alias InvoiceApp.Invoices
  alias InvoiceApp.Invoices.Invoice
  alias InvoiceAppWeb.CustomComponents
  alias InvoiceAppWeb.InvoiceLive.InvoiceForm
  alias InvoiceAppWeb.InvoiceLive.Show

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    filter = %{user_id: user.id, status: ""}
    invoices = Invoices.list_invoices(filter)

    {:ok,
     socket
     |> stream(:invoices, invoices)
     |> assign(:filter, filter)}
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
  def handle_event("filter", %{"status" => status}, socket) do
    filter =
      socket.assigns.filter
      |> Map.replace!(:status, status)

    invoices = Invoices.list_invoices(filter)

    {:noreply,
     socket
     |> stream(:invoices, invoices, reset: true)
     |> assign(:filter, filter)}
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

  def grand_total(items) do
    items
    |> Enum.reduce(0, fn item, acc -> Decimal.add(acc, item.total) end)
    |> Number.Delimit.number_to_delimited(precision: 2)
  end
end
