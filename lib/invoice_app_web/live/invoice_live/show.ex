defmodule InvoiceAppWeb.InvoiceLive.Show do
  use InvoiceAppWeb, :live_view

  alias InvoiceApp.Invoices
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

  defp page_title(:show), do: "Show Invoice"
  defp page_title(:edit), do: "Edit Invoice"

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset))
  end

  def due_date(date, days) do
    date
    |> Date.add(days)
    |> Calendar.strftime("%d %b %Y")
  end
end
