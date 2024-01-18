defmodule InvoiceAppWeb.UserRegistrationLive do
  use InvoiceAppWeb, :live_view

  alias InvoiceApp.Accounts
  alias InvoiceApp.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="mx-5 max-w-sm flex flex-col gap-2">
      <header class="text-center">
        <h1 class="text-3xl font-bold">Create an account</h1>
        <p class="text-base">Begin creating invoices for free!</p>
      </header>

      <.simple_form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/users/log_in?_action=registered"}
        method="post"
        class="m-0"
      >
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input field={@form[:full_name]} type="text" placeholder="Enter Your Name" required />
        <.input field={@form[:username]} type="text" placeholder="Enter Your Username" required />
        <.input field={@form[:email]} type="email" placeholder="Enter Your Email Address" required />
        <.input field={@form[:password]} type="password" placeholder="Enter Your Password" required />
        <.input field={@form[:avatar_url]} type="hidden" />

        <:actions>
          <.button phx-disable-with="Signing up..." class="w-full bg-[#7C5DFA]">Sign Up</.button>
        </:actions>
      </.simple_form>

      <p class="text-xl text-center">
        Already have an account?
        <.link navigate={~p"/users/log_in"} class=" text-[#7C5DFA] hover:underline">
          Log in
        </.link>
      </p>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
