defmodule InvoiceAppWeb.UserRegistrationLiveTest do
  use InvoiceAppWeb.ConnCase

  import Phoenix.LiveViewTest
  import InvoiceApp.AccountsFixtures

  describe "Registration page" do
    test "renders registration page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/register")

      assert html =~ "Create an account"
      assert html =~ "Begin creating invoices for free!"
      assert html =~ "Log in"
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/users/register")
        |> follow_redirect(conn, "/invoices")

      assert {:ok, _conn} = result
    end

    test "renders errors for invalid data", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      result =
        lv
        |> element("#registration_form")
        |> render_change(
          user: %{
            "name" => "some name",
            "email" => "with spaces",
            "username" => "username",
            "password" => "too short"
          }
        )

      assert result =~ "Create an account"
      assert result =~ "Please enter a valid email address"
      assert result =~ "at least one digit"
      assert result =~ "should be at least 12 characters"
    end
  end

  describe "register user" do
    test "creates account and redirects to confirmation page", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/users/register")
      email = unique_user_email()

      {:ok, _view, html} =
        view
        |> form("#registration_form", user: valid_user_attributes(email: email))
        |> render_submit()
        |> follow_redirect(conn, ~p"/users/confirm?#{[email: email]}")

      assert html =~ "Confirm Your Email Address."
      assert html =~ "We&#39;ve sent a confirmation email to"
      assert html =~ email
    end

    test "renders errors for duplicated email", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      user = user_fixture(%{email: "test@email.com"})

      result =
        lv
        |> form("#registration_form",
          user: %{"email" => user.email, "password" => "valid_password"}
        )
        |> render_submit()

      assert result =~ "has already been taken"
    end

    test "renders errors for duplicated username", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      user = user_fixture(%{username: "lgmfred"})

      result =
        lv
        |> form("#registration_form",
          user: %{
            "email" => "lgmfred@ayikoyo.com",
            "username" => user.username,
            "password" => "Hello 2 world!"
          }
        )
        |> render_submit()

      assert result =~ "This username is taken"
    end
  end

  describe "registration navigation" do
    test "redirects to login page when the Log in button is clicked", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      {:ok, _login_live, login_html} =
        lv
        |> element(~s|main a:fl-contains("Log in")|)
        |> render_click()
        |> follow_redirect(conn, ~p"/users/log_in")

      assert login_html =~ "Sign in to Invoice"
      assert login_html =~ "Continue"
      assert login_html =~ "Don&#39;t have an account?"
    end
  end
end
