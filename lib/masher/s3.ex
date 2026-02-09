defmodule Masher.S3 do
  @moduledoc false

  def download(bucket, key) do
    config = ex_aws_config()

    ExAws.S3.get_object(bucket, key)
    |> ExAws.request(config)
    |> case do
      {:ok, %{body: body}} -> {:ok, body}
      {:error, reason} -> {:error, reason}
    end
  end

  def upload(bucket, key, binary, content_type) do
    config = ex_aws_config()

    ExAws.S3.put_object(bucket, key, binary, content_type: content_type)
    |> ExAws.request(config)
  end

  def delete(bucket, key) do
    config = ex_aws_config()

    ExAws.S3.delete_object(bucket, key)
    |> ExAws.request(config)
  end

  defp ex_aws_config do
    config = Application.fetch_env!(:masher, :s3)

    [
      access_key_id: config[:access_key_id],
      secret_access_key: config[:secret_access_key],
      region: config[:region],
      scheme: config[:scheme],
      host: config[:host],
      port: config[:port],
      s3: [
        scheme: config[:scheme],
        host: config[:host],
        port: config[:port]
      ]
    ]
  end
end
