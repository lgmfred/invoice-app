defmodule InvoiceAppWeb.InvoicesLive do
  use InvoiceAppWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        invoices: [],
        filter: %{status: ""}
      )

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-20">
      <.list_page_actions invoices={@invoices} filter={@filter} />

      <div class="mx-auto flex flex-col text-center">
        <.no_invoices :if={@invoices == []} />
      </div>
    </div>
    """
  end

  def no_invoices(assigns) do
    ~H"""
    <div class="flex flex-col gap-10">
      <img src={~p"/images/open-envelope.svg"} />
      <div>
        <h3 class="mt-2 font-semibold">There is nothing here</h3>
        <p class="mt-1 text-sm text-gray-500">
          Create an invoice by clicking the <br /> <span class="font-bold">New Invoice</span>
          button and get started
        </p>
      </div>
    </div>
    """
  end

  def list_page_actions(assigns) do
    ~H"""
    <div class="flex justify-between">
      <div class="flex flex-col">
        <h3 class="font-semibold">Invoices</h3>
        <p class="text-sm text-gray-500">
          <%= count_invoices(@invoices) %>
        </p>
      </div>
      <div class="flex gap-4">
        <form class="flex">
          <label for="invoice-status" class="sr-only">
            Invoice status
          </label>

          <select
            name="status"
            class="bg-[#F8F8FB] dark:bg-[#141625] border-none rounded-lg font-semibold cursor-pointer focus:outline-none"
          >
            <%= Phoenix.HTML.Form.options_for_select(
              status_options(),
              @filter.status
            ) %>
          </select>
        </form>

        <button
          type="button"
          class="inline-flex items-center gap-x-2 rounded-full bg-[#7C5DFA] px-2 py-0 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
        >
          <svg class="-ml-0.5 h-8 w-8" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
            <path
              fill-rule="evenodd"
              d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.857-9.809a.75.75 0 00-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 10-1.06 1.061l2.5 2.5a.75.75 0 001.137-.089l4-5.5z"
              clip-rule="evenodd"
            />
          </svg>
          New <span class="hidden md:inline"> Invoice</span>
        </button>
      </div>
    </div>
    """
  end

  defp status_options do
    [
      Filter: "",
      Paid: "paid",
      Pending: "pending",
      Draft: "draft"
    ]
  end

  def count_invoices([]), do: "No invoices"
  def count_invoices([_]), do: "1 invoice"
  def count_invoices(invoices), do: "#{Enum.count(invoices)} invoices"
end
