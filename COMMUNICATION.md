# Masher Cross-Node Communication

## Node setup

Each client app starts with `--sname` and a shared `--cookie masher_secret`. A
`MasherConnector` GenServer calls `hidden_connect_node(:masher@localhost)` — a
hidden Erlang distribution connection that gives full RPC and direct messaging
without triggering `global`'s mesh algorithm between client apps.

## Why not Phoenix PubSub cross-node?

`Phoenix.PubSub` uses `:pg` for cross-node group membership. `:pg`'s internal
`monitor_nodes` only watches **visible** connections. Hidden connections are
invisible to `:pg`, so the two PubSub adapters never discover each other —
broadcasts silently drop. Direct Erlang `send/2` has no such restriction and
works fine over hidden connections.

## Request path — Client → Masher

```
image_upload.ex
  send({Masher.Listener, masher_node}, {:mash_image, bucket, key, variants})
    → Masher.Listener.handle_info (GenServer)
      → Oban.insert(ProcessImage job)
```

## Result path — Masher → Client

```
Masher.Workers.ProcessImage.perform
  → download, resize, upload WebP variants to S3
  → for node <- Node.list(:hidden) do
      send({:masher_result_listener, node}, {:image_mashed, key, variant_keys})
    end
    → Cookbook.ImageListener  (registered as :masher_result_listener)
      → updates recipe_image.processing_status = :completed in DB
      → Phoenix.PubSub.broadcast(Cookbook.PubSub, "image:KEY", :image_processed)
        → subscribed LiveViews refresh their image list
```

## The `:masher_result_listener` convention

Every client app (cookbook, nota, any future app) registers its image-result
GenServer under the atom `:masher_result_listener`:

```elixir
def start_link(_), do: GenServer.start_link(__MODULE__, nil, name: :masher_result_listener)
```

Masher sends to that name on every hidden node — it never needs to know whether
the client is cookbook, nota, or something else.
