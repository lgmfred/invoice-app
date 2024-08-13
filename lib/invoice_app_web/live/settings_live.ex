defmodule InvoiceAppWeb.SettingsLive do
  alias Ecto.Repo
  use InvoiceAppWeb, :live_view

  alias InvoiceApp.Accounts
  alias InvoiceApp.Accounts.BusinessAddress
  alias InvoiceApp.Accounts.EmailPreferences
  alias InvoiceApp.Accounts.User
  alias InvoiceApp.Repo
  alias InvoiceAppWeb.CustomComponents
  alias Phoenix.LiveView.JS

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    settings_tabs = [personal: "Personal", password: "Password", email: "Email notifications"]

    {:ok,
     socket
     |> assign(:delete_account?, false)
     |> assign(:tabs, settings_tabs)}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"tab" => "personal"}, _uri, socket) do
    selected_tab = Enum.find(socket.assigns.tabs, fn {key, _val} -> key == :personal end)

    changeset =
      socket.assigns.current_user
      |> User.update_user_changeset()

    {:noreply,
     socket
     |> allow_upload(:avatar,
       accept: ~w(.png .jpeg .jpg),
       max_entries: 1,
       max_file_size: 400_000,
       progress: &handle_progress/3,
       auto_upload: true
     )
     |> assign_form(changeset)
     |> assign(:page_title, "Settings - Personal")
     |> assign(:selected_tab, selected_tab)}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"tab" => "password"}, _uri, socket) do
    selected_tab = Enum.find(socket.assigns.tabs, fn {key, _val} -> key == :password end)
    user = socket.assigns.current_user
    changeset = Accounts.change_user_password(user)

    {:noreply,
     socket
     |> assign(:current_password, nil)
     |> assign(:current_email, user.email)
     |> assign_form(changeset)
     |> assign(:page_title, "Settings - Password")
     |> assign(:selected_tab, selected_tab)}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"tab" => "email"}, _uri, socket) do
    selected_tab = Enum.find(socket.assigns.tabs, fn {key, _val} -> key == :email end)
    user = socket.assigns.current_user

    changeset =
      user.email_preferences
      |> EmailPreferences.changeset()

    {:noreply,
     socket
     |> assign(:page_title, "Settings - Email notifications")
     |> assign(:selected_tab, selected_tab)
     |> assign_form(changeset)}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _uri, socket) do
    {:noreply, push_patch(socket, to: ~p"/settings?tab=personal")}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="flex-1 overflow-y-auto">
      <.settings_header tabs={@tabs} selected_tab={@selected_tab} />
      <.edit_profile_form
        :if={@selected_tab == {:personal, "Personal"}}
        uploads={@uploads}
        current_user={@current_user}
        form={@form}
        tabs={@tabs}
        selected_tab={@selected_tab}
      />
      <.password_form
        :if={@selected_tab == {:password, "Password"}}
        current_user={@current_user}
        form={@form}
        current_password={@current_password}
        current_email={@current_email}
        tabs={@tabs}
        selected_tab={@selected_tab}
      />
      <.email_notifications
        :if={@selected_tab == {:email, "Email notifications"}}
        current_user={@current_user}
        tabs={@tabs}
        selected_tab={@selected_tab}
        form={@form}
      />
      <.delete_account_modal current_user={@current_user} delete_account?={@delete_account?} />
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("validate-upload", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("validate-profile", %{"user" => params}, socket) do
    changeset =
      socket.assigns.current_user
      |> User.update_user_changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl Phoenix.LiveView
  def handle_event("save-profile", %{"user" => params}, socket) do
    case Accounts.update_user(socket.assigns.current_user, params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> assign(:current_user, user)
         |> put_flash(:info, "Profile updated successfully.")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign_form(changeset)
         |> put_flash(:error, "An error occurred during profile update.")}
    end
  end

  @impl Phoenix.LiveView
  def handle_event("validate-password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, form: form, current_password: password)}
  end

  @impl Phoenix.LiveView
  def handle_event("update-password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> assign(current_user: user)
         |> put_flash(:info, "Password updated successfully.")
         |> redirect(to: ~p"/users/log_in")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("delete-avatar", _params, socket) do
    update_user(socket, nil)
  end

  def handle_event("validate-email", %{"email-address" => email}, socket) do
    case socket.assigns.current_user do
      %Accounts.User{email: ^email} ->
        {:noreply, assign(socket, :delete_account?, true)}

      _any ->
        {:noreply, assign(socket, :delete_account?, false)}
    end
  end

  def handle_event("save-preferences", %{"email_preferences" => _pref} = params, socket) do
    case Accounts.update_user(socket.assigns.current_user, params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> assign(:current_user, user)
         |> put_flash(:info, "Notification preferences updated successfully.")}

      {:error, _changeset} ->
        changeset =
          socket.assigns.current_user.email_preferences
          |> EmailPreferences.changeset(params)
          |> Map.put(:action, :validate)

        {:noreply,
         socket
         |> assign_form(changeset)
         |> put_flash(:error, "Could not update notification preferences.")}
    end
  end

  def handle_event("delete-account", %{"email-address" => email}, socket) do
    case socket.assigns.current_user do
      %Accounts.User{email: ^email} = user ->
        Repo.delete!(user)

        {:noreply,
         socket
         |> put_flash(:info, "Account deleted successfully.")
         |> redirect(to: ~p"/")}

      _any ->
        {:noreply,
         socket
         |> put_flash(:error, "Could not delete account.")
         |> push_patch(to: ~p"/settings?tab=email")}
    end
  end

  defp handle_progress(:avatar, entry, socket) do
    if entry.done? do
      [avatar_url | _] = consume_uploads(socket)
      update_user(socket, avatar_url)
    else
      {:noreply, socket}
    end
  end

  defp consume_uploads(socket) do
    consume_uploaded_entries(socket, :avatar, fn %{path: path}, entry ->
      dest = upload_destination(entry)
      Path.dirname(dest) |> File.mkdir_p!()
      File.cp!(path, dest)
      static_path = Path.join(InvoiceApp.public_uploads_path(), Path.basename(dest))
      {:ok, static_path(socket, static_path)}
    end)
  end

  defp upload_destination(entry) do
    Path.join(InvoiceApp.uploads_dir(), filename(entry))
  end

  defp filename(entry) do
    "#{entry.uuid}-#{entry.client_name}"
  end

  defp update_user(socket, avatar_url) do
    current_user = socket.assigns.current_user
    attrs = %{avatar_url: avatar_url}
    {:ok, user} = Accounts.update_user(current_user, attrs)
    {:noreply, assign(socket, :current_user, user)}
  end

  def settings_header(assigns) do
    ~H"""
    <header class="border-b border-white/5">
      <h1 class="text-2xl font-bold tracking-tight">Settings</h1>
      <!-- Secondary navigation -->
      <nav class="flex overflow-x-auto py-4">
        <ul role="list" class="flex min-w-full flex-none gap-x-6 text-sm font-semibold leading-6">
          <li :for={{id, text} = tab <- @tabs}>
            <.link
              patch={~p"/settings?#{[tab: id]}"}
              class={if tab == @selected_tab, do: "text-indigo-400"}
              data-role={id}
            >
              <%= text %>
            </.link>
          </li>
        </ul>
      </nav>
    </header>
    """
  end

  def edit_profile_form(assigns) do
    ~H"""
    <div class="flex flex-col gap-4 mx-auto max-w-3xl px-4 py-10 sm:px-6 lg:px-8 lg:py-12 rounded-md bg-white dark:bg-[#1E2139]">
      <form class="flex flex-col gap-4" id="upload-form" phx-change="validate-upload">
        <%!-- Avatar render and update section --%>
        <.render_avatar current_user={@current_user} />
        <div class="col-span-2 text-[#E86969]">
          <%= for entry <- @uploads.avatar.entries do %>
            <%= for err <- upload_errors(@uploads.avatar, entry) do %>
              <p data-role="entry-upload-error" class="alert alert-danger justify-self-center">
                <%= error_to_string(err) %>
              </p>
            <% end %>
          <% end %>
          <%= for err <- upload_errors(@uploads.avatar) do %>
            <p data-role="general-upload-error" class="alert alert-danger justify-self-center">
              <%= error_to_string(err) %>
            </p>
          <% end %>
        </div>
        <div class="flex gap-4 justify-start">
          <div class="relative">
            <.live_file_input
              class="peer absolute z-0 inset-0 h-full w-full rounded-full opacity-0"
              upload={@uploads.avatar}
            />
            <label
              for="user-photo"
              class="pointer-events-none block rounded-full bg:bg-white px-3 py-2 text-sm font-semibold shadow-sm ring-1 ring-inset ring-slate-300 peer-hover:bg-[1E2139] peer-focus:ring-2 peer-focus:ring-blue-600"
            >
              <span>Upload an new photo</span>
              <span class="sr-only"> user photo</span>
            </label>
          </div>
          <button
            phx-click="delete-avatar"
            type="button"
            class="inline-flex justify-center rounded-full bg-gray-200 dark:bg-[#252945] px-3 py-2 text-sm font-semibold shadow-sm hover:bg-white focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-300"
            data-role="delete-avatar"
          >
            Delete
          </button>
        </div>
      </form>
      <.form
        for={@form}
        phx-change="validate-profile"
        phx-submit="save-profile"
        class="flex flex-col gap-4"
      >
        <h2 class="font-medium text-xl">Edit Profile Information</h2>
        <div class="grid grid-cols-1 gap-y-6 sm:grid-cols-6 sm:gap-x-6">
          <div class="sm:col-span-3">
            <CustomComponents.input field={@form[:full_name]} type="text" id="full-name" label="Name" />
          </div>

          <div class="sm:col-span-3">
            <CustomComponents.input
              field={@form[:username]}
              type="text"
              id="username"
              label="Username"
            />
          </div>

          <div class="sm:col-span-6">
            <CustomComponents.input field={@form[:email]} type="email" id="email" label="Email" />
          </div>

          <.inputs_for :let={address} field={@form[:business_address]}>
            <div class="sm:col-span-3">
              <CustomComponents.input
                field={address[:country]}
                type="select"
                options={country_options()}
                id="country"
                label="Country"
              />
            </div>

            <div class="sm:col-span-3">
              <CustomComponents.input
                field={address[:city]}
                type="text"
                id="city"
                autocomplete="city-name"
                label="City"
              />
            </div>

            <div class="sm:col-span-3">
              <CustomComponents.input
                field={address[:street_address]}
                type="text"
                id="street-address"
                label="Street Address"
              />
            </div>

            <div class="sm:col-span-3">
              <CustomComponents.input
                field={address[:postal_code]}
                type="text"
                id="postal-code"
                label="Postal Code"
              />
            </div>
          </.inputs_for>
          <.save_delete_buttons />
        </div>
      </.form>
    </div>
    """
  end

  def password_form(assigns) do
    ~H"""
    <div class="mx-auto max-w-3xl px-4 py-10 sm:px-6 lg:px-8 lg:py-12 rounded-md bg-white dark:bg-[#1E2139]">
      <.form
        for={@form}
        id="password_form"
        phx-change="validate-password"
        phx-submit="update-password"
        class="flex flex-col gap-4"
      >
        <%!-- Avatar render and update section --%>
        <.render_avatar current_user={@current_user} />
        <h2 class="font-medium text-xl">Change Password</h2>
        <div class="grid grid-cols-1 gap-y-6 sm:grid-cols-6 sm:gap-x-6">
          <div class="col-span-6">
            <CustomComponents.input
              field={@form[:email]}
              type="hidden"
              id="hidden_user_email"
              value={@current_email}
            />
          </div>
          <div class="col-span-6">
            <CustomComponents.input
              field={@form[:current_password]}
              name="current_password"
              type="password"
              label="Old password"
              id="current_password_for_password"
              value={@current_password}
              required
            />
          </div>
          <div class="col-span-6">
            <CustomComponents.input
              field={@form[:password]}
              type="password"
              label="New password"
              required
            />
          </div>

          <div class="col-span-6">
            <CustomComponents.input
              field={@form[:password_confirmation]}
              type="password"
              label="Confirm new password"
            />
          </div>

          <div class="col-span-6 flex flex-wrap gap-4">
            <div class="flex items-center gap-x-2 justify-start">
              <span class="flex-none rounded-full p-1.5 bg-green-400"></span>
              <span>12+ characters</span>
            </div>
            <div class="flex items-center gap-x-2 justify-start">
              <span class="flex-none rounded-full p-1.5 bg-[#D9D9D9]"></span>
              <span>number</span>
            </div>
            <div class="flex items-center gap-x-2 justify-start">
              <span class="flex-none rounded-full p-1.5 bg-green-400"></span>
              <span>upper-case</span>
            </div>
            <div class="flex items-center gap-x-2 justify-start">
              <span class="flex-none rounded-full p-1.5 bg-[#D9D9D9]"></span>
              <span>special character (*#$%&!-@)</span>
            </div>
          </div>
          <.save_delete_buttons />
        </div>
      </.form>
    </div>
    """
  end

  def email_notifications(assigns) do
    ~H"""
    <div class="mx-auto max-w-3xl px-4 py-10 sm:px-6 lg:px-8 lg:py-12 rounded-md bg-white dark:bg-[#1E2139]">
      <.form for={@form} phx-submit="save-preferences" class="flex flex-col gap-4">
        <%!-- Avatar render and update section --%>
        <.render_avatar current_user={@current_user} />
        <h2 class="font-medium text-xl">Edit Notification Preferences</h2>
        <div class="grid grid-cols-1 gap-y-6 sm:grid-cols-6 sm:gap-x-6">
          <fieldset class="col-span-6">
            <legend class="font-medium">I’d like to receive:</legend>
            <br />
            <div class="space-y-5">
              <CustomComponents.input
                field={@form[:newsletter]}
                type="checkbox"
                label="Newsletter and product updates"
              />
              <CustomComponents.input
                field={@form[:sign_in]}
                type="checkbox"
                label="Sign in notification"
              />
              <CustomComponents.input
                field={@form[:payment_reminder]}
                type="checkbox"
                label="Due payment reminders"
              />
            </div>
          </fieldset>

          <.save_delete_buttons />
        </div>
      </.form>
    </div>
    """
  end

  def render_avatar(assigns) do
    ~H"""
    <div class="flex gap-2 text-xl items-center justify-center">
      <div class="flex-shrink-0">
        <img
          :if={@current_user.avatar_url}
          class="h-16 w-16 rounded-full"
          src={@current_user.avatar_url}
          data-role="user-avatar"
          alt=""
        />
        <.icon :if={!@current_user.avatar_url} name="hero-user-circle" class="h-20 w-20" />
      </div>
      <h2 class="min-w-0 flex-1 font-semibold">
        <%= @current_user.full_name %> / Profile information
      </h2>
    </div>
    """
  end

  def save_delete_buttons(assigns) do
    ~H"""
    <div class="sm:col-span-6 flex flex-col gap-4 sm:flex-row sm:justify-between">
      <button
        type="submit"
        class="inline-flex sm:order-last justify-center rounded-full bg-blue-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-blue-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600"
      >
        Save changes
      </button>
      <button
        phx-click={show_modal("delete-account")}
        type="button"
        class="rounded-full px-3 py-2 text-sm font-semibold text-[#EC5757] hover:bg-[#7E88C3] dark:hover:bg-[#303559]"
      >
        Delete Account
      </button>
    </div>
    """
  end

  def delete_account_modal(assigns) do
    ~H"""
    <form
      phx-submit="delete-account"
      phx-change="validate-email"
      id="delete-account"
      class="relative hidden z-10"
      aria-labelledby="delete-account"
      role="dialog"
      aria-modal="false"
    >
      <div
        phx-click={JS.hide(to: "#delete-account")}
        class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"
      >
      </div>
      <div class="fixed inset-0 z-10 w-screen overflow-y-auto">
        <div class="flex min-h-full items-end justify-center p-4 items-center sm:p-0">
          <div class="relative transform overflow-hidden rounded-lg bg-white dark:bg-[#1E2139] px-4 pb-4 pt-5 shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-lg sm:p-6">
            <div>
              <h2 class="text-xl font-semibold leading-6" id="modal-title">
                Delete Account
              </h2>
              <div class="mt-3 sm:mt-5">
                <h4 class="text-base font-semibold leading-6" id="modal-title">
                  Would you like to delete your Invoice account (<span class="text-[#7C5DFA]">@<%= @current_user.username %></span>)?
                </h4>
                <div class="mt-2">
                  <p class="text-sm">
                    Deleting your account will remove all your content and data associated with your Invoice profile. To confirm the permanent deletion, type your email address (“<span class="font-bold"><%= @current_user.email %></span>”) below.
                  </p>
                </div>
              </div>
            </div>
            <div class="sm:col-span-6">
              <label for="email-address" class="sr-only">
                Email
              </label>
              <input
                type="text"
                name="email-address"
                id="email-address"
                autocomplete="email-address"
                class="mt-2 block w-full rounded-md border-0 py-1.5 font-bold dark:bg-[#303559] shadow-sm ring-1 ring-inset ring-[#DFE3FA] dark:ring-[#303559] placeholder:text-slate-400 focus:ring-1 focus:ring-inset focus:ring-[#0C0E16] dark:focus:ring-white sm:text-sm sm:leading-6"
              />
            </div>
            <div class="mt-4 flex gap-4 flex-col justify-center md:flex-row md:justify-end">
              <button
                :if={@delete_account?}
                type="submit"
                class="inline-flex md:px-6 justify-center rounded-full bg-blue-600 px-3 py-2 font-semibold text-white shadow-sm hover:bg-blue-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600"
              >
                Ok
              </button>
              <button
                :if={!@delete_account?}
                type="button"
                class="cursor-not-allowed inline-flex md:px-6 justify-center rounded-full bg-blue-200 px-3 py-2 font-semibold text-white shadow-sm hover:bg-blue-100 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600"
              >
                Ok
              </button>
              <button
                phx-click={JS.hide(to: "#delete-account")}
                type="button"
                class="inline-flex justify-center md:justify-end rounded-full px-3 py-2 font-semibold text-[#7C5DFA] shadow-sm ring-1 ring-inset ring-[#7C5DFA] hover:bg-gray-50"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      </div>
    </form>
    """
  end

  def country_options do
    tl =
      Countries.all()
      |> Enum.into(%{}, fn x -> {x.name, x.alpha2} end)
      |> Enum.sort()

    [{"Choose Country", ""} | tl]
  end

  def error_to_string(:too_large), do: "Too large"
  def error_to_string(:not_accepted), do: "Invalid file type"
  def error_to_string(:too_many_files), do: "Too many files"

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset)

    if changeset.valid? do
      socket
      |> assign(:form, form)
      |> assign(:check_errors, false)
    else
      assign(socket, :form, form)
    end
  end
end
