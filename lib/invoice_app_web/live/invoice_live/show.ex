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
  def handle_event("delete-invoice", %{"id" => id}, socket) do
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

  def delete_invoice_modal(assigns) do
    ~H"""
    <div
      id="delete-invoice"
      class="relative hidden z-10"
      aria-labelledby="delete-invoice"
      role="dialog"
      aria-modal="false"
    >
      <div
        phx-click={JS.hide(to: "#delete-invoice")}
        class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"
      >
      </div>
      <div class="fixed inset-0 z-10 w-screen overflow-y-auto">
        <div class="flex min-h-full items-end justify-center p-4 items-center sm:p-0">
          <div class="relative transform overflow-hidden rounded-lg bg-white dark:bg-[#1E2139] px-4 pb-4 pt-5 shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-lg sm:p-6">
            <div>
              <h2 class="text-xl font-semibold leading-6" id="modal-title">
                Confirm Deletion
              </h2>
              <div class="mt-3 sm:mt-5">
                <p class="text-sm">
                  Are you sure you want to delete invoice #<%= String.slice(@invoice.id, 0, 6) %>? This action cannot be undone.
                </p>
              </div>
            </div>
            <div class="mt-4 flex gap-4 flex-row justify-end">
              <button
                data-role="cancel-delete"
                phx-click={JS.hide(to: "#delete-invoice")}
                type="button"
                class="inline-flex justify-end rounded-full px-3 py-2 font-semibold text-[#7E88C3] dark:text-[#DFE3FA] bg-[#F9FAFE] dark:bg-[#252945] shadow-sm hover:bg-gray-50"
              >
                Cancel
              </button>
              <button
                data-role="delete-invoice"
                phx-click={JS.push("delete-invoice", value: %{id: @invoice.id})}
                phx-click="delete-invoice"
                class="inline-flex md:px-6 justify-end rounded-full bg-[#EC5757] px-3 py-2 font-semibold text-white shadow-sm hover:bg-red-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-red-600"
              >
                Delete
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
