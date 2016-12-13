use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :adit_api, AditApi.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :adit_api, AditApi.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: System.get_env("POSTGRES_PASSWORD"),
  database: "adit_api_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
