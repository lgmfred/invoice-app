defmodule InvoiceAppWeb.PageControllerTest do
  use InvoiceAppWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Sign in to Invoice"
    assert html_response(conn, 200) =~ "Continue with email"
    assert html_response(conn, 200) =~ "Don't have an account?"
  end
end
