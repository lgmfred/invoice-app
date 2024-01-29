defmodule InvoiceAppWeb.UserConfirmationInstructionsLiveTest do
  use InvoiceAppWeb.ConnCase

  import Phoenix.LiveViewTest
  import InvoiceApp.AccountsFixtures

  alias InvoiceApp.Accounts
  alias InvoiceApp.Repo

  setup do
    %{user: user_fixture()}
  end

  describe "Resend confirmation" do
    test "renders email confirmation page (without url param)", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/confirm")
      assert html =~ "No confirmation instructions received?"
      assert html =~ "Resend confirmation instructions"
    end

    test "renders email confirmation page (with invalid url param)", %{
      conn: conn
    } do
      {:error, {:live_redirect, %{to: path}}} =
        live(conn, ~p"/users/confirm?email=#{unique_user_email()}")

      assert path == ~p"/users/confirm"
    end

    test "renders email confirmation page (with valid url param)", %{
      conn: conn,
      user: user
    } do
      {:ok, _view, html} = live(conn, ~p"/users/confirm?email=#{user.email}")

      assert html =~ user.email
      assert html =~ "Confirm Your Email Address."
      assert html =~ " Please follow the link in the message to confirm your email address."
    end

    test "sends a new confirmation token (logged out user types their email)", %{
      conn: conn,
      user: user
    } do
      {:ok, lv, _html} = live(conn, ~p"/users/confirm")

      {:ok, conn} =
        lv
        |> form("#resend_confirmation_form", user: %{email: user.email})
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      assert Repo.get_by!(Accounts.UserToken, user_id: user.id).context == "confirm"
    end

    test "sends a new confirmation token (logged out user after redirection from registration page)",
         %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, ~p"/users/confirm?email=#{user.email}")

      {:ok, conn} =
        view
        |> form("#resend_confirmation_form", user: %{})
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "We've sent a confirmation email. Please follow the link in the message to confirm your email address."
    end

    test "does not send confirmation token if user is confirmed", %{conn: conn, user: user} do
      Repo.update!(Accounts.User.confirm_changeset(user))

      {:ok, lv, _html} = live(conn, ~p"/users/confirm")

      {:ok, conn} =
        lv
        |> form("#resend_confirmation_form", user: %{email: user.email})
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      refute Repo.get_by(Accounts.UserToken, user_id: user.id)
    end

    test "does not send confirmation token if email is invalid", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/confirm")

      {:ok, conn} =
        lv
        |> form("#resend_confirmation_form", user: %{email: "unknown@example.com"})
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      assert Repo.all(Accounts.UserToken) == []
    end
  end
end
