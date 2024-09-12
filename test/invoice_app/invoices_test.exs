defmodule InvoiceApp.InvoicesTest do
  use InvoiceApp.DataCase

  alias Faker.Address
  alias Faker.Internet
  alias Faker.Person
  alias InvoiceApp.Invoices
  alias InvoiceApp.Invoices.Invoice

  import InvoiceApp.AccountsFixtures
  import InvoiceApp.InvoicesFixtures

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
    items: [
      %{
        name: "some name",
        quantity: 4,
        price: 9.5,
        total: 4 * 9.5
      }
    ],
    payment_term: 14,
    project_description: "some project description",
    status: "pending"
  }

  @update_attrs %{
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
    items: [
      %{
        name: "some updated name",
        quantity: 4,
        price: 9.5,
        total: 4 * 9.5
      }
    ],
    payment_term: 7,
    project_description: "some updated project description",
    status: "paid"
  }

  @invalid_attrs %{
    bill_from: nil,
    bill_to: nil,
    items: nil,
    payment_term: nil,
    project_description: nil
  }

  describe "invoices" do
    setup %{} do
      user =
        user_fixture()
        |> confirm_email()
        |> add_address()
        |> add_avatar()

      %{user: user}
    end

    test "list_invoices/0 returns all invoices", %{user: user} do
      invoice = invoice_fixture(user)
      assert Invoices.list_invoices() == [invoice]
    end

    test "list_invoices/1 returns all invoices matching the given filter" do
    end

    test "get_invoice!/1 returns the invoice with given id", %{user: user} do
      invoice = invoice_fixture(user)
      assert Invoices.get_invoice!(invoice.id) == invoice
    end

    test "create_invoice/1 with valid data creates a invoice", %{user: user} do
      assert {:ok, %Invoice{} = invoice} = Invoices.create_invoice(user, @valid_attrs)
      assert invoice.bill_to.name == @valid_attrs.bill_to.name
      assert invoice.payment_term == 14
      assert invoice.status == :pending
      assert invoice.project_description == "some project description"
    end

    test "create_invoice/1 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Invoices.create_invoice(user, @invalid_attrs)
    end

    test "update_invoice/2 with valid data updates the invoice", %{user: user} do
      invoice = invoice_fixture(user, @valid_attrs)

      assert {:ok, %Invoice{} = updated_invoice} = Invoices.update_invoice(invoice, @update_attrs)

      assert updated_invoice.bill_to.name == @update_attrs.bill_to.name
      refute updated_invoice.payment_term == invoice.payment_term
      assert updated_invoice.status == :paid
      assert updated_invoice.project_description == "some updated project description"
    end

    test "update_invoice/2 with invalid data returns error changeset", %{user: user} do
      invoice = invoice_fixture(user)
      assert {:error, %Ecto.Changeset{}} = Invoices.update_invoice(invoice, @invalid_attrs)
      assert invoice == Invoices.get_invoice!(invoice.id)
    end

    test "delete_invoice/1 deletes the invoice", %{user: user} do
      invoice = invoice_fixture(user)
      assert {:ok, %Invoice{}} = Invoices.delete_invoice(invoice)
      assert_raise Ecto.NoResultsError, fn -> Invoices.get_invoice!(invoice.id) end
    end

    test "change_invoice/1 returns a invoice changeset", %{user: user} do
      invoice = invoice_fixture(user)
      assert %Ecto.Changeset{} = Invoices.change_invoice(invoice)
    end
  end
end
