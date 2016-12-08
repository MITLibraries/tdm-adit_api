# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :adit_api,
  ecto_repos: [AditApi.Repo]

# Configures the endpoint
config :adit_api, AditApi.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "0II/WHxDXaub/U6/g2tiPX/EZNXY01XL9LFshpzxiMfEJ7aCnHRehMPbWYU2iAuC",
  render_errors: [view: AditApi.ErrorView, accepts: ~w(json)],
  pubsub: [name: AditApi.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
