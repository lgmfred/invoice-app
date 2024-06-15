defmodule InvoiceAppWeb.InvoicesLive do
  use InvoiceAppWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        invoices: [%{status: :paid}, %{status: :pending}, %{status: :paid}, %{status: :draft}],
        filter: %{status: ""}
      )

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-20">
      <.list_page_actions invoices={@invoices} filter={@filter} />

      <div class="w-full flex flex-col text-center gap-4">
        <%= if Enum.empty?(@invoices) do %>
          <.no_invoices />
        <% else %>
          <.invoice_list_item :for={invoice <- @invoices} invoice={invoice} />
        <% end %>
      </div>
    </div>
    """
  end

  def no_invoices(assigns) do
    ~H"""
    <div class="flex flex-col gap-10">
      <div class="mx-auto">
        <img src={~p"/images/open-envelope.svg"} />
      </div>
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

  defp invoice_list_item(assigns) do
    status = assigns.invoice.status

    assigns =
      assigns
      |> assign(:text, badge_text(status))
      |> assign(:badge_colors, badge_colors(status))
      |> assign(:circle_fill, circle_fill(status))

    ~H"""
    <.link
      href="#"
      class="flex justify-between items-stretch md:items-center bg-white dark:bg-[#1E2139] py-4 px-8 rounded-md"
    >
      <div class="flex flex-col md:flex-row gap-4 justify-between items-start md:items-center">
        <h3>
          <span class="text-[#858BB2]">#</span><span class="font-bold">RT3080</span>
        </h3>
        <p class="text-[#858BB2] -mb-4 md:mb-0">
          <span>Due </span>
          <span>19 Aug 2021</span>
        </p>
        <p class="hidden md:inline-block text-[#858BB2] dark:text-white">Jensen Huang Dawg</p>
        <h3 class="md:hidden font-bold -mb-2">
          <span>£ </span>
          <span>1,800.90</span>
        </h3>
      </div>

      <div class="flex flex-col md:flex-row gap-4 justify-between md:justify-between items-end md:items-center font-bold">
        <p class="md:hidden text-[#858BB2] dark:text-white font-normal">Jensen Huang Dawg</p>
        <h3 class="hidden md:inline-block">
          <span>£ </span>
          <span>1,800.90</span>
        </h3>
        <span class={[
          @badge_colors,
          "inline-flex w-24 h-10 justify-center items-center gap-x-1.5 rounded-md px-2 py-1 text-xs font-bold"
        ]}>
          <svg class={[@circle_fill, "h-2 w-2"]} viewBox="0 0 6 6" aria-hidden="true">
            <circle cx="3" cy="3" r="3" />
          </svg>
          <%= @text %>
        </span>
        <svg
          class="hidden h-5 w-5 flex-none text-[#7C5DFA] md:flex"
          viewBox="0 0 20 20"
          fill="currentColor"
          aria-hidden="true"
        >
          <path
            fill-rule="evenodd"
            d="M7.21 14.77a.75.75 0 01.02-1.06L11.168 10 7.23 6.29a.75.75 0 111.04-1.08l4.5 4.25a.75.75 0 010 1.08l-4.5 4.25a.75.75 0 01-1.06-.02z"
            clip-rule="evenodd"
          />
        </svg>
      </div>
    </.link>
    """
  end

  def list_page_actions(assigns) do
    assigns = assign(assigns, :count, count_invoices(assigns.invoices))

    ~H"""
    <div class="flex justify-between">
      <div class="flex flex-col">
        <h3 class="font-semibold">Invoices</h3>
        <p :if={!Enum.empty?(@invoices)} class="text-sm text-gray-500">
          <span class="hidden md:inline-block">There are </span>
          <span><%= @count %></span>
          <span class="hidden md:inline-block">total</span>
          <span>invoices</span>
        </p>
        <p :if={Enum.empty?(@invoices)} class="text-sm text-gray-500">No invoices</p>
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

  def badge_colors(:paid), do: "bg-green-100 text-green-500"
  def badge_colors(:pending), do: "bg-orange-100 text-orange-500"
  def badge_colors(:draft), do: "bg-gray-100 text-gray-500"

  def circle_fill(:paid), do: "fill-green-500"
  def circle_fill(:pending), do: "fill-orange-500"
  def circle_fill(:draft), do: "fill-gray-500"

  def badge_text(:paid), do: "Paid"
  def badge_text(:pending), do: "Paid"
  def badge_text(:draft), do: "Paid"

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
end
