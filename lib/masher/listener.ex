defmodule Masher.Listener do
  @moduledoc false
  use GenServer

  require Logger

  def start_link(_), do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  @impl true
  def init(_) do
    Phoenix.PubSub.subscribe(:masher_pubsub, "mash_requests")
    {:ok, nil}
  end

  @impl true
  def handle_info({:mash_image, image_key, variants}, state) do
    Logger.info("Received mash request for #{image_key}")

    variants = Enum.map(variants, &Tuple.to_list/1)

    case %{"image_key" => image_key, "variants" => variants}
         |> Masher.Workers.ProcessImage.new()
         |> Oban.insert() do
      {:ok, job} ->
        Logger.info("Enqueued job #{job.id} for #{image_key}")

      {:error, reason} ->
        Logger.error("Failed to enqueue job for #{image_key}: #{inspect(reason)}")
    end

    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.warning("Unexpected message: #{inspect(msg)}")
    {:noreply, state}
  end
end
