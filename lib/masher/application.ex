defmodule Masher.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Masher.Repo,
      {Phoenix.PubSub, name: :masher_pubsub},
      {Oban, Application.fetch_env!(:masher, Oban)},
      Masher.Listener
    ]

    opts = [strategy: :one_for_one, name: Masher.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
