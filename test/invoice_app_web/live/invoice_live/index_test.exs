defmodule InvoiceAppWeb.InvoiceLive.IndexTest do
  use InvoiceAppWeb.ConnCase

  alias Faker.Address
  alias Faker.Internet
  alias Faker.Person
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

  describe "/invoices/new" do
    @valid_attrs %{
      bill_from: %{
        city: Address.city(),
        country: Address.country_code(),
        post_code: Address.postcode(),
        street_address: Address.street_address()
      },
      bill_to: %{
        city: Address.city(),
        name: Person.name(),
        country: Address.country_code(),
        email: Internet.email(),
        post_code: Address.postcode(),
        street_address: Address.street_address()
      },
      date: Date.utc_today(),
      items: %{
        "0" => %{
          name: "new item name",
          quantity: 4,
          price: 9.5,
          total: 4 * 9.5
        }
      },
      payment_term: 14,
      project_description: "new project description"
    }
    @invalid_attrs %{}

    test "renders new invoice page", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/invoices/new")

      assert html =~ "New Invoice"
      assert html =~ "Bill From"
      assert html =~ "Bill To"
    end

    test "invalid attrs render serrors", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/invoices/new")

      view
      |> form("#invoice-form", %{"invoice_form" => @invalid_attrs})
      |> render_submit()

      assert render(view) =~ "can&#39;t be blank"
    end

    test "valid attrs creates new invoice", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/invoices/new")

      view
      |> form("#invoice-form", %{"invoice_form" => @valid_attrs})
      |> render_submit()

      {path, %{"info" => info}} = assert_redirect(view)

      assert path == ~p"/invoices"
      assert info == "Invoice created successfully"
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
