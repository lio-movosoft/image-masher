# Masher

Image processing service for Cookbook and Nota. Receives mash requests via direct Erlang messaging over hidden distribution connections, generates WebP variants using libvips, and uploads them back to S3.

## Prerequisites

libvips must be installed:

```bash
# macOS
brew install vips

# Amazon Linux 2023
dnf install vips vips-devel
```

## Setup

```bash
mix setup
```

## Development

Start both nodes with the same cookie:

```bash
# Terminal 1 - Masher
cd /Users/lio/projects/prj.image-masher/masher
iex --sname masher@localhost --cookie masher_secret -S mix

# Terminal 2 - Cookbook
MASHER_NODE=masher@localhost \
iex --sname cookbook@localhost --cookie masher_secret -S mix phx.server

# Terminal 3 - Nota
cd /Users/lio/projects/prj.pax-nota/nota
iex --sname nota@localhost --cookie masher_secret -S mix phx.server



```
