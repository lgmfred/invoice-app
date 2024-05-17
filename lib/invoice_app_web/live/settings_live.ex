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
    </div>
    """
  end

  def settings_header(assigns) do
    ~H"""
    <header class="border-b border-white/5">
      <h1 class="text-2xl font-bold tracking-tight">Settings</h1>
      <!-- Secondary navigation -->
      <nav class="flex overflow-x-auto py-4">
        <ul
          role="list"
          class="flex min-w-full flex-none gap-x-6 text-sm font-semibold leading-6 text-gray-400"
        >
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
    <div class="mx-auto max-w-3xl px-4 py-10 sm:px-6 lg:px-8 lg:py-12 rounded-md">
      <form class="flex flex-col gap-4">
        <%!-- Avatar render and update section --%>
        <div class="flex gap-2 items-center justify-center">
          <div class="flex-shrink-0">
            <img class="h-16 w-16 rounded-full" src={@current_user.avatar_url} alt="" />
          </div>
          <h2 class="min-w-0 flex-1 font-semibold">
            <%= @current_user.full_name %> / Profile information
          </h2>
        </div>
        <div class="flex gap-4 justify-start">
          <div class="relative">
            <input
              id="user-photo"
              name="user-photo"
              type="file"
              class="peer absolute inset-0 h-full w-full rounded-full opacity-0"
            />
            <label
              for="user-photo"
              class="pointer-events-none block rounded-full bg-white px-3 py-2 text-sm font-semibold text-slate-900 shadow-sm ring-1 ring-inset ring-slate-300 peer-hover:bg-slate-50 peer-focus:ring-2 peer-focus:ring-blue-600"
            >
              <span>Upload an new photo</span>
              <span class="sr-only"> user photo</span>
            </label>
          </div>
          <button
            type="button"
            class="inline-flex justify-center rounded-full bg-gray-400 px-3 py-2 text-sm font-semibold shadow-sm hover:bg-white focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-300"
          >
            Delete
          </button>
        </div>
        <h2 class="font-medium text-xl">Edit  Profile Information</h2>
        <div class="grid grid-cols-1 gap-y-6 sm:grid-cols-6 sm:gap-x-6">
          <div class="sm:col-span-3">
            <label for="full-name" class="block text-sm font-medium leading-6 text-slate-900">
              Name
            </label>
            <input
              type="text"
              name="full-name"
              id="full-name"
              autocomplete="full-name"
              class="mt-2 block w-full rounded-md border-0 py-1.5 text-slate-900 shadow-sm ring-1 ring-inset ring-slate-300 placeholder:text-slate-400 focus:ring-2 focus:ring-inset focus:ring-blue-500 sm:text-sm sm:leading-6"
            />
          </div>

          <div class="sm:col-span-3">
            <label for="username" class="block text-sm font-medium leading-6 text-slate-900">
              Username
            </label>
            <input
              type="text"
              name="username"
              id="username"
              autocomplete="username"
              class="mt-2 block w-full rounded-md border-0 py-1.5 text-slate-900 shadow-sm ring-1 ring-inset ring-slate-300 placeholder:text-slate-400 focus:ring-2 focus:ring-inset focus:ring-blue-500 sm:text-sm sm:leading-6"
            />
          </div>

          <div class="sm:col-span-6">
            <label for="email-address" class="block text-sm font-medium leading-6 text-slate-900">
              Email
            </label>
            <input
              type="text"
              name="email-address"
              id="email-address"
              autocomplete="email-address"
              class="mt-2 block w-full rounded-md border-0 py-1.5 text-slate-900 shadow-sm ring-1 ring-inset ring-slate-300 placeholder:text-slate-400 focus:ring-2 focus:ring-inset focus:ring-blue-500 sm:text-sm sm:leading-6"
            />
          </div>

          <div class="sm:col-span-3">
            <label for="country" class="block text-sm font-medium leading-6 text-slate-900">
              Country
            </label>
            <input
              type="text"
              name="country"
              id="country"
              autocomplete="country-name"
              class="mt-2 block w-full rounded-md border-0 py-1.5 text-slate-900 shadow-sm ring-1 ring-inset ring-slate-300 placeholder:text-slate-400 focus:ring-2 focus:ring-inset focus:ring-blue-500 sm:text-sm sm:leading-6"
            />
          </div>

          <div class="sm:col-span-3">
            <label for="city" class="block text-sm font-medium leading-6 text-slate-900">
              City
            </label>
            <input
              type="text"
              name="city"
              id="city"
              autocomplete="city-name"
              class="mt-2 block w-full rounded-md border-0 py-1.5 text-slate-900 shadow-sm ring-1 ring-inset ring-slate-300 placeholder:text-slate-400 focus:ring-2 focus:ring-inset focus:ring-blue-500 sm:text-sm sm:leading-6"
            />
          </div>

          <div class="sm:col-span-3">
            <label for="street-address" class="block text-sm font-medium leading-6 text-slate-900">
              Street Address
            </label>
            <input
              type="text"
              name="street-address"
              id="street-address"
              autocomplete="street-address"
              class="mt-2 block w-full rounded-md border-0 py-1.5 text-slate-900 shadow-sm ring-1 ring-inset ring-slate-300 placeholder:text-slate-400 focus:ring-2 focus:ring-inset focus:ring-blue-500 sm:text-sm sm:leading-6"
            />
          </div>

          <div class="sm:col-span-3">
            <label for="postal-code" class="block text-sm font-medium leading-6 text-slate-900">
              Postal Code
            </label>
            <input
              type="text"
              name="postal-code"
              id="postal-code"
              class="mt-2 block w-full rounded-md border-0 py-1.5 text-slate-900 shadow-sm ring-1 ring-inset ring-slate-300 placeholder:text-slate-400 focus:ring-2 focus:ring-inset focus:ring-blue-500 sm:text-sm sm:leading-6"
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
              class="rounded-full bg-white px-3 py-2 text-sm font-semibold text-[#EC5757] shadow-sm ring-1 ring-inset ring-slate-300 hover:bg-slate-50"
            >
              Delete Account
            </button>
          </div>
        </div>
      </form>
    </div>
    """
  end
end
