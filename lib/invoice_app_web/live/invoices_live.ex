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
    </div>
    """
  end
end
