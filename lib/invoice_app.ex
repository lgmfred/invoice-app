defmodule InvoiceApp do
  @moduledoc """
  InvoiceApp keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def public_uploads_path do
    Application.get_env(:invoice_app, :public_uploads_path, default_public_uploads_path())
  end

  defp default_public_uploads_path do
    "/uploads"
  end

  def uploads_dir do
    Application.get_env(:invoice_app, :uploads_dir, default_uploads_dir())
  end

  defp default_uploads_dir do
    Path.join([:code.priv_dir(:invoice_app), "static", "uploads"])
  end
end
