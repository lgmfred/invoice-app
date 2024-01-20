defmodule InvoiceAppWeb.UserLoginLive do
  use InvoiceAppWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm flex flex-col gap-4">
      <h1 class="text-3xl font-bold">Sign in to Invoice</h1>
      <.simple_form
        for={@form}
        id="login_form"
        action={~p"/users/log_in"}
        phx-update="ignore"
        class="text-left"
      >
        <.input
          field={@form[:email]}
          type="email"
          label="Email"
          placeholder="example@email.com"
          required
        />
        <.input
          field={@form[:password]}
          type="password"
          placeholder="Enter Your Password"
          label="Password"
          required
        />

        <:actions>
          <.input field={@form[:remember_me]} type="checkbox" label="Remember Me" />
          <.link href={~p"/users/reset_password"} class="text-sm text-[#E86969] font-medium">
            Forgot Password?
          </.link>
        </:actions>
        <:actions>
          <.button phx-disable-with="Logging in..." class="w-full bg-[#7C5DFA]">
            Login
          </.button>
        </:actions>
      </.simple_form>
      <p class="text-sm font-light text-center">
        Don't have an account?
        <.link navigate={~p"/users/register"} class="text-[#7C5DFA] hover:underline">
          Sign up
        </.link>
      </p>

      <div class="flex items-center w-full max-w-screen-md mx-auto text-lg">
        <div class="flex-grow h-px bg-[#3F445F]"></div>
        <div class="px-4 text-center">
          <p class="text-lg">Or With</p>
        </div>
        <div class="flex-grow h-px bg-[#3F445F]"></div>
      </div>
      <a
        href="#"
        class="border rounded-full py-2 px-6 flex justify-center items-center gap-2 text-[#3F445F]"
      >
        <svg class="w-6 h-6" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 25 24" fill="none">
          <path
            d="M22.3055 10.0415H21.5V10H12.5V14H18.1515C17.327 16.3285 15.1115 18 12.5 18C9.1865 18 6.5 15.3135 6.5 12C6.5 8.6865 9.1865 6 12.5 6C14.0295 6 15.421 6.577 16.4805 7.5195L19.309 4.691C17.523 3.0265 15.134 2 12.5 2C6.9775 2 2.5 6.4775 2.5 12C2.5 17.5225 6.9775 22 12.5 22C18.0225 22 22.5 17.5225 22.5 12C22.5 11.3295 22.431 10.675 22.3055 10.0415Z"
            fill="#FFC107"
          />
          <path
            d="M3.65332 7.3455L6.93882 9.755C7.82782 7.554 9.98082 6 12.5003 6C14.0298 6 15.4213 6.577 16.4808 7.5195L19.3093 4.691C17.5233 3.0265 15.1343 2 12.5003 2C8.65932 2 5.32832 4.1685 3.65332 7.3455Z"
            fill="#FF3D00"
          />
          <path
            d="M12.5002 21.9999C15.0832 21.9999 17.4302 21.0114 19.2047 19.4039L16.1097 16.7849C15.0719 17.574 13.8039 18.0009 12.5002 17.9999C9.89916 17.9999 7.69066 16.3414 6.85866 14.0269L3.59766 16.5394C5.25266 19.7779 8.61366 21.9999 12.5002 21.9999Z"
            fill="#4CAF50"
          />
          <path
            d="M22.3055 10.0415H21.5V10H12.5V14H18.1515C17.7571 15.1082 17.0467 16.0766 16.108 16.7855L16.1095 16.7845L19.2045 19.4035C18.9855 19.6025 22.5 17 22.5 12C22.5 11.3295 22.431 10.675 22.3055 10.0415Z"
            fill="#1976D2"
          />
        </svg>
        <p>Login with Google</p>
      </a>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = live_flash(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end