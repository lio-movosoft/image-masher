defmodule Masher.Listener do
  @moduledoc """
  Listens for image processing requests from client apps (Cookbook, Nota, etc.).

  Clients connect to this node using hidden Erlang distribution
  (`hidden_connect_node/1`) and send mash requests directly:

      send({Masher.Listener, masher_node}, {:mash_image, bucket, image_key, variants})

  Masher enqueues an Oban job and, upon completion, sends the result directly to
  `:masher_result_listener` on each connected hidden node.
  """
  use GenServer

  alias Masher.Workers.ProcessImage

  require Logger

  def start_link(_), do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  @impl true
  def init(_), do: {:ok, nil}

  @impl true
  def handle_info({:mash_image, bucket, image_key, variants}, state) do
    Logger.info("Received mash request for #{bucket}/#{image_key}")

    variants = Enum.map(variants, &Tuple.to_list/1)

    case %{"bucket" => bucket, "image_key" => image_key, "variants" => variants}
         |> ProcessImage.new()
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
