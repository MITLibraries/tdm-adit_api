defmodule AditApi.DocumentController do
  use AditApi.Web, :controller
  alias AditApi.Document

  def show(conn, %{"id" => id}) do
    case Repo.get(Document, id) do
      nil ->
        conn |> put_status(404) |> json(%{show: "not found"})
      doc ->
        doc_url = Application.get_env(:adit_api, :repo_svc) <>
                 ":8080/fcrepo/rest/theses/" <> doc.ref
        doc_info = Poison.decode!(HTTPoison.get!(doc_url, %{"Accept" => "application/ld+json"}).body)
        render conn, "show.json", doc: doc, info: doc_info
    end
  end

  def text(conn, %{"id" => id}) do
    case Repo.get(Document, id) do
      nil ->
        conn |> put_status(404) |> json(%{text: "not found"})
      doc ->
        doc_url = Application.get_env(:adit_api, :repo_svc) <>
                 ":8080/fcrepo/rest/theses/" <> doc.ref <> "/" <> doc.ref <> ".txt"
        body = HTTPoison.get!(doc_url).body
        conn |> put_resp_content_type("text/plain") |> send_resp(200, body)
    end
  end
end
