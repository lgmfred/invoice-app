defmodule InvoiceApp.Repo.Migrations.NotificationPreferences do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :email_preferences, :map, null: false
    end
  end
end
