defmodule InvoiceApp.Repo.Migrations.UpdateUsersTable do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :full_name, :string
      add :username, :string
      add :avatar_url, :string
      add :business_address, :map
    end

    create unique_index(:users, [:username])
  end
end