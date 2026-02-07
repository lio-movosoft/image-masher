# Masher

Image processing service for Cookbook. Receives mash requests via Phoenix PubSub, generates WebP variants using libvips, and uploads them back to S3.

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
iex --sname masher --cookie cookbook_secret -S mix

# Terminal 2 - Cookbook
cd /Users/lio/projects/prj.cookbook/cookbook
iex --sname cookbook --cookie cookbook_secret -S mix phx.server
```
