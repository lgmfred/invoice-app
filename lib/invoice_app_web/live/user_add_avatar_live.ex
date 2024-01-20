defmodule InvoiceAppWeb.UserAddAvatarLive do
  use InvoiceAppWeb, :live_view

  alias InvoiceApp.Accounts

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      allow_upload(socket, :avatar,
        accept: ~w(.png .jpeg .jpg),
        max_entries: 1,
        max_file_size: 600_000
      )

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="flex flex-col justify-center items-center gap-8 m-10">
      <div class="w-full flex place-content-start gap-4 font-semibold text-4xl text-[#7C5DFA]">
        <svg class="w-10 h-10" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 43 41" fill="none">
          <path
            fill-rule="evenodd"
            clip-rule="evenodd"
            d="M11.0887 0.554688L21.2344 20.8461L31.3797 0.555474C37.985 4.15522 42.467 11.1605 42.467 19.2126C42.467 30.9395 32.9604 40.4461 21.2335 40.4461C9.50656 40.4461 0 30.9395 0 19.2126C0 11.1599 4.48265 4.1542 11.0887 0.554688Z"
            fill="#7C5DFA"
          />
        </svg>
        <h1>Invoice</h1>
      </div>
      <div class="text-left">
        <h2 class="text-2xl font-semibold text-[#000000]">Welcome! Let's create your profile</h2>
        <p class="text-xl font-light text-[#979797]">Just a few more steps...</p>
      </div>
      <div>
        <h3 class="text-xl font-semibold text-[#000000]">Add an avatar</h3>
        <img src={@current_user.avatar_url} alt="My Avatar" />
        <form id="upload-form" phx-submit="upload" phx-change="validate">
          <.live_file_input upload={@uploads.avatar} />
          <button type="submit">Upload</button>

          <%!-- use phx-drop-target with the upload ref to enable file drag and drop --%>
          <section phx-drop-target={@uploads.avatar.ref}>
            <%!-- render each avatar entry --%>
            <%= for entry <- @uploads.avatar.entries do %>
              <article class="upload-entry">
                <figure>
                  <.live_img_preview entry={entry} />
                  <figcaption><%= entry.client_name %></figcaption>
                </figure>
                <%!-- entry.progress will update automatically for in-flight entries --%>
                <progress value={entry.progress} max="100"><%= entry.progress %>%</progress>
                <%!-- a regular click event whose handler will invoke Phoenix.LiveView.cancel_upload/3 --%>
                <button
                  type="button"
                  phx-click="cancel-upload"
                  phx-value-ref={entry.ref}
                  aria-label="cancel"
                >
                  &times;
                </button>
                <%!-- Phoenix.Component.upload_errors/2 returns a list of error atoms --%>
                <%= for err <- upload_errors(@uploads.avatar, entry) do %>
                  <p class="alert alert-danger"><%= error_to_string(err) %></p>
                <% end %>
              </article>
            <% end %>
            <%!-- Phoenix.Component.upload_errors/1 returns a list of error atoms --%>
            <%= for err <- upload_errors(@uploads.avatar) do %>
              <p class="alert alert-danger"><%= error_to_string(err) %></p>
            <% end %>
          </section>
        </form>
      </div>
      <img src="/images/add_avatar_bottom.png" alt="" />
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :avatar, ref)}
  end

  @impl Phoenix.LiveView
  def handle_event("upload", _params, socket) do
    avatar_locations =
      consume_uploaded_entries(socket, :avatar, fn %{path: path}, entry ->
        dest =
          Path.join([
            "priv",
            "static",
            "uploads",
            "#{entry.uuid}-#{entry.client_name}"
          ])

        File.mkdir_p!(Path.dirname(dest))
        File.cp!(path, dest)
        avatar_url_path = static_path(socket, ~p"/uploads/#{Path.basename(dest)}")
        {:ok, avatar_url_path}
      end)

    attrs = %{avatar_url: hd(avatar_locations)}
    old_avatar = socket.assigns.current_user.avatar_url

    case Accounts.update_user(socket.assigns.current_user, attrs) do
      {:ok, user} ->
        Path.join(["priv", "static", old_avatar])
        |> File.rm!()

        {:noreply, assign(socket, current_user: user)}

      {:error, %Ecto.Changeset{} = _changeset} ->
        {:noreply, socket}
    end
  end

  def error_to_string(:too_large), do: "Too large"
  def error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  def error_to_string(:too_many_files), do: "You have selected too many files"
end
