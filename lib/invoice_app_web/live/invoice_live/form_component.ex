defmodule InvoiceAppWeb.InvoiceLive.FormComponent do
  alias InvoiceAppWeb.InvoiceLive.InvoiceForm
  use InvoiceAppWeb, :live_component

  alias InvoiceApp.Invoices

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage invoice records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="invoice-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.inputs_for :let={bill_from} field={@form[:bill_from]}>
          <.input field={bill_from[:street_address]} type="text" label="Street address" />
          <.input field={bill_from[:city]} type="text" label="City" />
          <.input field={bill_from[:post_code]} type="text" label="Post code" />
          <.input field={bill_from[:country]} type="text" label="Country" />
        </.inputs_for>
        <.inputs_for :let={bill_to} field={@form[:bill_to]}>
          <.input field={bill_to[:name]} type="text" label="Client's Name" />
          <.input field={bill_to[:email]} type="email" label="Client's Email" />
          <.input field={bill_to[:street_address]} type="text" label="Street Address" />
          <.input field={bill_to[:city]} type="text" label="City" />
          <.input field={bill_to[:post_code]} type="text" label="Post Code" />
          <.input field={bill_to[:country]} type="text" label="Country" />
        </.inputs_for>
        <.input field={@form[:date]} type="date" label="Invoice Date" />
        <.input
          field={@form[:payment_term]}
          type="select"
          options={term_options()}
          label="Payment Term"
        />
        <.input field={@form[:project_description]} type="text" label="Project Description" />
        <.inputs_for :let={item} field={@form[:items]}>
          <input name={@form[:item_sort].name <> "[]"} type="hidden" value={item.id} />
          <.input field={item[:name]} type="text" label="Item Name" />
          <.input field={item[:quantity]} type="number" label="Qty" />
          <.input field={item[:price]} type="number" label="Price" />
          <.input field={item[:total]} type="number" label="Total" />
        </.inputs_for>
        <button
          type="button"
          name={@form[:item_sort].name <> "[]"}
          value="new"
          phx-click={JS.dispatch("change")}
        >
          + Add New Item
        </button>
        <:actions>
          <.button phx-disable-with="Saving...">Save & Send</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def handle_event("validate", %{"invoice_form" => invoice_params}, socket) do
    changeset =
      socket.assigns.form
      |> InvoiceForm.validate(invoice_params)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"invoice_form" => invoice_params}, socket) do
    save_invoice(socket, socket.assigns.action, invoice_params)
  end

  defp save_invoice(socket, :edit, params) do
    form = socket.assigns.form
    invoice = socket.assigns.invoice

    with {:ok, %{invoice: invoice_data}} <- InvoiceForm.submit(form, params),
         {:ok, updated_invoice} <- Invoices.update_invoice(invoice, invoice_data) do
      notify_parent({:saved, updated_invoice})

      {:noreply,
       socket
       |> put_flash(:info, "Invoice updated successfully")
       |> push_patch(to: socket.assigns.patch)}
    else
      {:error, %Ecto.Changeset{} = _changeset} ->
        changeset = InvoiceForm.validate(socket.assigns.form, params)

        {:noreply,
         socket
         |> put_flash(:error, "Invalid data!")
         |> assign_form(changeset)}
    end
  end

  defp save_invoice(socket, :new, params) do
    form = socket.assigns.form
    user = socket.assigns.current_user

    with {:ok, %{invoice: invoice_data}} <- InvoiceForm.submit(form, params),
         {:ok, invoice} <- Invoices.create_invoice(user, invoice_data) do
      notify_parent({:saved, invoice})

      {:noreply,
       socket
       |> put_flash(:info, "Invoice created successfully")
       |> push_patch(to: socket.assigns.patch)}
    else
      {:error, %Ecto.Changeset{} = _changeset} ->
        changeset = InvoiceForm.validate(socket.assigns.form, params)

        {:noreply,
         socket
         |> put_flash(:error, "Invalid data!")
         |> assign_form(changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp term_options do
    ["Net 1 Day": 1, "Net 7 Days": 7, "Net 14 Days": 14, "Net 30 Days": 30]
  end
end
