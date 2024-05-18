defmodule InvoiceAppWeb.SettingsLive do
  use InvoiceAppWeb, :live_view

  def mount(_params, _session, socket) do
    settings_tabs = [personal: "Personal", password: "Password", email: "Email notifications"]
    {:ok, assign(socket, tabs: settings_tabs)}
  end

  def handle_params(%{"tab" => tab}, _uri, socket) do
    tab = String.to_existing_atom(tab)
    selected_tab = Enum.find(socket.assigns.tabs, fn {key, _val} -> key == tab end)
    {:noreply, assign(socket, selected_tab: selected_tab)}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, assign(socket, selected_tab: hd(socket.assigns.tabs))}
  end

  def render(assigns) do
    ~H"""
    <div class="flex-1 overflow-y-auto">
      <.settings_header tabs={@tabs} selected_tab={@selected_tab} />
      <.address_form
        :if={@selected_tab == {:personal, "Personal"}}
        current_user={@current_user}
        tabs={@tabs}
        selected_tab={@selected_tab}
      />
      <.password_form
        :if={@selected_tab == {:password, "Password"}}
        current_user={@current_user}
        tabs={@tabs}
        selected_tab={@selected_tab}
      />
      <.email_notifications
        :if={@selected_tab == {:email, "Email notifications"}}
        current_user={@current_user}
        tabs={@tabs}
        selected_tab={@selected_tab}
      />
    </div>
    """
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
            >
              <%= text %>
            </.link>
          </li>
        </ul>
      </nav>
    </header>
    """
  end

  def address_form(assigns) do
    ~H"""
    <div class="mx-auto max-w-3xl px-4 py-10 sm:px-6 lg:px-8 lg:py-12 rounded-md bg-white dark:bg-[#1E2139]">
      <form class="flex flex-col gap-4">
        <%!-- Avatar render and update section --%>
        <.render_avatar current_user={@current_user} />
        <div class="flex gap-4 justify-start">
          <div class="relative">
            <input
              id="user-photo"
              name="user-photo"
              type="file"
              class="peer absolute z-0 inset-0 h-full w-full rounded-full opacity-0"
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
            type="button"
            class="inline-flex justify-center rounded-full bg-gray-200 dark:bg-[#252945] px-3 py-2 text-sm font-semibold shadow-sm hover:bg-white focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-300"
          >
            Delete
          </button>
        </div>
        <h2 class="font-medium text-xl">Edit  Profile Information</h2>
        <div class="grid grid-cols-1 gap-y-6 sm:grid-cols-6 sm:gap-x-6">
          <div class="sm:col-span-3">
            <label
              for="full-name"
              class="block text-sm font-medium leading-6 text-[#7E88C3] dark:text-[#DFE3FA]"
            >
              Name
            </label>
            <input
              type="text"
              name="full-name"
              id="full-name"
              autocomplete="full-name"
              class="mt-2 block w-full rounded-md border-0 py-1.5 font-bold dark:bg-[#303559] shadow-sm ring-1 ring-inset ring-[#DFE3FA] dark:ring-[#303559] placeholder:text-slate-400 focus:ring-1 focus:ring-inset focus:ring-[#0C0E16] dark:focus:ring-white sm:text-sm sm:leading-6"
            />
          </div>

          <div class="sm:col-span-3">
            <label
              for="username"
              class="block text-sm font-medium leading-6 text-[#7E88C3] dark:text-[#DFE3FA]"
            >
              Username
            </label>
            <input
              type="text"
              name="username"
              id="username"
              autocomplete="username"
              class="mt-2 block w-full rounded-md border-0 py-1.5 font-bold dark:bg-[#303559] shadow-sm ring-1 ring-inset ring-[#DFE3FA] dark:ring-[#303559] placeholder:text-slate-400 focus:ring-1 focus:ring-inset focus:ring-[#0C0E16] dark:focus:ring-white sm:text-sm sm:leading-6"
            />
          </div>

          <div class="sm:col-span-6">
            <label
              for="email-address"
              class="block text-sm font-medium leading-6 text-[#7E88C3] dark:text-[#DFE3FA]"
            >
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

          <div class="sm:col-span-3">
            <label
              for="country"
              class="block text-sm font-medium leading-6 text-[#7E88C3] dark:text-[#DFE3FA]"
            >
              Country
            </label>
            <input
              type="text"
              name="country"
              id="country"
              autocomplete="country-name"
              class="mt-2 block w-full rounded-md border-0 py-1.5 font-bold dark:bg-[#303559] shadow-sm ring-1 ring-inset ring-[#DFE3FA] dark:ring-[#303559] placeholder:text-slate-400 focus:ring-1 focus:ring-inset focus:ring-[#0C0E16] dark:focus:ring-white sm:text-sm sm:leading-6"
            />
          </div>

          <div class="sm:col-span-3">
            <label
              for="city"
              class="block text-sm font-medium leading-6 text-[#7E88C3] dark:text-[#DFE3FA]"
            >
              City
            </label>
            <input
              type="text"
              name="city"
              id="city"
              autocomplete="city-name"
              class="mt-2 block w-full rounded-md border-0 py-1.5 font-bold dark:bg-[#303559] shadow-sm ring-1 ring-inset ring-[#DFE3FA] dark:ring-[#303559] placeholder:text-slate-400 focus:ring-1 focus:ring-inset focus:ring-[#0C0E16] dark:focus:ring-white sm:text-sm sm:leading-6"
            />
          </div>

          <div class="sm:col-span-3">
            <label
              for="street-address"
              class="block text-sm font-medium leading-6 text-[#7E88C3] dark:text-[#DFE3FA]"
            >
              Street Address
            </label>
            <input
              type="text"
              name="street-address"
              id="street-address"
              autocomplete="street-address"
              class="mt-2 block w-full rounded-md border-0 py-1.5 font-bold dark:bg-[#303559] shadow-sm ring-1 ring-inset ring-[#DFE3FA] dark:ring-[#303559] placeholder:text-slate-400 focus:ring-1 focus:ring-inset focus:ring-[#0C0E16] dark:focus:ring-white sm:text-sm sm:leading-6"
            />
          </div>

          <div class="sm:col-span-3">
            <label
              for="postal-code"
              class="block text-sm font-medium leading-6 text-[#7E88C3] dark:text-[#DFE3FA]"
            >
              Postal Code
            </label>
            <input
              type="text"
              name="postal-code"
              id="postal-code"
              class="mt-2 block w-full rounded-md border-0 py-1.5 font-bold dark:bg-[#303559] shadow-sm ring-1 ring-inset ring-[#DFE3FA] dark:ring-[#303559] placeholder:text-slate-400 focus:ring-1 focus:ring-inset focus:ring-[#0C0E16] dark:focus:ring-white sm:text-sm sm:leading-6"
            />
          </div>
          <div class="sm:col-span-6 flex flex-col gap-4 sm:flex-row sm:justify-between">
            <button
              type="submit"
              class="inline-flex sm:order-last justify-center rounded-full bg-blue-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-blue-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600"
            >
              Save changes
            </button>
            <button
              type="button"
              class="rounded-full px-3 py-2 text-sm font-semibold text-[#EC5757] hover:bg-[#7E88C3] dark:hover:bg-[#303559]"
            >
              Delete Account
            </button>
          </div>
        </div>
      </form>
    </div>
    """
  end

  def password_form(assigns) do
    ~H"""
    <div class="mx-auto max-w-3xl px-4 py-10 sm:px-6 lg:px-8 lg:py-12 rounded-md bg-white dark:bg-[#1E2139]">
      <form class="flex flex-col gap-4">
        <%!-- Avatar render and update section --%>
        <.render_avatar current_user={@current_user} />
        <h2 class="font-medium text-xl">Change Password</h2>
        <div class="grid grid-cols-1 gap-y-6 sm:grid-cols-6 sm:gap-x-6">
          <div class="col-span-6">
            <label
              for="email-address"
              class="block text-sm font-medium leading-6 text-[#7E88C3] dark:text-[#DFE3FA]"
            >
              Old password
            </label>
            <input
              id="current-password"
              name="current_password"
              type="password"
              autocomplete="current-password"
              required
              class="mt-2 block w-full rounded-md border-0 py-1.5 font-bold dark:bg-[#303559] shadow-sm ring-1 ring-inset ring-[#DFE3FA] dark:ring-[#303559] placeholder:text-slate-400 focus:ring-1 focus:ring-inset focus:ring-[#0C0E16] dark:focus:ring-white sm:text-sm sm:leading-6"
            />
          </div>

          <div class="col-span-6">
            <label
              for="email-address"
              class="block text-sm font-medium leading-6 text-[#7E88C3] dark:text-[#DFE3FA]"
            >
              New password
            </label>
            <input
              id="new-password"
              name="new_password"
              type="password"
              autocomplete="new-password"
              required
              class="mt-2 block w-full rounded-md border-0 py-1.5 font-bold dark:bg-[#303559] shadow-sm ring-1 ring-inset ring-[#DFE3FA] dark:ring-[#303559] placeholder:text-slate-400 focus:ring-1 focus:ring-inset focus:ring-[#0C0E16] dark:focus:ring-white sm:text-sm sm:leading-6"
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

          <div class="sm:col-span-6 flex flex-col gap-4 sm:flex-row sm:justify-between">
            <button
              type="submit"
              class="inline-flex sm:order-last justify-center rounded-full bg-blue-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-blue-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600"
            >
              Save changes
            </button>
            <button
              type="button"
              class="rounded-full px-3 py-2 text-sm font-semibold text-[#EC5757] hover:bg-[#7E88C3] dark:hover:bg-[#303559]"
            >
              Delete Account
            </button>
          </div>
        </div>
      </form>
    </div>
    """
  end

  def email_notifications(assigns) do
    ~H"""
    <div class="mx-auto max-w-3xl px-4 py-10 sm:px-6 lg:px-8 lg:py-12 rounded-md bg-white dark:bg-[#1E2139]">
      <form class="flex flex-col gap-4">
        <%!-- Avatar render and update section --%>
        <.render_avatar current_user={@current_user} />
        <h2 class="font-medium text-xl">Edit Notification Preferences</h2>
        <div class="grid grid-cols-1 gap-y-6 sm:grid-cols-6 sm:gap-x-6">
          <fieldset class="col-span-6">
            <legend class="font-medium">I’d like to receive:</legend>
            <br />
            <div class="space-y-5">
              <div class="relative flex items-start">
                <div class="flex h-6 items-center">
                  <input
                    id="newsletter"
                    name="newsletter"
                    type="checkbox"
                    class="h-4 w-4 bg-[#DFE3FA] dark:bg-[#303559] border-gray-300 text-[#0C0E16] dark:text-[#7C5DFA] focus:ring-1 focus:ring-gray-300 dark:focus:ring-[#303559]"
                  />
                </div>
                <div class="ml-3 text-sm leading-6">
                  <label for="newsletter" class="font-medium">
                    Newsletter and product updates
                  </label>
                </div>
              </div>
              <div class="relative flex items-start">
                <div class="flex h-6 items-center">
                  <input
                    id="sign-in-notification"
                    name="sign-in-notification"
                    type="checkbox"
                    class="h-4 w-4 bg-[#DFE3FA] dark:bg-[#303559] border-gray-300 text-[#0C0E16] dark:text-[#7C5DFA] focus:ring-1 focus:ring-gray-300 dark:focus:ring-[#303559]"
                  />
                </div>
                <div class="ml-3 text-sm leading-6">
                  <label for="sign-in-notification" class="font-medium">
                    Sign in notification
                  </label>
                </div>
              </div>
              <div class="relative flex items-start">
                <div class="flex h-6 items-center">
                  <input
                    id="due-payment"
                    name="due-payment"
                    type="checkbox"
                    class="h-4 w-4 bg-[#DFE3FA] dark:bg-[#303559] border-gray-300 text-[#0C0E16] dark:text-[#7C5DFA] focus:ring-1 focus:ring-gray-300 dark:focus:ring-[#303559]"
                  />
                </div>
                <div class="ml-3 text-sm leading-6">
                  <label for="due-payment" class="font-medium">
                    Due payment reminders
                  </label>
                </div>
              </div>
            </div>
          </fieldset>

          <div class="sm:col-span-6 flex flex-col gap-4 sm:flex-row sm:justify-between">
            <button
              type="button"
              class="inline-flex sm:order-last justify-center rounded-full bg-blue-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-blue-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600"
            >
              Save changes
            </button>
            <button
              type="button"
              class="rounded-full px-3 py-2 text-sm font-semibold text-[#EC5757] hover:bg-[#7E88C3] dark:hover:bg-[#303559]"
            >
              Delete Account
            </button>
          </div>
        </div>
      </form>
    </div>
    """
  end

  def render_avatar(assigns) do
    ~H"""
    <div class="flex gap-2 text-xl items-center justify-center">
      <div class="flex-shrink-0">
        <img class="h-16 w-16 rounded-full" src={@current_user.avatar_url} alt="" />
      </div>
      <h2 class="min-w-0 flex-1 font-semibold">
        <%= @current_user.full_name %> / Profile information
      </h2>
    </div>
    """
  end
end
