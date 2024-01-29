defmodule InvoiceAppWeb.InvoicesLiveTest do
  use InvoiceAppWeb.ConnCase

  import Phoenix.LiveViewTest
  import InvoiceApp.AccountsFixtures

  test "redirects to login page if user is not authenticated", %{conn: conn} do
    {:error, {:redirect, to}} = live(conn, ~p"/invoices")

    assert to == %{
             flash: %{"error" => "You must log in to access this page."},
             to: ~p"/users/log_in"
           }
  end

  describe "Invoices page" do
    setup %{conn: conn} do
      user = confirm_email(user_fixture())
      %{conn: log_in_user(conn, user), user: user}
    end

    test "renders invoices page", %{conn: conn, user: user} do
      {:ok, _lv, html} = live(conn, ~p"/invoices")

      assert html =~ "There is nothing here"
      assert html =~ user.email
    end
  end
end
