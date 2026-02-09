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

  region = System.get_env("S3_REGION", "ap-southeast-1")

  config :masher, :s3,
    region: region,
    host: System.get_env("S3_HOST", "s3.#{region}.amazonaws.com"),
    port: System.get_env("S3_PORT", "443") |> String.to_integer(),
    scheme: System.get_env("S3_SCHEME", "https://"),
    access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
    secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY")
end
