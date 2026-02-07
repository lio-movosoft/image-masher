import Config

config :masher, ecto_repos: [Masher.Repo]

config :masher, Masher.Repo,
  database: "masher_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :masher, Oban,
  repo: Masher.Repo,
  queues: [images: 2]

config :masher, :s3,
  bucket: "recipe-images",
  region: "us-east-1",
  host: "localhost",
  port: 9099,
  scheme: "http://",
  access_key_id: "root",
  secret_access_key: "root421-"

config :ex_aws,
  json_codec: Jason,
  http_client: ExAws.Request.Req

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]
