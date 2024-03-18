defmodule InvoiceAppWeb.AddBusinessAddressLiveTest do
  alias InvoiceApp.Accounts
  use InvoiceAppWeb.ConnCase

  import Phoenix.LiveViewTest
  import InvoiceApp.AccountsFixtures

  setup %{conn: conn} do
    address = valid_address_attributes()

    user =
      user_fixture(%{business_address: address})
      |> confirm_email()

    %{conn: log_in_user(conn, user), user: user}
  end

  test "renders address update page", %{conn: conn, user: user} do
    {:ok, _view, html} = live(conn, ~p"/users/add_address")

    assert html =~ "Enter your business address details"
    assert html =~ user.business_address.country
    assert html =~ user.business_address.phone_number
  end

  test "user can click the Back link to redirect to avatar page", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/users/add_address")

    {:ok, _avatar_view, avatar_html} =
      view
      |> element("[data-role='avatar-update-link']", "Back")
      |> render_click()
      |> follow_redirect(conn, ~p"/users/add_avatar")

    assert avatar_html =~ "Welcome! Let&#39;s create your profile"
  end

  test "user can update their business address", %{conn: conn, user: user} do
    {:ok, view, _html} = live(conn, ~p"/users/add_address")
    new_address = valid_address_attributes()

    {:ok, _view, html} =
      view
      |> form("#address_form", %{"business_address" => new_address})
      |> render_submit()
      |> follow_redirect(conn, ~p"/invoices")

    updated_user = Accounts.get_user!(user.id)

    assert html =~ "There is nothing here"
    refute user.business_address.country == updated_user.business_address.country
    refute user.business_address.city == updated_user.business_address.city
    refute user.business_address.phone_number == updated_user.business_address.phone_number
  end
end
