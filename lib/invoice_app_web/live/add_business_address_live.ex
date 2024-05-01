defmodule InvoiceAppWeb.AddBusinessAddressLive do
  use InvoiceAppWeb, :live_view

  alias InvoiceApp.Accounts
  alias InvoiceApp.Accounts.BusinessAddress

  def mount(_params, _session, socket) do
    changeset = address_changeset(socket)

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="h-screen lg:mx-6 flex flex-col place-content-center gap-6 lg:gap-4">
      <.link
        data-role="avatar-update-link"
        navigate={~p"/users/add_avatar"}
        class="hidden lg:flex items-center justify-start gap-1 my-0 font-medium text-lg text-[#7C5DFA]"
      >
        <svg width="12" height="12" viewBox="0 0 12 18" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path
            d="M4.43766 9.00002L11.0377 15.6L9.15233 17.4854L0.666992 9.00002L9.15233 0.514682L11.0377 2.40001L4.43766 9.00002Z"
            fill="#7C5DFA"
          />
        </svg>
        <div>Back</div>
      </.link>

      <div class="lg:mx-16 flex flex-col gap-4">
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
        <h1 class="text-2xl font-semibold text-[#000000]">Enter your business address details</h1>
        <.form
          for={@form}
          id="address_form"
          phx-submit="save-address"
          phx-trigger-action={@trigger_submit}
          action={~p"/users/add_address"}
          method="post"
          class="flex flex-col place-content-center gap-2 text-left"
        >
          <.error :if={@check_errors}>
            Oops, something went wrong! Please check the errors below.
          </.error>
          <div class="grid lg:grid-cols-2 gap-2 lg:gap-4">
            <.input
              field={@form[:country]}
              type="select"
              label="Country"
              options={country_options()}
              required
            />
            <.input field={@form[:city]} type="text" label="City" placeholder="City Name" required />
          </div>
          <.input
            field={@form[:street_address]}
            type="text"
            label="Street Address"
            placeholder="Street Address"
            required
          />
          <.input
            field={@form[:postal_code]}
            type="text"
            label="Postal Code"
            placeholder="Postal Code"
            required
          />
          <.input
            field={@form[:phone_number]}
            type="tel"
            label="Phone Number"
            placeholder="Phone Number"
            required
          />
          <div class="mt-8 flex place-content-between lg:place-content-end text-lg font-semibold">
            <.link
              navigate={~p"/users/add_avatar"}
              class="lg:hidden px-8 py-1 flex items-center justify-center border border-[#979797] rounded-full text-[#000000] text-center"
            >
              Back
            </.link>
            <button
              type="submit"
              phx-disable-with="Saving..."
              class="px-8 lg:px-16 py-1 flex items-center justify-center rounded-full text-[#FFFFFF] bg-[#7C5DFA]"
            >
              Save
            </button>
          </div>
        </.form>
      </div>
    </div>
    """
  end

  def handle_event("save-address", address_params, socket) do
    user = socket.assigns.current_user

    case Accounts.update_user(user, address_params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> assign(current_user: user)
         |> put_flash(:info, "Address updated successfully.")
         |> push_navigate(to: ~p"/invoices")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(check_errors: true)
         |> assign_form(changeset)
         |> put_flash(:info, "An error occurred during address update.")}
    end
  end

  defp address_changeset(socket, params \\ %{}) do
    if socket.assigns.current_user.business_address do
      socket.assigns.current_user.business_address
      |> BusinessAddress.changeset(params)
    else
      %BusinessAddress{}
      |> BusinessAddress.changeset()
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "business_address")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end

  def country_options do
    tl =
      Countries.all()
      |> Enum.into(%{}, fn x -> {x.name, x.alpha2} end)
      |> Enum.sort()

    [{"Choose Country", ""} | tl]
  end
end
