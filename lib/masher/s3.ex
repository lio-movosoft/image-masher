defmodule Masher.S3 do
  @moduledoc false

  def download(key) do
    config = s3_config()

    ExAws.S3.get_object(config[:bucket], key)
    |> ExAws.request(ex_aws_config(config))
    |> case do
      {:ok, %{body: body}} -> {:ok, body}
      {:error, reason} -> {:error, reason}
    end
  end

  def upload(key, binary, content_type) do
    config = s3_config()

    ExAws.S3.put_object(config[:bucket], key, binary, content_type: content_type)
    |> ExAws.request(ex_aws_config(config))
  end

  def delete(key) do
    config = s3_config()

    ExAws.S3.delete_object(config[:bucket], key)
    |> ExAws.request(ex_aws_config(config))
  end

  defp s3_config do
    Application.fetch_env!(:masher, :s3)
  end

  defp ex_aws_config(config) do
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
