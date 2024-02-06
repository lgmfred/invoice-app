defmodule InvoiceAppWeb.UserSettingsLiveTest do
  use InvoiceAppWeb.ConnCase

  import Phoenix.LiveViewTest
  import InvoiceApp.AccountsFixtures

  alias Faker.Person.Fr
  alias InvoiceApp.Accounts

  setup do
    %{user: confirm_email(user_fixture())}
  end

  describe "Settings page" do
    test "renders settings page", %{conn: conn, user: user} do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/users/settings")

      assert html =~ "Change Name"
      assert html =~ "Change Username"
      assert html =~ "Change Email"
      assert html =~ "Change Password"
    end

    test "redirects if user is not logged in", %{conn: conn, user: _user} do
      assert {:error, redirect} = live(conn, ~p"/users/settings")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log_in"
      assert %{"error" => "You must log in to access this page."} = flash
    end
  end

  describe "update full name" do
    setup %{conn: conn} do
      password = valid_user_password()

      user =
        user_fixture(%{password: password})
        |> confirm_email()

      %{conn: log_in_user(conn, user), user: user, password: password}
    end

    test "full_name update validation errors", %{conn: conn, user: user, password: password} do
      {:ok, view, _html} = live(conn, ~p"/users/settings")

      result =
        view
        |> form("#name_form", %{
          "current_password" => password,
          "user" => %{"full_name" => ""}
        })
        |> render_change()

      refetch_user = Accounts.get_user!(user.id)

      assert result =~ "can&#39;t be blank"
      assert refetch_user.full_name == user.full_name
    end

    test "full_name update submit errors", %{conn: conn, user: user, password: _password} do
      full_name = Fr.name()
      {:ok, view, _html} = live(conn, ~p"/users/settings")

      result =
        view
        |> form("#name_form", %{
          "current_password" => "wrong password",
          "user" => %{"full_name" => full_name}
        })
        |> render_submit()

      updated_user = Accounts.get_user!(user.id)

      assert result =~ "Password is not valid."
      assert updated_user.full_name == user.full_name
      refute updated_user.full_name == full_name
    end

    test "full_name update submit success", %{conn: conn, user: user, password: password} do
      full_name = Fr.name()
      {:ok, view, _html} = live(conn, ~p"/users/settings")

      view
      |> form("#name_form", %{
        "current_password" => password,
        "user" => %{"full_name" => full_name}
      })
      |> render_submit()

      updated_user = Accounts.get_user!(user.id)

      assert updated_user.full_name == full_name
      refute updated_user.full_name == user.full_name
    end
  end

  describe "update username" do
    setup %{conn: conn} do
      password = valid_user_password()

      user =
        user_fixture(%{password: password})
        |> confirm_email()

      %{conn: log_in_user(conn, user), user: user, password: password}
    end

    test "username update validation errors", %{conn: conn, user: user, password: password} do
      {:ok, view, _html} = live(conn, ~p"/users/settings")

      result =
        view
        |> form("#username_form", %{
          "current_password" => password,
          "user" => %{"username" => user.username}
        })
        |> render_change()

      assert result =~ "did not change"
    end

    test "username update submit errors", %{conn: conn, user: user, password: password} do
      existing_user = user_fixture()
      {:ok, view, _html} = live(conn, ~p"/users/settings")

      result =
        view
        |> form("#username_form", %{
          "current_password" => password,
          "user" => %{"username" => existing_user.username}
        })
        |> render_submit()

      refetch_user = Accounts.get_user!(user.id)

      assert result =~ "This username is taken"
      assert refetch_user.username == user.username
    end

    test "username update submit success", %{conn: conn, user: user, password: password} do
      unique_username = unique_username()
      {:ok, view, _html} = live(conn, ~p"/users/settings")

      view
      |> form("#username_form", %{
        "current_password" => password,
        "user" => %{"username" => unique_username}
      })
      |> render_submit()

      updated_user = Accounts.get_user!(user.id)

      assert updated_user.username == unique_username
      refute updated_user.username == user.username
    end
  end

  describe "update email form" do
    setup %{conn: conn} do
      password = valid_user_password()

      user =
        user_fixture(%{password: password})
        |> confirm_email()

      %{conn: log_in_user(conn, user), user: user, password: password}
    end

    test "updates the user email", %{conn: conn, password: password, user: user} do
      new_email = unique_user_email()

      {:ok, lv, _html} = live(conn, ~p"/users/settings")

      result =
        lv
        |> form("#email_form", %{
          "current_password" => password,
          "user" => %{"email" => new_email}
        })
        |> render_submit()

      assert result =~ "A link to confirm your email"
      assert Accounts.get_user_by_email(user.email)
    end

    test "renders errors with invalid data (phx-change)", %{conn: conn, user: _user} do
      {:ok, lv, _html} = live(conn, ~p"/users/settings")

      result =
        lv
        |> element("#email_form")
        |> render_change(%{
          "action" => "update_email",
          "current_password" => "invalid",
          "user" => %{"email" => "with spaces"}
        })

      assert result =~ "Change Email"
      assert result =~ "Please enter a valid email address"
    end

    test "renders errors with invalid data (phx-submit)", %{conn: conn, user: user} do
      {:ok, lv, _html} = live(conn, ~p"/users/settings")

      result =
        lv
        |> form("#email_form", %{
          "current_password" => "invalid",
          "user" => %{"email" => user.email}
        })
        |> render_submit()

      assert result =~ "Change Email"
      assert result =~ "did not change"
      assert result =~ "is not valid"
    end
  end

  describe "update password form" do
    setup %{conn: conn} do
      password = valid_user_password()

      user =
        user_fixture(%{password: password})
        |> confirm_email()

      %{conn: log_in_user(conn, user), user: user, password: password}
    end

    test "updates the user password", %{conn: conn, user: user, password: password} do
      new_password = valid_user_password()

      {:ok, lv, _html} = live(conn, ~p"/users/settings")

      form =
        form(lv, "#password_form", %{
          "current_password" => password,
          "user" => %{
            "email" => user.email,
            "password" => new_password,
            "password_confirmation" => new_password
          }
        })

      render_submit(form)

      new_password_conn = follow_trigger_action(form, conn)

      assert redirected_to(new_password_conn) == ~p"/users/settings"

      assert get_session(new_password_conn, :user_token) != get_session(conn, :user_token)

      assert Phoenix.Flash.get(new_password_conn.assigns.flash, :info) =~
               "Password updated successfully"

      assert Accounts.get_user_by_email_and_password(user.email, new_password)
    end

    test "renders errors with invalid data (phx-change)", %{conn: conn, user: _user} do
      {:ok, lv, _html} = live(conn, ~p"/users/settings")

      result =
        lv
        |> element("#password_form")
        |> render_change(%{
          "current_password" => "invalid",
          "user" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      assert result =~ "Change Password"
      assert result =~ "should be at least 12 characters"
      assert result =~ "does not match password"
    end

    test "renders errors with invalid data (phx-submit)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/settings")

      result =
        lv
        |> form("#password_form", %{
          "current_password" => "invalid",
          "user" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })
        |> render_submit()

      assert result =~ "Change Password"
      assert result =~ "should be at least 12 characters"
      assert result =~ "does not match password"
      assert result =~ "is not valid"
    end
  end

  describe "confirm email" do
    setup %{conn: conn} do
      user = confirm_email(user_fixture())
      email = unique_user_email()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_update_email_instructions(%{user | email: email}, user.email, url)
        end)

      %{conn: log_in_user(conn, user), token: token, email: email, user: user}
    end

    test "updates the user email once", %{conn: conn, user: user, token: token, email: email} do
      {:error, redirect} = live(conn, ~p"/users/settings/confirm_email/#{token}")

      assert {:live_redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/settings"
      assert %{"info" => message} = flash
      assert message == "Email changed successfully."
      refute Accounts.get_user_by_email(user.email)
      assert Accounts.get_user_by_email(email)

      # use confirm token again
      {:error, redirect} = live(conn, ~p"/users/settings/confirm_email/#{token}")
      assert {:live_redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/settings"
      assert %{"error" => message} = flash
      assert message == "Email change link is invalid or it has expired."
    end

    test "does not update email with invalid token", %{conn: conn, user: user} do
      {:error, redirect} = live(conn, ~p"/users/settings/confirm_email/oops")
      assert {:live_redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/settings"
      assert %{"error" => message} = flash
      assert message == "Email change link is invalid or it has expired."
      assert Accounts.get_user_by_email(user.email)
    end

    test "redirects if user is not logged in", %{token: token} do
      conn = build_conn()
      {:error, redirect} = live(conn, ~p"/users/settings/confirm_email/#{token}")
      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log_in"
      assert %{"error" => message} = flash
      assert message == "You must log in to access this page."
    end
  end
end
