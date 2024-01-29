defmodule InvoiceAppWeb.UserRegistrationLive do
  use InvoiceAppWeb, :live_view

  alias InvoiceApp.Accounts
  alias InvoiceApp.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="lg:grid lg:grid-cols-2">
      <div class="hidden lg:block bg-pink-500">
        <img class="w-full h-[100vh]" src="/images/desktop-cover.png" alt="" />
      </div>
      <div class="w-full h-screen text-center bg-purple-500">
        <div class="h-screen mx-8 flex flex-col place-content-center gap-6 lg:gap-4 bg-yellow-600">
          <div class="hidden h-20 lg:flex gap-4 items-center justify-center">
            <svg
              class="w-20 h-full"
              viewBox="0 0 85 80"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
            >
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
            class="flex flex-col gap-2 "
          >
            <.error :if={@check_errors}>
              Oops, something went wrong! Please check the errors below.
            </.error>

            <div class="grid lg:grid-cols-2 gap-2 lg:gap-4">
              <.input field={@form[:full_name]} type="text" placeholder="Enter Your Name" required />
              <.input field={@form[:username]} type="text" placeholder="Enter Your Username" required />
            </div>
            <.input
              field={@form[:email]}
              type="email"
              placeholder="Enter Your Email Address"
              required
            />
            <.input
              field={@form[:password]}
              type="password"
              placeholder="Enter Your Password"
              required
            />
            <.input field={@form[:avatar_url]} type="hidden" />

            <div class="hidden lg:grid grid-cols-3">
              <p class="col-span-3 text-start mb-4">Password must contain :</p>
              <div class="flex justify-start items-center gap-4">
                <div class="w-3 h-3 rounded-full bg-[#4CAF50]"></div>
                <div>8+ characters</div>
              </div>
              <div class="col-span-2 flex justify-start items-center gap-4">
                <div class="w-3 h-3 rounded-full bg-[#4CAF50]"></div>
                <div>number</div>
              </div>
              <div class="flex justify-start items-center gap-4">
                <div class="w-3 h-3 rounded-full bg-[#4CAF50]"></div>
                <div>upper-case</div>
              </div>
              <div class="col-span-2 flex justify-start items-center gap-4">
                <div class="w-3 h-3 rounded-full bg-[#4CAF50]"></div>
                <div>special character (*#$%&!-@)</div>
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
      </div>
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

        {:noreply, push_navigate(socket, to: ~p"/users/confirm?#{[email: user.email]}")}

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
