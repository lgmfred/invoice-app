defmodule InvoiceAppWeb.InvoiceLive.Show do
  use InvoiceAppWeb, :live_view

  alias InvoiceApp.Invoices
  alias InvoiceAppWeb.CustomComponents
  alias InvoiceAppWeb.InvoiceLive.Index
  alias InvoiceAppWeb.InvoiceLive.InvoiceForm

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    invoice = Invoices.get_invoice!(id)
    changeset = InvoiceForm.new(invoice)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:invoice, invoice)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    invoice = Invoices.get_invoice!(id)
    {:ok, _} = Invoices.delete_invoice(invoice)

    {:noreply, push_navigate(socket, to: ~p"/invoices")}
  end

  def handle_event("change-status", %{"id" => id}, socket) do
    invoice = Invoices.get_invoice!(id)
    status = change_status(invoice.status)
    {:ok, invoice} = Invoices.update_invoice(invoice, %{status: status})
    {:noreply, push_patch(socket, to: ~p"/invoices/#{invoice.id}")}
  end

  defp page_title(:show), do: "Show Invoice"
  defp page_title(:edit), do: "Edit Invoice"

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset))
  end

  def due_date(invoice) do
    invoice.date
    |> Date.add(invoice.payment_term)
    |> Calendar.strftime("%d %b %Y")
  end

  def change_status(status) do
    %{
      :paid => "draft",
      :pending => "paid",
      :draft => "pending"
    }[status]
  end

  def status_change_text(status) do
    %{
      :paid => "Mark as Draft",
      :pending => "Mark as Paid",
      :draft => "Mark as Pending"
    }[status]
  end

  defp grand_total(items) do
    items
    |> Enum.reduce(0, fn item, acc -> Decimal.add(acc, item.total) end)
    |> Number.Delimit.number_to_delimited(precision: 2)
  end
end
