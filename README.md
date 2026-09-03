# ecosystem-infra

Shared local infrastructure for the `auth`, `accounts` and `promo` services.

| Service  | Image                | Host port | In-network host |
| -------- | -------------------- | --------- | --------------- |
| postgres | `postgres:16-alpine` | 5432      | `postgres:5432` |
| redis    | `redis:7-alpine`     | 6379      | `redis:6379`    |

Databases created automatically: `auth`, `accounts`, `promo`.

## Usage

```bash
make up      # start postgres + redis, wait for health, create databases
make down    # stop (data kept)
make clean   # stop and wipe volumes
make logs    # tail logs
make psql    # psql shell
```

`make up` copies `.env.example` to `.env` on first run. Edit `.env` to change
credentials, ports, or the list of databases (`POSTGRES_DATABASES`).

## Connecting a service

The compose file creates a docker network called `ecosystem`.
In each service's own compose file:

```yaml
services:
  auth:
    # ...
    environment:
      DATABASE_URL: postgres://postgres:postgres@postgres:5432/auth
      REDIS_URL: redis://redis:6379/0
    networks:
      - ecosystem

networks:
  ecosystem:
    external: true
```

Start `ecosystem-infra` first, then the service.

If you run a service outside docker, use `localhost:5432` / `localhost:6379`.

## Adding a database

Add the name to `POSTGRES_DATABASES` in `.env` and run `make databases` — the
script is idempotent and works against an existing volume.
