defmodule AditApi.Endpoint do
  use Phoenix.Endpoint, otp_app: :adit_api

  socket "/socket", AditApi.UserSocket

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/", from: :adit_api, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_adit_api_key",
    signing_salt: "NAa/cp49"

  plug CORSPlug,
    headers: ["Authorization", "Content-Type", "Accept", "Origin",
              "User-Agent", "DNT","Cache-Control", "X-Api-Key",
              "Keep-Alive", "X-Requested-With", "If-Modified-Since",
              "X-CSRF-Token"]

  plug AditApi.Router
end
