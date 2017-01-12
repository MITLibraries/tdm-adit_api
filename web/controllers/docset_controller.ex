defmodule AditApi.DocsetController do
  use AditApi.Web, :controller
  alias AditApi.Docset

  def index(conn, _params) do
    # this will be replaced by a lookup to the user from the API key
    key = List.first(get_req_header(conn, "x-api-key"))
    docsets = if key, do: Repo.all(from d in Docset, where: d.owner == ^key), else: []
    render conn, "index.json", docsets: docsets
  end

  def show(conn, %{"id" => id}) do
    case Repo.get(Docset, id) do
      nil ->
        conn |> put_status(404) |> json(%{show: "not found"})
      docset ->
        key = List.first(get_req_header(conn, "x-api-key"))
        if (docset.owner == key) do
          render conn, "show.json", docset: docset
        else
          conn |> put_status(403)|> json(%{show: "denied"})
        end
    end
  end

  def create(conn, %{"query" => query}) do
    key = List.first(get_req_header(conn, "x-api-key"))
    if key do
      # construct changeset from query and api key
      {:ok, qry_str} = Poison.encode(query, [])
      docset_params = %{
        name: "extract-from-query",
        generator: to_string(qry_str),
        owner: key
      }
      changeset = Docset.changeset(%Docset{}, docset_params)
      # now perform the index query to get the list of documents
      # setting _source to only retrieve the uri field for efficiency
      index_query = Poison.encode!(%{
        query: query,
        _source: ["uri"]
      })
      index_url = Application.get_env(:adit_api, :index_svc) <> ":9200/theses/_search"
      resp = Poison.decode!(HTTPoison.post!(index_url, index_query).body)
      docRefs = resp["hits"]["hits"]
      |> Enum.map(fn h -> h["_source"]["uri"] end)
      |> Enum.map(fn u -> hd(Enum.reverse(String.split(u, "/"))) end)

      case Repo.insert(changeset) do
        {:ok, docset} ->
          # add in the docRefs
          Enum.map(docRefs, fn x -> Repo.insert!(build_assoc(docset, :documents, %{ref: x})) end)
          conn |> put_status(201)
          |> put_resp_header("Location", "/docsets/#{docset.id}")
          |> json(%{create: "success"})
        {:error, _changeset} ->
          conn |> put_status(400) |> json(%{create: "fail"})
      end
    else
      conn |> put_status(403) |> json(%{create: "denied"})
    end
  end

  def update(conn, %{"id" => id, "docset" => docset_params}) do
    case Repo.get(Docset, id) do
      nil ->
        conn |> put_status(404) |> json(%{update: "not found"})
      docset ->
        key = List.first(get_req_header(conn, "x-api-key"))
        if (docset.owner == key) do
          changeset = Docset.changeset(docset, docset_params)
          case Repo.update(changeset) do
            {:ok, _docset} ->
              json conn, %{update: "success"}
            {:error, _changeset} ->
              conn |> put_status(400) |> json(%{update: "error"})
          end
        else
          conn |> put_status(403)|> json(%{update: "denied"})
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    case Repo.get(Docset, id) do
      nil ->
        conn |> put_status(404) |> json(%{delete: "not found"})
      docset ->
        key = List.first(get_req_header(conn, "x-api-key"))
        if (docset.owner == key) do
          Repo.delete!(docset)
          json conn, %{delete: "ok"}
        else
          conn |> put_status(403) |> json(%{delete: "denied"})
        end
    end
  end

  def list(conn, %{"id" => id}) do
    case Repo.get(Docset, id) do
      nil ->
        conn |> put_status(404) |> json(%{list: "not found"})
      docset ->
        key = List.first(get_req_header(conn, "x-api-key"))
        if (docset.owner == key) do
          # paginate access to member list - TODO (using a query)
          ldocset = Repo.preload(docset, :documents)
          render conn, "list.json", docset: ldocset
        else
          conn |> put_status(403) |> json(%{list: "denied"})
        end
    end
  end

  def catalog(conn, %{"id" => id}) do
    case Repo.get(Docset, id) do
      nil ->
        conn |> put_status(404) |> json(%{catalog: "not found"})
      docset ->
        key = List.first(get_req_header(conn, "x-api-key"))
        if (docset.owner == key) do
          # build a catalog from member list - TODO (using a query)
          ldocset = Repo.preload(docset, :documents)
          render conn, "catalog.json", docset: ldocset
        else
          conn |> put_status(403) |> json(%{catalog: "denied"})
        end
    end
  end

  def dump(conn, params) do
    id = Dict.get(params, "id")
    formats = String.split(Dict.get(params, "fmts", "txt"), ",")
    case Repo.get(Docset, id) do
      nil ->
        conn |> put_status(404) |> json(%{dump: "not found"})
      docset ->
        key = List.first(get_req_header(conn, "x-api-key"))
        if (docset.owner == key) do
          # build a dump file from member list - TODO (using a query)
          ldocset = Repo.preload(docset, :documents)
          # very crude first pass: the Erlang zip library
          # requires file-to-file copy, not stream-to-file. Thus,
          # we require not quite 2X scratch disk space
          tmp_dir = System.tmp_dir
          doc_files = Enum.concat(Enum.map(formats, fn fmt -> write_fmt(ldocset.documents, fmt, tmp_dir) end))
          arch_path = Path.absname(ldocset.name, tmp_dir)
          :zip.zip(to_charlist(arch_path), doc_files, cwd: tmp_dir) # Erlang!
          # clean up the loose files
          Enum.map(doc_files, fn doc -> File.rm(Path.absname(doc, tmp_dir)) end)
          conn |> put_resp_content_type("application/zip") |> send_file(200, arch_path)
        else
          conn |> put_status(403) |> json(%{dump: "denied"})
        end
    end
  end

  defp write_fmt(documents, format, tmp_dir) do
    case format do
      "meta" -> Enum.map(documents, fn doc -> write_meta(doc, tmp_dir) end)
      _ -> Enum.map(documents, fn doc -> write_doc(doc, format, tmp_dir) end)
    end
  end

  defp write_meta(doc, tmp_dir) do
    base_name = doc.ref <> ".json"
    doc_file = Path.absname(base_name, tmp_dir)
    doc_url = Application.get_env(:adit_api, :repo_svc) <>
       ":8080/fcrepo/rest/theses/" <> doc.ref
    body = HTTPoison.get!(doc_url, %{"Accept" => "application/ld+json"}).body
    {:ok, file} = File.open(doc_file, [:write])
    IO.binwrite(file, body)
    File.close(file)
    to_charlist(Path.basename(doc_file))
  end

  defp write_doc(doc, format, tmp_dir) do
    base_name = doc.ref <> "." <> format
    doc_file = Path.absname(base_name, tmp_dir)
    doc_url = Application.get_env(:adit_api, :repo_svc) <>
       ":8080/fcrepo/rest/theses/" <> doc.ref <> "/" <> doc.ref <> "." <> format
    body = HTTPoison.get!(doc_url).body
    {:ok, file} = File.open(doc_file, [:write])
    IO.binwrite(file, body)
    File.close(file)
    to_charlist(Path.basename(doc_file))
  end
end
