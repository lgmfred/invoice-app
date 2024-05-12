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
      <h2>There is nothing here</h2>
      <%= inspect(@current_user) %>

      <p>Create an invoice by clicking the New button and get started</p>

      <ul class="relative z-10 flex items-center gap-4 px-4 sm:px-6 lg:px-8 justify-end">
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
      </ul>
    </div>
    """
  end
end
