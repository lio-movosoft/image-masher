import Config

config :masher, Masher.Repo,
  database: "masher_test#{System.get_env("MIX_TEST_PARTITION")}",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :masher, Oban, testing: :inline

config :logger, level: :warning
