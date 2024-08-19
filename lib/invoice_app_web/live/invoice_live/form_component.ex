defmodule InvoiceAppWeb.InvoiceLive.FormComponent do
  use InvoiceAppWeb, :live_component

  alias InvoiceApp.Invoices
  alias InvoiceAppWeb.CustomComponents
  alias InvoiceAppWeb.InvoiceLive.InvoiceForm

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-4 text-[#0C0E16] dark:text-white">
      <h2 :if={@action == :new} class="font-bold"><%= @title %></h2>
      <h2 :if={@action == :edit} class="font-bold">
        <span>Edit</span>
        <span class="text-[#858BB2]">#</span><span class="uppercase"><%= String.slice(@invoice.id, 0, 6) %></span>
      </h2>

      <.form
        for={@form}
        id="invoice-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="flex flex-col gap-4"
      >
        <div>
          <h2 class="font-bold text-[#7C5DFA]">Bill From</h2>
          <.inputs_for :let={bill_from} field={@form[:bill_from]}>
            <div class="grid grid-cols-2 md:grid-cols-3 gap-4">
              <div class="col-span-2 md:col-span-3">
                <CustomComponents.input
                  field={bill_from[:street_address]}
                  type="text"
                  label="Street address"
                />
              </div>
              <div class="col-span-1">
                <CustomComponents.input field={bill_from[:city]} type="text" label="City" class="" />
              </div>
              <div class="col-span-1">
                <CustomComponents.input
                  field={bill_from[:post_code]}
                  type="text"
                  label="Post code"
                  class=""
                />
              </div>
              <div class="col-span-2 md:col-span-1">
                <CustomComponents.input
                  field={bill_from[:country]}
                  type="select"
                  label="Country"
                  options={country_options()}
                  class="col-span-2"
                />
              </div>
            </div>
          </.inputs_for>
        </div>
        <div>
          <h2 class="font-bold text-[#7C5DFA]">Bill To</h2>
          <.inputs_for :let={bill_to} field={@form[:bill_to]}>
            <div class="grid grid-cols-2 md:grid-cols-3 gap-4">
              <div class="col-span-2 md:col-span-3">
                <CustomComponents.input field={bill_to[:name]} type="text" label="Client's Name" />
              </div>
              <div class="col-span-2 md:col-span-3">
                <CustomComponents.input field={bill_to[:email]} type="email" label="Client's Email" />
              </div>
              <div class="col-span-2 md:col-span-3">
                <CustomComponents.input
                  field={bill_to[:street_address]}
                  type="text"
                  label="Street Address"
                />
              </div>
              <div class="col-span-1">
                <CustomComponents.input field={bill_to[:city]} type="text" label="City" />
              </div>
              <div class="col-span-1">
                <CustomComponents.input field={bill_to[:post_code]} type="text" label="Post Code" />
              </div>
              <div class="col-span-2 md:col-span-1">
                <CustomComponents.input
                  field={bill_to[:country]}
                  type="select"
                  label="Country"
                  options={country_options()}
                  required
                />
              </div>
            </div>
          </.inputs_for>
        </div>
        <div class="flex flex-col md:flex-row gap-4 justify-between">
          <div class="grow">
            <CustomComponents.input field={@form[:date]} type="date" label="Invoice Date" />
          </div>
          <div class="grow">
            <CustomComponents.input
              field={@form[:payment_term]}
              type="select"
              options={term_options()}
              label="Payment Term"
            />
          </div>
        </div>
        <CustomComponents.input
          field={@form[:project_description]}
          type="text"
          label="Project Description"
        />
        <div class="flex flex-col gap-4">
          <h2 class="font-bold text-[#777F98]">Item List</h2>
          <table class="w-full">
            <thead>
              <tr class="text-left text-[#7E88C3] dark:text-[#DFE3FA]">
                <th>Item Name</th>
                <th>Qty</th>
                <th>Price</th>
                <th>Total</th>
                <th class="sr-only">Delete</th>
              </tr>
            </thead>
            <tbody>
              <.inputs_for :let={item} field={@form[:items]}>
                <input name={@form[:item_sort].name <> "[]"} type="hidden" value={item.index} />
                <tr>
                  <td>
                    <CustomComponents.input field={item[:name]} type="text" placeholder="Item Name" />
                  </td>
                  <td>
                    <CustomComponents.input field={item[:quantity]} type="number" placeholder="1" />
                  </td>
                  <td>
                    <CustomComponents.input field={item[:price]} type="number" placeholder="0.00" />
                  </td>
                  <td>
                    <CustomComponents.input
                      field={item[:total]}
                      type="number"
                      placeholder="0.00"
                      readonly="true"
                    />
                  </td>
                  <td>
                    <button
                      name={@form[:item_drop].name <> "[]"}
                      value={item.index}
                      phx-click={JS.dispatch("change")}
                      type="button"
                    >
                      <.icon name="hero-trash" />
                    </button>
                  </td>
                </tr>
              </.inputs_for>
            </tbody>
          </table>
          <button
            type="button"
            name={@form[:item_sort].name <> "[]"}
            value="new"
            phx-click={JS.dispatch("change")}
            class="w-full rounded-full bg-[#F9FAFE] dark:bg-[#252945] px-4 py-2.5 text-sm font-semibold
              text-[#7E88C3] dark:text-[#DFE3FA] shadow-sm hover:bg-indigo-500 focus-visible:outline
              focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
          >
            + Add New Item
          </button>
          <input type="hidden" name={@form[:item_drop].name <> "[]"} />
        </div>
        <div class="flex justify-between">
          <.link
            :if={@action == :new}
            navigate={@patch}
            class="rounded-full bg-[#F9FAFE] dark:bg-[#F9FAFE] px-4 py-2.5 text-sm font-semibold
              text-[#7E88C3] dark:text-[#7E88C3] shadow-sm hover:bg-[indigo-500] focus-visible:outline
              focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
          >
            Discard
          </.link>
          <div :if={@action == :edit}></div>

          <div class="flex gap-4">
            <button
              :if={@action == :new}
              type="submit"
              name="save-as"
              value="draft"
              class="rounded-full bg-[#373B53] px-4 py-2.5 text-sm font-semibold text-[#888EB0]
                dark:text-[#DFE3FA] shadow-sm focus-visible:outline focus-visible:outline-2"
            >
              Save as Draft
            </button>

            <.link
              :if={@action == :edit}
              navigate={@patch}
              class="rounded-full bg-[#F9FAFE] dark:bg-[#252945] px-4 py-2.5 text-sm font-semibold text-[#7E88C3]
                dark:text-[#DFE3FA] shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2
                focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
            >
              Cancel
            </.link>

            <button
              type="submit"
              name="save-as"
              value="regular"
              class="rounded-full bg-[#7C5DFA] px-4 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
            >
              Save <%= if @action == :new, do: "& Send", else: "Changes" %>
            </button>
          </div>
        </div>
      </.form>
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

  def handle_event("save", invoice_params, socket) do
    save_invoice(socket, socket.assigns.action, invoice_params)
  end

  defp save_invoice(socket, :edit, %{"invoice_form" => params}) do
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

  defp save_invoice(socket, :new, %{"save-as" => status, "invoice_form" => params}) do
    form = socket.assigns.form
    user = socket.assigns.current_user
    params = if status == "draft", do: Map.put(params, "status", "draft"), else: params

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
    ["Next 1 Day": 1, "Next 7 Days": 7, "Next 14 Days": 14, "Next 30 Days": 30]
  end

  def items_total(items) do
    items
    |> Enum.reduce(0, fn item, acc ->
      acc + item.quantity * item.price
    end)
  end

  def item_total(item) do
    item.quantity * item.price
  end

  def country_options do
    tl =
      Countries.all()
      |> Enum.into(%{}, fn x -> {x.name, x.alpha2} end)
      |> Enum.sort()

    [{"Choose Country", ""} | tl]
  end
end
