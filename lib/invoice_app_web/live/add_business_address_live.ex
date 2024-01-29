defmodule InvoiceAppWeb.AddBusinessAddressLive do
  use InvoiceAppWeb, :live_view

  alias InvoiceApp.Accounts
  alias InvoiceApp.Accounts.BusinessAddress

  def mount(_params, _session, socket) do
    changeset =
      if socket.assigns.current_user.business_address do
        socket.assigns.current_user.business_address
        |> BusinessAddress.changeset()
      else
        BusinessAddress.changeset(%BusinessAddress{})
      end

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1>Enter your business address details</h1>
      <.simple_form
        for={@form}
        id="address_form"
        phx-submit="save-address"
        phx-trigger-action={@trigger_submit}
        action={~p"/users/add_address"}
        method="post"
        class="m-0"
      >
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input field={@form[:country]} type="select" options={country_options()} required />
        <.input field={@form[:city]} type="text" placeholder="City Name" required />
        <.input field={@form[:street_address]} type="text" placeholder="Street Address" required />
        <.input field={@form[:postal_code]} type="text" placeholder="Postal Code" required />
        <.input field={@form[:phone_number]} type="tel" placeholder="Phone Number" />

        <:actions>
          <.button phx-disable-with="Signing up..." class="w-full bg-[#7C5DFA]">Save</.button>
        </:actions>
      </.simple_form>
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
         |> redirect(to: ~p"/")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(check_errors: true)
         |> assign_form(changeset)
         |> put_flash(:info, "An error occurred during address update.")}
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
