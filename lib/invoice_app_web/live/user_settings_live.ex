defmodule InvoiceAppWeb.UserSettingsLive do
  use InvoiceAppWeb, :live_view

  alias InvoiceApp.Accounts

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="mx-auto w-5/6 md:w-1/2 lg:w-2/5">
      <.header class="text-center">
        Account Settings
        <:subtitle>Manage your account name, username email address and password settings</:subtitle>
      </.header>

      <div class="space-y-12 divide-y">
        <div>
          <.simple_form
            for={@name_form}
            id="name_form"
            phx-change="validate_name"
            phx-submit="update_name"
          >
            <.input field={@name_form[:full_name]} type="text" label="Full Name" required />
            <.input
              field={@name_form[:current_password]}
              name="current_password"
              id="current_password_for_name"
              type="password"
              label="Current password"
              value={@name_form_current_password}
              required
            />
            <:actions>
              <.button phx-disable-with="Changing...">Change Name</.button>
            </:actions>
          </.simple_form>
        </div>
        <div>
          <.simple_form
            for={@username_form}
            id="username_form"
            phx-submit="update_username"
            phx-change="validate_username"
          >
            <.input field={@username_form[:username]} type="text" label="Username" required />
            <.input
              field={@username_form[:current_password]}
              name="current_password"
              id="current_password_for_username"
              type="password"
              label="Current password"
              value={@username_form_current_password}
              required
            />
            <:actions>
              <.button phx-disable-with="Changing...">Change Username</.button>
            </:actions>
          </.simple_form>
        </div>
        <div>
          <.simple_form
            for={@email_form}
            id="email_form"
            phx-submit="update_email"
            phx-change="validate_email"
          >
            <.input field={@email_form[:email]} type="email" label="Email" required />
            <.input
              field={@email_form[:current_password]}
              name="current_password"
              id="current_password_for_email"
              type="password"
              label="Current password"
              value={@email_form_current_password}
              required
            />
            <:actions>
              <.button phx-disable-with="Changing...">Change Email</.button>
            </:actions>
          </.simple_form>
        </div>
        <div>
          <.simple_form
            for={@password_form}
            id="password_form"
            action={~p"/users/log_in?_action=password_updated"}
            method="post"
            phx-change="validate_password"
            phx-submit="update_password"
            phx-trigger-action={@trigger_submit}
          >
            <.input
              field={@password_form[:email]}
              type="hidden"
              id="hidden_user_email"
              value={@current_email}
            />
            <.input field={@password_form[:password]} type="password" label="New password" required />
            <.input
              field={@password_form[:password_confirmation]}
              type="password"
              label="Confirm new password"
            />
            <.input
              field={@password_form[:current_password]}
              name="current_password"
              type="password"
              label="Current password"
              id="current_password_for_password"
              value={@current_password}
              required
            />
            <:actions>
              <.button phx-disable-with="Changing...">Change Password</.button>
            </:actions>
          </.simple_form>
        </div>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    full_name_changeset = Accounts.change_full_name(user)
    username_changeset = Accounts.change_username(user)
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:name_form_current_password, nil)
      |> assign(:username_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:name_form, to_form(full_name_changeset))
      |> assign(:username_form, to_form(username_changeset))
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  @impl Phoenix.LiveView
  def handle_event("validate_name", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    name_form =
      socket.assigns.current_user
      |> Accounts.change_full_name(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, name_form: name_form, name_form_current_password: password)}
  end

  @impl Phoenix.LiveView
  def handle_event("update_name", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_full_name(user, password, user_params) do
      {:ok, user} ->
        full_name_changeset = Accounts.change_full_name(user)

        {:noreply,
         socket
         |> assign(current_user: user)
         |> assign(name_form: to_form(full_name_changeset))
         |> assign(:name_form_current_password, nil)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, name_form: to_form(changeset))}
    end
  end

  @impl Phoenix.LiveView
  def handle_event("validate_username", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    name_form =
      socket.assigns.current_user
      |> Accounts.change_username(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, username_form: name_form, username_form_current_password: password)}
  end

  @impl Phoenix.LiveView
  def handle_event("update_username", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_username(user, password, user_params) do
      {:ok, user} ->
        username_changeset = Accounts.change_username(user)

        {:noreply,
         socket
         |> assign(current_user: user)
         |> assign(username_form: to_form(username_changeset))
         |> assign(:username_form_current_password, nil)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, username_form: to_form(changeset))}
    end
  end

  @impl Phoenix.LiveView
  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  @impl Phoenix.LiveView
  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  @impl Phoenix.LiveView
  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end
end
