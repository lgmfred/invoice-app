defmodule InvoiceAppWeb.InvoicesLive do
  use InvoiceAppWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    socket = assign(socket, user: user)
    {:ok, stream(socket, :invoices, [])}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div>
      <div
        class="absolute right-0 z-10 mt-2 w-48 origin-top-right rounded-md bg-white py-1 shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none"
        role="menu"
        aria-orientation="vertical"
        aria-labelledby="user-menu-button"
        tabindex="-1"
      >
        <div>
          <div class="flex flex-1 flex-col p-8">
            <img
              class="mx-auto h-32 w-32 flex-shrink-0 rounded-full"
              src={@current_user.avatar_url}
              alt=""
            />
            <h3 class="mt-6 text-sm font-medium text-gray-900">Jane Cooper</h3>
            <dl class="mt-1 flex flex-grow flex-col justify-between">
              <dt class="sr-only"><%= @current_user.full_name %></dt>
            </dl>
          </div>
        </div>
        <nav class="flex-none px-4 sm:px-6 lg:px-0">
          <ul role="list" class="flex flex-col gap-x-3 gap-y-1 whitespace-nowrap">
            <li>
              <.link
                navigate={~p"/invoices"}
                class="text-gray-700 hover:text-indigo-600 hover:bg-gray-50 group flex gap-x-3 rounded-md py-2 pl-2 pr-3 text-sm leading-6 font-semibold"
              >
                <img class="inline-block" src="/images/dashboard.svg" alt="" /> Dashboard
              </.link>
            </li>
            <li>
              <.link
                navigate={~p"/users/settings"}
                class="text-gray-700 hover:text-indigo-600 hover:bg-gray-50 group flex gap-x-3 rounded-md py-2 pl-2 pr-3 text-sm leading-6 font-semibold"
              >
                <img src="/images/settings.svg" alt="" /> Settings
              </.link>
            </li>
            <li>
              <.link
                href={~p"/users/log_out"}
                method="delete"
                class="text-gray-700 hover:text-indigo-600 hover:bg-gray-50 group flex gap-x-3 rounded-md py-2 pl-2 pr-3 text-sm leading-6 font-semibold"
              >
                <img src="/images/sign-out.svg" alt="" /> Sign out
              </.link>
            </li>
          </ul>
        </nav>
      </div>

      <h2>There is nothing here</h2>
      <%= inspect(@current_user) %>

      <p>Create an invoice by clicking the New button and get started</p>

      <%!-- <ul class="relative z-10 flex items-center gap-4 px-4 sm:px-6 lg:px-8 justify-end">
        <%= if @current_user do %>
          <li class="text-[0.8125rem] leading-6 text-zinc-900">
            <%= @current_user.email %>
          </li>
          <li>
            <.link
              href={~p"/users/settings"}
              class="text-[0.8125rem] leading-6 text-zinc-900 font-semibold hover:text-zinc-700"
            >
              Settings
            </.link>
          </li>
          <li>
            <.link
              href={~p"/users/log_out"}
              method="delete"
              class="text-[0.8125rem] leading-6 text-zinc-900 font-semibold hover:text-zinc-700"
            >
              Log out
            </.link>
          </li>
        <% end %>
      </ul> --%>
    </div>
    """
  end
end
