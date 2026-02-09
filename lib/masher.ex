defmodule Masher do
  @moduledoc """
  Image processing service.

  Subscribes to mash requests via Phoenix PubSub, processes images
  with Vix (libvips), and uploads WebP variants to S3.
  """
end
