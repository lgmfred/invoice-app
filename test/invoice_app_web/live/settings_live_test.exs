defmodule InvoiceAppWeb.SettingsLiveTest do
  use InvoiceAppWeb.ConnCase

  import Phoenix.LiveViewTest
  import InvoiceApp.AccountsFixtures

  alias InvoiceApp.Accounts

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
      |> add_address()
      |> add_avatar()

    %{conn: log_in_user(conn, user), user: user}
  end

  test "redirects to personal tab if parameter is not set", %{conn: conn} do
    {:error, {:live_redirect, %{to: path}}} = live(conn, ~p"/settings")
    assert path == ~p"/settings?tab=personal"
  end

  describe "/settings: live patch between tabs" do
    test "can click to visit Personal tab", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/settings?tab=email")

      view
      |> element("[data-role=personal]", "Personal")
      |> render_click()

      assert render(view) =~ "Edit Profile Information"
    end

    test "can click to visit Email notifications tab", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/settings?tab=personal")

      view
      |> element("[data-role=email]", "Email notifications")
      |> render_click()

      assert render(view) =~ "Edit Notification Preferences"
    end

    test "can click to visit Password tab", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/settings?tab=personal")

      view
      |> element("[data-role=password]", "Password")
      |> render_click()

      assert render(view) =~ "Change Password"
    end
  end

  describe "/settings?tab=personal" do
    test "renders settings personal tab", %{conn: conn, user: user} do
      {:ok, view, html} = live(conn, ~p"/settings?tab=personal")

      assert html =~ "#{user.full_name} / Profile information"
      assert html =~ "Edit Profile Information"

      assert has_element?(view, ~s(button[type="submit"]), "Save changes")
      assert has_element?(view, ~s(button[type="button"]), "Delete Account")
    end

    test "user sees error when a larger file is uploaded", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/settings?tab=personal")

      view
      |> upload("keynote_elixir_brazil.jpeg", "image/jpeg")

      assert has_element?(view, "[data-role='entry-upload-error']", "Too large")
    end

    test "user can upload a new avatar", %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, ~p"/settings?tab=personal")

      avatar = element(view, ~s(img[src*="#{user.avatar_url}"]))
      assert has_element?(avatar)

      view
      |> upload("cookie-monster.png", "image/png")

      updated_user = Accounts.get_user!(user.id)
      avatar_new = element(view, ~s(img[src*="#{updated_user.avatar_url}"]))

      refute has_element?(avatar)
      assert has_element?(avatar_new)
      refute user.avatar_url == updated_user.avatar_url
    end

    test "user can delete avatar (delete button)", %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, ~p"/settings?tab=personal")

      avatar = element(view, ~s(img[src*="#{user.avatar_url}"]))
      assert has_element?(avatar)

      view
      |> element("[data-role='delete-avatar']")
      |> render_click()

      updated_user = Accounts.get_user!(user.id)

      refute has_element?(avatar)
      refute updated_user.avatar_url
    end
  end

  describe "/settings?tab=password" do
    test "renders settings password tab", %{conn: conn, user: user} do
      {:ok, view, html} = live(conn, ~p"/settings?tab=password")

      assert html =~ "#{user.full_name} / Profile information"
      assert html =~ "Change Password"

      assert has_element?(view, ~s(button[type="submit"]), "Save changes")
      assert has_element?(view, ~s(button[type="button"]), "Delete Account")
    end
  end

  describe "/settings?tab=email" do
    test "renders settings email tab", %{conn: conn, user: user} do
      {:ok, view, html} = live(conn, ~p"/settings?tab=email")

      assert html =~ "#{user.full_name} / Profile information"
      assert html =~ "Edit Notification Preferences"

      assert has_element?(view, ~s(button[type="submit"]), "Save changes")
      assert has_element?(view, ~s(button[type="button"]), "Delete Account")
    end
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
end
