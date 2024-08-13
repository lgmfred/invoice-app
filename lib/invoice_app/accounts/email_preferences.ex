defmodule InvoiceApp.Accounts.EmailPreferences do
  @moduledoc """
  User email notification preferences schema
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias InvoiceApp.Accounts.EmailPreferences

  embedded_schema do
    field :newsletter, :boolean, default: true
    field :sign_in, :boolean, default: true
    field :payment_reminder, :boolean, default: true
  end

  @doc """
  Email notifications preferences changeset.
  """
  def changeset(%EmailPreferences{} = preferences, attrs \\ %{}) do
    required_fields = [:newsletter, :sign_in, :payment_reminder]

    preferences
    |> cast(attrs, required_fields)
    |> validate_required(required_fields)
  end
end
