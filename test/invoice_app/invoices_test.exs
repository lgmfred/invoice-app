defmodule InvoiceApp.InvoicesTest do
  use InvoiceApp.DataCase

  alias InvoiceApp.Invoices

  describe "invoices" do
    alias InvoiceApp.Invoices.Invoice

    import InvoiceApp.InvoicesFixtures

    @invalid_attrs %{
      bill_from: nil,
      bill_to: nil,
      items: nil,
      payment_term: nil,
      project_description: nil
    }

    test "list_invoices/0 returns all invoices" do
      invoice = invoice_fixture()
      assert Invoices.list_invoices() == [invoice]
    end

    test "get_invoice!/1 returns the invoice with given id" do
      invoice = invoice_fixture()
      assert Invoices.get_invoice!(invoice.id) == invoice
    end

    test "create_invoice/1 with valid data creates a invoice" do
      valid_attrs = %{
        bill_from: ~D[2024-07-16],
        bill_to: ~D[2024-07-16],
        items: %{},
        payment_term: 42,
        project_description: "some project_description"
      }

      assert {:ok, %Invoice{} = invoice} = Invoices.create_invoice(valid_attrs)
      assert invoice.bill_from == ~D[2024-07-16]
      assert invoice.bill_to == ~D[2024-07-16]
      assert invoice.items == %{}
      assert invoice.payment_term == 42
      assert invoice.project_description == "some project_description"
    end

    test "create_invoice/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Invoices.create_invoice(@invalid_attrs)
    end

    test "update_invoice/2 with valid data updates the invoice" do
      invoice = invoice_fixture()

      update_attrs = %{
        bill_from: ~D[2024-07-17],
        bill_to: ~D[2024-07-17],
        items: %{},
        payment_term: 43,
        project_description: "some updated project_description"
      }

      assert {:ok, %Invoice{} = invoice} = Invoices.update_invoice(invoice, update_attrs)
      assert invoice.bill_from == ~D[2024-07-17]
      assert invoice.bill_to == ~D[2024-07-17]
      assert invoice.items == %{}
      assert invoice.payment_term == 43
      assert invoice.project_description == "some updated project_description"
    end

    test "update_invoice/2 with invalid data returns error changeset" do
      invoice = invoice_fixture()
      assert {:error, %Ecto.Changeset{}} = Invoices.update_invoice(invoice, @invalid_attrs)
      assert invoice == Invoices.get_invoice!(invoice.id)
    end

    test "delete_invoice/1 deletes the invoice" do
      invoice = invoice_fixture()
      assert {:ok, %Invoice{}} = Invoices.delete_invoice(invoice)
      assert_raise Ecto.NoResultsError, fn -> Invoices.get_invoice!(invoice.id) end
    end

    test "change_invoice/1 returns a invoice changeset" do
      invoice = invoice_fixture()
      assert %Ecto.Changeset{} = Invoices.change_invoice(invoice)
    end
  end
end
