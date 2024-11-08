defmodule InvoiceAppWeb.UserAddAvatarLive do
  use InvoiceAppWeb, :live_view

  alias InvoiceApp.Accounts

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      allow_upload(socket, :avatar,
        accept: ~w(.png .jpeg .jpg),
        max_entries: 1,
        max_file_size: 400_000
      )

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="h-screen mx-8 flex flex-col place-content-center gap-6 lg:gap-4">
      <div class="h-20 flex gap-4 items-center justify-center">
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
      <div class="text-left md:text-center">
        <h2 class="text-2xl font-semibold text-[#000000]">Welcome! Let's create your profile</h2>
        <p class="text-xl font-light text-[#979797]">Just a few more steps...</p>
      </div>
      <h3 class="justify-self-start text-xl font-semibold text-[#000000]">Add an avatar</h3>
      <form
        class="w-full grid grid-cols-2 gap-4 text-[#FFFFFF]"
        id="upload-form"
        phx-submit="upload"
        phx-change="validate"
      >
        <img
          :if={@uploads.avatar.entries == [] && @current_user.avatar_url}
          src={@current_user.avatar_url}
          data-role="user-avatar"
          class="w-24 h-24  justify-self-center rounded-full border-2 border-dashed "
          alt="Avatar"
        />
        <div
          :if={@uploads.avatar.entries == [] && !@current_user.avatar_url}
          class="w-24 h-24 flex justify-center items-center border-2 border-dashed rounded-full"
        >
          <img data-role="default-avatar" src="/images/default_avatar.png" alt="Avatar" />
        </div>
        <%= for entry <- @uploads.avatar.entries do %>
          <article :if={@uploads.avatar.entries != []} class="justify-self-center">
            <.link
              data-role="cancel-upload"
              phx-click="cancel-upload"
              phx-value-ref={entry.ref}
              aria-label="cancel"
              class="flex justify-end text-[#E86969]"
            >
              &times;
            </.link>
            <.live_img_preview
              data-role="image-preview"
              entry={entry}
              class="w-24 h-24 rounded-full outline-double"
            />
          </article>
        <% end %>

        <label class="justify-self-start my-auto px-1 py-1 bg-[#7C5DFA] rounded-full font-semibold hover:cursor-pointer">
          <.live_file_input class="hidden" upload={@uploads.avatar} />
          <span>Choose Image</span>
        </label>

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

        <button
          type="submit"
          class="col-start-2 col-end-2 my-auto justify-self-center px-10 py-2 bg-[#979797] rounded-full font-semibold"
        >
          Continue
        </button>
      </form>
      <img class="lg:hidden w-full h-full" src="/images/add_avatar_bottom.png" alt="" />
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :avatar, ref)}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("upload", _params, socket) do
    case consume_uploads(socket) do
      [] ->
        {:noreply, push_navigate(socket, to: ~p"/invoices")}

      [avatar_url | _] ->
        update_user(socket, avatar_url)
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

    case Accounts.update_user(current_user, attrs) do
      {:ok, user} ->
        {:noreply,
         socket
         |> assign(:current_user, user)
         |> push_navigate(to: ~p"/invoices")}

      {:error, %Ecto.Changeset{} = _changeset} ->
        {:noreply, socket}
    end
  end

  def error_to_string(:too_large), do: "Too large"
  def error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  def error_to_string(:too_many_files), do: "You have selected too many files"
end
