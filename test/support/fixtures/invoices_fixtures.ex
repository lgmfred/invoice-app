defmodule InvoiceApp.InvoicesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `InvoiceApp.Invoices` context.
  """

  @doc """
  Generate a invoice.
  """
  def invoice_fixture(attrs \\ %{}) do
    {:ok, invoice} =
      attrs
      |> Enum.into(%{
        bill_from: ~D[2024-07-16],
        bill_to: ~D[2024-07-16],
        items: %{},
        payment_term: 42,
        project_description: "some project_description"
      })
      |> InvoiceApp.Invoices.create_invoice()

    invoice
  end
end
