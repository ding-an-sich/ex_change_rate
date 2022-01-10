# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

import Config

config :ex_change_rate,
  ecto_repos: [ExChangeRate.Repo],
  generators: [binary_id: true]

config :ex_change_rate, ExChangeRateWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: ExChangeRateWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: ExChangeRate.PubSub,
  live_view: [signing_salt: "1NQNCwkA"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :ex_change_rate, Oban,
  repo: ExChangeRate.Repo,
  queues: [requests: 10]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
