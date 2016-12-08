defmodule AditApi.CollectionController do
  use AditApi.Web, :controller

  @doc """
    Currently a stub/hard-coded, since there is only one collection
    in the service. Will be DB-backed when there are more
  """
  def index(conn, _params), do: render conn, "index.json"

  def show(conn, %{"id" => id}), do: render conn, "show.json", id: id

  def schema(conn, %{"id" => id}), do: render conn, "schema.json", id: id

  def search(conn, %{"id" => id}) do
    # TB implemented
    render conn, "search.json", id: id
  end

  def watch(conn, %{"id" => id}) do
    # TB implemented
  end
end
