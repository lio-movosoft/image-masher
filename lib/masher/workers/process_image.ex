defmodule Masher.Workers.ProcessImage do
  @moduledoc false
  use Oban.Worker, queue: :images, max_attempts: 3

  alias Vix.Vips.{Image, Operation}

  require Logger

  @impl true
  def perform(%Oban.Job{args: %{"bucket" => bucket, "image_key" => key, "variants" => variants}}) do
    Logger.info("Processing image #{bucket}/#{key}")

    {:ok, binary} = Masher.S3.download(bucket, key)
    {:ok, image} = Image.new_from_buffer(binary)

    variant_keys =
      for [name, max_dim, quality] <- variants do
        variant_key = "#{name}/#{Path.rootname(key)}.webp"
        Logger.info("Generating variant #{variant_key} (#{max_dim}px, q#{quality})")

        {:ok, resized} = Operation.thumbnail_image(image, max_dim, size: :VIPS_SIZE_DOWN)
        {:ok, webp_binary} = Image.write_to_buffer(resized, ".webp[Q=#{quality}]")

        Masher.S3.upload(bucket, variant_key, webp_binary, "image/webp")

        {name, variant_key}
      end

    Masher.S3.delete(bucket, key)

    Phoenix.PubSub.broadcast(:masher_pubsub, "image_results",
      {:image_mashed, key, variant_keys})

    Logger.info("Completed processing #{bucket}/#{key}")

    :ok
  end
end
