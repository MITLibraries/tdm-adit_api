defmodule AditApi.DocumentController do
  use AditApi.Web, :controller
  alias AditApi.Document
  alias AditApi.Miner

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
        case List.first(get_req_header(conn, "x-api-key")) do
          nil ->
            conn |> put_status(403) |> json(%{show: "denied"})
          key ->
            case Repo.get_by(Miner, api_key: key) do
              nil ->
                # should always be a miner for an API key
                conn |> put_status(500) |> json(%{show: "server error"})
              miner -> # rate limit check
                now = System.system_time(:seconds)
                case (now - miner.rl_window) do
                  diff when diff > 0 -> # new window - allow and reset
                    miner = Ecto.Changeset.change miner, rl_balance: miner.rate_limit - 1, rl_window: now + 60
                    Repo.update!(miner)
                    send_text(conn, key, doc)
                  _ -> # in existing window - verify status
                    case miner.rl_balance do
                      bal when bal > 0 ->
                        miner = Ecto.Changeset.change miner, rl_balance: miner.rl_balance - 1
                        Repo.update!(miner)
                        send_text(conn, key, doc)
                      _ -> # miner has no remaining balance
                        conn |> put_status(429)
                             |> put_resp_header("x-ratelimit-limit", Integer.to_string(miner.rate_limit))
                             |> put_resp_header("x-ratelimit-remaining", Integer.to_string(miner.rl_balance))
                             |> put_resp_header("x-ratelimit-reset", Integer.to_string(miner.rl_window))
                             |> json(%{show: "rate limit exceeded"})
                    end
                end
            end
        end
    end
  end

  defp send_text(conn, key, doc) do
    case Repo.get_by(Miner, api_key: key) do
      nil ->
        # should always be a miner for an API key
        conn |> put_status(500) |> json(%{show: "server error"})
      miner -> 
        format = case List.first(get_req_header(conn, "accept")) do
          "application/pdf" -> {".pdf", "application/pdf"}
          _ -> {".txt", "text/plain"}
        end
        doc_url = Application.get_env(:adit_api, :repo_svc) <>
                ":8080/fcrepo/rest/theses/" <> doc.ref <> "/" <> doc.ref <> elem(format, 0)
        body = HTTPoison.get!(doc_url).body
        conn |> put_resp_content_type(elem(format, 1))
             |> put_resp_header("x-ratelimit-limit", Integer.to_string(miner.rate_limit))
             |> put_resp_header("x-ratelimit-remaining", Integer.to_string(miner.rl_balance))
             |> put_resp_header("x-ratelimit-reset", Integer.to_string(miner.rl_window))
             |> send_resp(200, body)
    end
  end
end
