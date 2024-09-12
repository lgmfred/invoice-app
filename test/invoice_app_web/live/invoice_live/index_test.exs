defmodule InvoiceAppWeb.InvoiceLive.IndexTest do
  use InvoiceAppWeb.ConnCase

  alias InvoiceAppWeb.InvoiceLive.Index
  alias InvoiceAppWeb.InvoiceLive.Show

  import Phoenix.LiveViewTest
  import InvoiceApp.AccountsFixtures
  import InvoiceApp.InvoicesFixtures

  setup %{conn: conn} do
    user =
      user_fixture()
      |> confirm_email()
      |> add_address()
      |> add_avatar()

    %{conn: log_in_user(conn, user), user: user}
  end

  describe "/invoices" do
    test "redirects to '/invoices/new' when 'New Invoice' link is clicked", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/invoices")

      view
      |> element("[data-role=new-invoice]", "New")
      |> render_click()

      {path, _flash} = assert_redirect(view)
      assert path == ~p"/invoices/new"
    end
  end

  describe "/invoices: listing invoices" do
    test "renders empty state when there are no invoices", %{conn: conn} do
      {:ok, view, html} = live(conn, ~p"/invoices")

      assert has_element?(view, ~s(img[src*="/images/open-envelope.svg"]))
      assert html =~ "There is nothing here"
    end

    test "lists all invoices", %{conn: conn, user: user} do
      {invoice1, invoice2, invoice3} = create_three_invoices(user)
      {:ok, _view, html} = live(conn, ~p"/invoices")

      assert html =~ invoice1.bill_to.name
      assert html =~ Show.due_date(invoice2)
      assert html =~ Index.grand_total(invoice3.items)
    end

    test "clicking on an invoice redirects to the show page", %{conn: conn, user: user} do
      invoice = invoice_fixture(user)
      {:ok, view, _html} = live(conn, ~p"/invoices")

      view
      |> element(~s(a[href*="/invoices/#{invoice.id}"]), invoice.bill_to.name)
      |> render_click()

      {path, _flash} = assert_redirect(view)
      assert path == ~p"/invoices/#{invoice.id}"
    end
  end

  describe "/invoices: filter by status" do
    test "filter paid invoices", %{conn: conn, user: user} do
      {invoice1, invoice2, invoice3} = create_three_invoices(user)
      {:ok, view, _html} = live(conn, ~p"/invoices")

      html =
        view
        |> form("#filter", %{"status" => "paid"})
        |> render_change()

      assert html =~ invoice1.bill_to.name
      refute html =~ invoice2.bill_to.name
      refute html =~ invoice3.bill_to.name
    end

    test "filter pending invoices", %{conn: conn, user: user} do
      {invoice1, invoice2, invoice3} = create_three_invoices(user)
      {:ok, view, _html} = live(conn, ~p"/invoices")

      html =
        view
        |> form("#filter", %{"status" => "pending"})
        |> render_change()

      assert html =~ invoice2.bill_to.name
      refute html =~ invoice1.bill_to.name
      refute html =~ invoice3.bill_to.name
    end

    test "filter draft invoices", %{conn: conn, user: user} do
      {invoice1, invoice2, invoice3} = create_three_invoices(user)
      {:ok, view, _html} = live(conn, ~p"/invoices")

      html =
        view
        |> form("#filter", %{"status" => "draft"})
        |> render_change()

      assert html =~ invoice3.bill_to.name
      refute html =~ invoice1.bill_to.name
      refute html =~ invoice2.bill_to.name
    end
  end

  defp create_three_invoices(user) do
    {
      invoice_fixture(user, %{status: "paid"}),
      invoice_fixture(user, %{status: "pending"}),
      invoice_fixture(user, %{status: "draft"})
    }
  end
end
