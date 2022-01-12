import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :ex_change_rate, ExChangeRate.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "ex_change_rate_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ex_change_rate, ExChangeRateWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "oDuYuwrLt1UUh1fH0grgw0SS50KwqgeivWfKiVRxirSl/T/utjtvzpkkFu08XOD+",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :tesla, adapter: TeslaMock

config :ex_change_rate, Oban, queues: false, plugins: false

config :ex_change_rate,
       ExChangeRate.Clients.ExchangeratesAPI,
       api_key: "123456"
