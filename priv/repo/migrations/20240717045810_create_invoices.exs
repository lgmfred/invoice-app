defmodule InvoiceApp.Repo.Migrations.CreateInvoices do
  use Ecto.Migration

  def change do
    create table(:invoices) do
      add :bill_from, :map, null: false
      add :bill_to, :map, null: false
      add :date, :date, null: false
      add :payment_term, :integer, null: false
      add :project_description, :string, null: false
      add :items, :map, null: false
      add :status, :string, null: false
      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:invoices, [:user_id])

    alter table(:users) do
      add :invoices, references(:invoices, on_delete: :delete_all)
    end
  end
end
