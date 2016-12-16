defmodule AditApi.CollectionController do
  use AditApi.Web, :controller

  @doc """
    Currently a stub/hard-coded, since there is only one collection
    in the service. Will be DB-backed when there are more
  """
  def index(conn, _params), do: render conn, "index.json"

  def show(conn, %{"id" => id}), do: render conn, "show.json", id: id

  def schema(conn, %{"id" => id}), do: render conn, "schema.json", id: id

  def search(conn, %{"id" => id, "query" => query}) do
    # construct a query to indexing service from user query
    # setting size to 0 to suppress all but hit count in the response
    index_query = Poison.encode!(%{
      query: query,
      size: 0
    })
    index_url = Application.get_env(:adit_api, :index_svc) <> ":9200/theses/_search"
    resp = Poison.decode!(HTTPoison.post!(index_url, index_query).body)
    render conn, "search.json", id: id, hits: resp["hits"]["total"]
  end

  def watch(conn, %{"id" => id}) do
    # TB implemented
  end
end
