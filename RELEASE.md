Here's how to set it up for production with HAProxy in front:

Build releases
bash
# Cookbook
cd /path/to/cookbook
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix release

# Masher
cd /path/to/masher
MIX_ENV=prod mix release
Start them
The key is both nodes need the same Erlang cookie and resolvable node names. On a single host:

```bash
# Masher (no web server, just the worker)
DATABASE_URL="ecto://user:pass@localhost/masher_prod" \
S3_BUCKET="recipe-images" \
S3_HOST="your-s3-host" \
S3_PORT="443" \
S3_SCHEME="https://" \
AWS_ACCESS_KEY_ID="..." \
AWS_SECRET_ACCESS_KEY="..." \
RELEASE_NODE="masher@127.0.0.1" \
RELEASE_COOKIE="your_secret_cookie" \
  _build/prod/rel/masher/bin/masher start
```

# Cookbook (web server behind HAProxy)

```bash
PHX_SERVER=true \
PORT=4000 \
PHX_HOST="yourcookbook.com" \
SECRET_KEY_BASE="$(mix phx.gen.secret)" \
DATABASE_URL="ecto://user:pass@localhost/cookbook_prod" \
S3_BUCKET="recipe-images" \
S3_HOST="your-s3-host" \
S3_PORT="443" \
S3_SCHEME="https://" \
AWS_ACCESS_KEY_ID="..." \
AWS_SECRET_ACCESS_KEY="..." \
MASHER_NODE="masher@127.0.0.1" \
RELEASE_NODE="cookbook@127.0.0.1" \
RELEASE_COOKIE="your_secret_cookie" \
  _build/prod/rel/cookbook/bin/cookbook start
```
  
### Key points

RELEASE_COOKIE must be identical on both — this is how Erlang nodes authenticate
RELEASE_NODE — use @127.0.0.1 (or the actual IP) if on the same host; use real IPs if on separate hosts
PHX_SERVER=true — only needed for Cookbook (Masher has no web server)
HAProxy just proxies to 127.0.0.1:4000 — Cookbook handles HTTP only, HAProxy handles TLS
If on separate hosts, the nodes need network connectivity on the Erlang distribution port (default 4369 for EPMD + ephemeral ports). You can lock the port range with RELEASE_DISTRIBUTION=name and inet_dist_listen_min/max in rel/env.sh.eex
Order doesn't matter — start either first.
