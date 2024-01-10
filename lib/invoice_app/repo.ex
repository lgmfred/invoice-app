defmodule InvoiceApp.Repo do
  use Ecto.Repo,
    otp_app: :invoice_app,
    adapter: Ecto.Adapters.Postgres
end
