defmodule InvoiceAppWeb.UserConfirmationInstructionsLive do
  use InvoiceAppWeb, :live_view

  alias InvoiceApp.Accounts
  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"email" => email}, _uri, socket) do
    case Accounts.get_user_by_email(email) do
      %{email: ^email, confirmed_at: nil} = _user ->
        {:noreply, assign(socket, email: email)}

      _user_or_nil ->
        {:noreply, push_patch(socket, to: ~p"/users/confirm")}
    end
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _uri, socket) do
    {:noreply, assign(socket, email: nil)}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="min-h-screen flex items-center justify-center">
      <%= if @current_user do %>
        <%= if @current_user.confirmed_at do %>
          <div class="flex flex-col gap-4 py-8 px-16 text-center">
            <.header class="">
              You've already confirmed your Email Address.
            </.header>
          </div>
        <% else %>
          <.confirm_instruction :if={@email} form={@form} email={@email} />
          <.confirm_email_form :if={!@email} form={@form} />
        <% end %>
      <% else %>
        <.confirm_instruction :if={@email} form={@form} email={@email} />
        <.confirm_email_form :if={!@email} form={@form} />
      <% end %>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("send_instructions", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_confirmation_instructions(
        user,
        &url(~p"/users/confirm/#{&1}")
      )
    end

    info =
      "If your email is in our system and it has not been confirmed yet, you will receive an email with instructions shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end

  @impl Phoenix.LiveView
  def handle_event("send_instructions", _params, socket) do
    if user = Accounts.get_user_by_email(socket.assigns.email) do
      Accounts.deliver_user_confirmation_instructions(
        user,
        &url(~p"/users/confirm/#{&1}")
      )
    end

    info =
      "We've sent a confirmation email. Please follow the link in the message to confirm your email address."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end

  defp confirm_instruction(assigns) do
    ~H"""
    <div class="flex flex-col gap-4 py-8 px-16 text-left rounded-xl bg-[#7C5DFA33]">
      <.header class="">
        Confirm Your Email Address.
      </.header>

      <p>
        We've sent a confirmation email to <span class="font-bold"><%= @email %></span>.
        Please follow the link in the message to confirm your email address.
        If you did not receive the email, please check your spam folder or:
      </p>
      <.simple_form for={@form} id="resend_confirmation_form" phx-submit="send_instructions">
        <.button phx-disable-with="Sending..." class="w-full">
          Resend confirmation instructions
        </.button>
      </.simple_form>
    </div>
    """
  end

  defp confirm_email_form(assigns) do
    ~H"""
    <div>
      <.header class="text-center">
        No confirmation instructions received?
        <:subtitle>We'll send a new confirmation link to your inbox</:subtitle>
      </.header>

      <.simple_form for={@form} id="resend_confirmation_form" phx-submit="send_instructions">
        <.input field={@form[:email]} type="email" placeholder="Email" required />
        <:actions>
          <.button phx-disable-with="Sending..." class="w-full">
            Resend confirmation instructions
          </.button>
        </:actions>
      </.simple_form>

      <p class="text-center mt-4">
        <.link href={~p"/users/register"}>Register</.link>
        | <.link href={~p"/users/log_in"}>Log in</.link>
      </p>
    </div>
    """
  end
end
