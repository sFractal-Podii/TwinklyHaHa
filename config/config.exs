# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :twinklyhaha,
  ecto_repos: [Twinklyhaha.Repo]

# Configure your database
config :twinklyhaha, Twinklyhaha.Repo,
  username: "postgres",
  password: "postgres",
  database: "twinklyhaha_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# Configures the endpoint
config :twinklyhaha, TwinklyhahaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "vzPk3tVAKciHWicK/U81Kf7JHWK2SSvT9vAEvja45hCATyUSaeqygJMagWBp/D4Y",
  render_errors: [view: TwinklyhahaWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Twinklyhaha.PubSub,
  live_view: [signing_salt: "VUUDL5Wt"]

# Configure esbuild version
config :esbuild,
  version: "0.14.0",
  default: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
