defmodule InvoiceAppWeb.UserAddAvatarLiveTest do
  alias InvoiceApp.Accounts
  use InvoiceAppWeb.ConnCase, async: false

  import Phoenix.LiveViewTest
  import InvoiceApp.AccountsFixtures

  setup do
    on_exit(fn ->
      File.rm_rf!(InvoiceApp.uploads_dir())
      File.mkdir_p!(InvoiceApp.uploads_dir())
    end)
  end

  setup %{conn: conn} do
    user =
      user_fixture()
      |> confirm_email()

    %{conn: log_in_user(conn, user), user: user}
  end

  test "user can see the default avatar if one isn't uploaded yet", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/users/add_avatar")
    default_avatar = "/images/default_avatar.png"

    assert has_element?(view, "[data-role='default-avatar']")
    assert has_element?(view, ~s(img[src*="#{default_avatar}"]))
    refute has_element?(view, "[data-role='user-avatar']")
  end

  test "user can see the preview of pictures to be uploaded", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/users/add_avatar")

    view
    |> upload("keynote_elixir_brazil.jpeg", "image/jpeg")

    assert has_element?(view, "[data-role='image-preview']")
  end

  test "user can cancel upload", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/users/add_avatar")

    view
    |> upload("keynote_elixir_brazil.jpeg", "image/jpeg")
    |> cancel_upload()

    refute has_element?(view, "[data-role='image-preview']")
  end

  test "user sees error when a larger file is uploaded", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/users/add_avatar")

    view
    |> upload("keynote_elixir_brazil.jpeg", "image/jpeg")

    assert has_element?(view, "[data-role='entry-upload-error']", "Too large")
  end

  test "user can upload a new avatar", %{conn: conn, user: user} do
    {:ok, view, _html} = live(conn, "/users/add_avatar")

    view
    |> upload("cookie-monster.png", "image/png")
    |> form("#upload-form", %{})
    |> render_submit()
    |> follow_redirect(conn, ~p"/users/add_address")

    updated_user = Accounts.get_user!(user.id)

    {:ok, view, _html} = live(conn, "/users/add_avatar")

    refute user.avatar_url
    refute user.avatar_url == updated_user.avatar_url

    assert has_element?(view, "[data-role='user-avatar']")
    refute has_element?(view, "[data-role='default-avatar']")
  end

  defp upload(view, filename, file_type) do
    view
    |> file_input("#upload-form", :avatar, [
      %{
        name: filename,
        content: File.read!("test/support/images/#{filename}"),
        type: file_type
      }
    ])
    |> render_upload(filename)

    # ensure we have a phx-change
    # real form breaks if we don't have a phx-change validation
    view
    |> form("#upload-form")
    |> render_change()

    view
  end

  defp cancel_upload(view) do
    view
    |> element("[data-role='cancel-upload']")
    |> render_click()
  end
end
