defmodule InvoiceAppWeb.InvoiceLive.ShowTest do
  use InvoiceAppWeb.ConnCase

  alias InvoiceApp.Invoices
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

    invoice = invoice_fixture(user)
    %{conn: log_in_user(conn, user), invoice: invoice, user: user}
  end

  describe "/invoices/:id" do
    test "shows an invoice", %{conn: conn, invoice: invoice} do
      {:ok, _view, html} = live(conn, ~p"/invoices/#{invoice.id}")

      assert html =~ invoice.bill_to.name
      assert html =~ invoice.project_description
      assert html =~ Show.due_date(invoice)
      assert html =~ Calendar.strftime(invoice.date, "%d %b %Y")
    end

    test "Go Back link navigates to index page", %{conn: conn, invoice: invoice} do
      {:ok, view, _html} = live(conn, ~p"/invoices/#{invoice.id}")

      view
      |> element("[data-role=go-back]", "Go Back")
      |> render_click()

      {path, _flash} = assert_redirect(view)
      assert path == ~p"/invoices"
    end
  end

  describe "smaller screens button actions" do
    test "Edit button navigates to edit page", %{conn: conn, invoice: invoice} do
      {:ok, view, _html} = live(conn, ~p"/invoices/#{invoice.id}")

      view
      |> element("[data-role=edit-invoice-sm]", "Edit")
      |> render_click()

      {path, _flash} = assert_redirect(view)
      assert path == ~p"/invoices/#{invoice.id}/edit"
    end

    test "changes invoice status", %{conn: conn, invoice: invoice} do
      {:ok, view, _html} = live(conn, ~p"/invoices/#{invoice.id}")

      view
      |> element("[data-role=change-status-sm]", "Mark as")
      |> render_click()

      updated_invoice = Invoices.get_invoice!(invoice.id)

      refute invoice.status == updated_invoice.status
    end
  end

  describe "larger screens button actions" do
    test "Edit button navigates to edit page", %{conn: conn, invoice: invoice} do
      {:ok, view, _html} = live(conn, ~p"/invoices/#{invoice.id}")

      view
      |> element("[data-role=edit-invoice-lg]", "Edit")
      |> render_click()

      {path, _flash} = assert_redirect(view)
      assert path == ~p"/invoices/#{invoice.id}/edit"
    end

    test "changes invoice status", %{conn: conn, invoice: invoice} do
      {:ok, view, _html} = live(conn, ~p"/invoices/#{invoice.id}")

      view
      |> element("[data-role=change-status-lg]", "Mark as")
      |> render_click()

      updated_invoice = Invoices.get_invoice!(invoice.id)

      refute invoice.status == updated_invoice.status
    end
  end

  describe "Edit Invoice" do
    @update_attrs %{"project_description" => "updated description"}
    @invalid_attrs %{"project_description" => nil}

    test "edit button navigates to edit page", %{conn: conn, invoice: invoice} do
      {:ok, view, html} = live(conn, ~p"/invoices/#{invoice.id}/edit")

      assert has_element?(view, ~s(button[data-role="save-invoice"]), "Save Changes")
      assert html =~ "Bill To"
      assert html =~ "Project Description"
    end

    test "cancel button on edit page navigates to show page", %{conn: conn, invoice: invoice} do
      {:ok, view, _html} = live(conn, ~p"/invoices/#{invoice.id}/edit")

      view
      |> element(~s([data-role="cancel-edit"]), "Cancel")
      |> render_click()

      {path, _flash} = assert_redirect(view)
      assert path == ~p"/invoices/#{invoice.id}"
    end

    test "edit invoice with invalid params fails", %{conn: conn, invoice: invoice} do
      {:ok, view, _html} = live(conn, ~p"/invoices/#{invoice.id}/edit")

      view
      |> form("#invoice-form", %{"invoice_form" => @invalid_attrs})
      |> render_submit()

      assert render(view) =~ "can&#39;t be blank"
    end

    test "edit invoice with valid params succeeds", %{conn: conn, invoice: invoice} do
      {:ok, view, _html} = live(conn, ~p"/invoices/#{invoice.id}/edit")

      view
      |> form("#invoice-form", %{"invoice_form" => @update_attrs})
      |> render_submit()

      {path, %{"info" => info}} = assert_redirect(view)
      updated_invoice = Invoices.get_invoice!(invoice.id)

      assert path == ~p"/invoices/#{invoice.id}"
      assert info == "Invoice updated successfully"
      refute invoice.project_description == updated_invoice.project_description
    end
  end
end
