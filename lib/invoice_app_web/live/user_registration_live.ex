defmodule InvoiceAppWeb.UserRegistrationLive do
  use InvoiceAppWeb, :live_view

  alias InvoiceApp.Accounts
  alias InvoiceApp.Accounts.User

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="h-screen mx-8 flex flex-col place-content-center gap-6 lg:gap-4">
      <div class="hidden h-20 lg:flex gap-4 items-center justify-center">
        <svg class="w-20 h-full" viewBox="0 0 85 80" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path
            fill-rule="evenodd"
            clip-rule="evenodd"
            d="M22.1763 0.108887L42.4672 40.6907L62.7581 0.109081C75.9694 7.30834 84.934 21.3193 84.934 37.424C84.934 60.8779 65.9209 79.891 42.467 79.891C19.0131 79.891 0 60.8779 0 37.424C0 21.3191 8.96477 7.30809 22.1763 0.108887Z"
            fill="#7C5DFA"
          />
        </svg>
        <h1 class="text-[#7C5DFA] font-semibold text-6xl md:text-8xl lg:text-6xl">
          Invoice
        </h1>
      </div>
      <header class="text-center">
        <h1 class="text-3xl font-bold">Create an account</h1>
        <p class="text-base">Begin creating invoices for free!</p>
      </header>
      <.form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        class="flex flex-col gap-2 text-left"
      >
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <div class="grid lg:grid-cols-2 gap-2 lg:gap-4">
          <.input
            field={@form[:full_name]}
            type="text"
            label="Name"
            placeholder="Enter Your Name"
            required
          />
          <.input
            field={@form[:username]}
            type="text"
            label="Username"
            placeholder="Enter Your Username"
            required
          />
        </div>
        <.input
          field={@form[:email]}
          type="email"
          label="Email"
          placeholder="Enter Your Email Address"
          required
        />
        <.input
          field={@form[:password]}
          type="password"
          label="Password"
          placeholder="Enter Your Password"
          required
        />
        <.input field={@form[:avatar_url]} type="hidden" />

        <div>
          <%= inspect(@error_details) %>
        </div>
        <div class="grid grid-cols-2">
          <div class="inline-flex items-center gap-x-1.5 px-1.5 py-0.5">
            <svg class="h-3 w-3 fill-gray-400" viewBox="0 0 6 6" aria-hidden="true">
              <circle cx="3" cy="3" r="3" />
            </svg>
            12+ characters
          </div>
          <div class="inline-flex items-center gap-x-1.5 px-1.5 py-0.5">
            <svg class="h-3 w-3 fill-gray-400" viewBox="0 0 6 6" aria-hidden="true">
              <circle cx="3" cy="3" r="3" />
            </svg>
            number
          </div>
          <div class="inline-flex items-center gap-x-1.5 px-1.5 py-0.5">
            <svg class="h-3 w-3 fill-gray-400" viewBox="0 0 6 6" aria-hidden="true">
              <circle cx="3" cy="3" r="3" />
            </svg>
            upper-case
          </div>
          <div class="inline-flex items-center gap-x-1.5 px-1.5 py-0.5">
            <svg class="h-3 w-3 fill-gray-400" viewBox="0 0 6 6" aria-hidden="true">
              <circle cx="3" cy="3" r="3" />
            </svg>
            "special character (*#$%&!-@)"
          </div>
        </div>

        <.input
          field={@form[:terms_agreed?]}
          type="checkbox"
          label="I agree to the Terms of Use and Privacy Policy"
          class="mx-auto"
        />
        <button
          type="submit"
          phx-disable-with="Signing up..."
          class="w-full bg-[#7C5DFA] rounded-lg py-2 px-3 text-lg font-bold leading-6 text-white active:text-white/80"
        >
          Sign Up
        </button>
      </.form>
      <p class="text-xl text-center">
        Already have an account?
        <.link navigate={~p"/users/log_in"} class="text-[#7C5DFA] hover:underline">
          Log in
        </.link>
      </p>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false, error_details: %{})
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  @impl Phoenix.LiveView
  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        {:noreply, push_navigate(socket, to: ~p"/users/confirm?#{[email: user.email]}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  @impl Phoenix.LiveView
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)

    error_details = error_details(changeset)
    socket = assign(socket, :error_details, error_details)

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

  @doc """
  Translates the changeset errors and return a map of
  error messages. For example:

  %{start_date: ["can't be blank"], end_date: ["can't be blank"]}
  """
  def error_details(changeset) do
    case Ecto.Changeset.get_change(changeset, :password) do
      nil ->
        %{}

      _ ->
        traverse_errors(changeset)
    end
  end

  defp traverse_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &traverse_error/1)
    |> Map.take([:password])
  end

  defp traverse_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end
end
