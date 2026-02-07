import Config

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  config :masher, Masher.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "5")

  if System.get_env("S3_BUCKET") do
    config :masher, :s3,
      bucket: System.get_env("S3_BUCKET"),
      region: System.get_env("S3_REGION", "us-east-1"),
      host: System.get_env("S3_HOST"),
      port: System.get_env("S3_PORT") |> String.to_integer(),
      scheme: System.get_env("S3_SCHEME", "https://"),
      access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
      secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY")
  end
end
