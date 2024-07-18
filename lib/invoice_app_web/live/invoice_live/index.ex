defmodule InvoiceAppWeb.InvoiceLive.Index do
  use InvoiceAppWeb, :live_view

  alias InvoiceApp.Invoices
  alias InvoiceApp.Invoices.Invoice

  alias InvoiceAppWeb.InvoiceLive.InvoiceForm

  @impl true
  def mount(_params, _session, socket) do
    changeset = InvoiceForm.new()

    {:ok,
     stream(socket, :invoices, Invoices.list_invoices())
     |> assign_form(changeset)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Invoice")
    |> assign(:invoice, Invoices.get_invoice!(id))
  end

  defp apply_action(socket, :new, _params) do
    changeset = InvoiceForm.new()

    socket
    |> assign(:page_title, "New Invoice")
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

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    invoice = Invoices.get_invoice!(id)
    {:ok, _} = Invoices.delete_invoice(invoice)

    {:noreply, stream_delete(socket, :invoices, invoice)}
  end

  def assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
