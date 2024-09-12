defmodule InvoiceApp.Invoices do
  @moduledoc """
  The Invoices context.
  """

  import Ecto.Query, warn: false

  alias InvoiceApp.Accounts.User
  alias InvoiceApp.Invoices.Invoice
  alias InvoiceApp.Repo

  @doc """
  Returns the list of invoices.

  ## Examples

      iex> list_invoices()
      [%Invoice{}, ...]

  """
  def list_invoices do
    Invoice
    |> Repo.all()
    |> Repo.preload(:user)
  end

  @doc """
  Returns the list of invoices matching the given filter.

  ## Examples filter:

  %{user_id: 1, status: "paid"}
  """
  def list_invoices(filter) when is_map(filter) do
    from(Invoice)
    |> filter_by_user_id(filter)
    |> filter_by_status(filter)
    |> Repo.all()
    |> Repo.preload(:user)
  end

  defp filter_by_user_id(query, %{user_id: ""}), do: query

  defp filter_by_user_id(query, %{user_id: user_id}) do
    where(query, user_id: ^user_id)
  end

  defp filter_by_status(query, %{status: ""}), do: query

  defp filter_by_status(query, %{status: status}) do
    where(query, status: ^status)
  end

  @doc """
  Gets a single invoice.

  Raises `Ecto.NoResultsError` if the Invoice does not exist.

  ## Examples

      iex> get_invoice!(123)
      %Invoice{}

      iex> get_invoice!(456)
      ** (Ecto.NoResultsError)

  """
  def get_invoice!(id) do
    Invoice
    |> where([i], i.id == ^id)
    |> preload(:user)
    |> Repo.one!()
  end

  @doc """
  Creates a invoice for the give user.

  ## Examples

      iex> create_invoice(%User{} = user, %{field: value})
      {:ok, %Invoice{}}

      iex> create_invoice(%User{} = user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_invoice(%User{} = user, attrs \\ %{}) do
    %Invoice{}
    |> Invoice.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  @doc """
  Updates a invoice.

  ## Examples

      iex> update_invoice(invoice, %{field: new_value})
      {:ok, %Invoice{}}

      iex> update_invoice(invoice, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_invoice(%Invoice{} = invoice, attrs) do
    invoice
    |> Invoice.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a invoice.

  ## Examples

      iex> delete_invoice(invoice)
      {:ok, %Invoice{}}

      iex> delete_invoice(invoice)
      {:error, %Ecto.Changeset{}}

  """
  def delete_invoice(%Invoice{} = invoice) do
    Repo.delete(invoice)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking invoice changes.

  ## Examples

      iex> change_invoice(invoice)
      %Ecto.Changeset{data: %Invoice{}}

  """
  def change_invoice(%Invoice{} = invoice, attrs \\ %{}) do
    Invoice.changeset(invoice, attrs)
  end
end
