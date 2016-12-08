defmodule AditApi.DocumentController do
  use AditApi.Web, :controller
  alias AditApi.Document

  def show(conn, %{"id" => id}) do
    case Repo.get(Document, id) do
      nil ->
        conn |> put_status(404) |> json(%{show: "not found"})
      doc ->
        # TBD - look up in F4 from ref
        render conn, "show.json", doc: doc
    end
  end

  def text(conn, %{"id" => id}) do
    case Repo.get(Document, id) do
      nil ->
        conn |> put_status(404) |> json(%{text: "not found"})
      doc ->
        # TBD - look up in F4 from ref, get text info
        json conn, %{ref: doc.ref}
    end
  end
end
