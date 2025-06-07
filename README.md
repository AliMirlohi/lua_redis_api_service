# lua_redis_api_service

A lightweight, high-performance API service built on **NGINX** with embedded **Lua** scripting for interaction with a **Redis** backend. This repository enables rapid development of scalable key-value API endpoints, rate limiting, and more, all orchestrated via Docker Compose for seamless local deployment.

## Features

- **NGINX + Lua**: Use OpenResty/NGINX with custom Lua code for flexible and fast API logic.
- **Redis Integration**: Read and write key-value data directly to a Redis cluster.
- **Rate Limiting**: Out-of-the-box IP-based rate limiting using Redis.
- **Hashing Utilities**: Built-in FNV-1a hash implementation for sharding or consistency.
- **Docker Compose**: Easy local development and deployment.

## Directory Structure

```
.
├── docker-compose.yml      # Multi-container orchestration (NGINX, Redis, etc.)
└── nginx/
    ├── nginx.conf          # NGINX configuration with Lua hooks
    └── lua/
        ├── fnv1a.lua           # FNV-1a hash function
        ├── get.lua             # Logic for GET API endpoint
        ├── set.lua             # Logic for SET API endpoint
        ├── redis_cluster.lua   # Redis cluster client logic
        ├── ratelimit.lua       # IP-based rate limiting
```

## Getting Started

### Prerequisites

- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/)

### Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/AliMirlohi/lua_redis_api_service.git
   cd lua_redis_api_service
   ```

2. **Start services:**
   ```bash
   docker-compose up
   ```
   This will spin up NGINX (with Lua), and Redis.

3. **API Endpoints:**
   - `GET /get?key=<your_key>`: Retrieve a value from Redis.
   - `POST /set`: Set a value in Redis. (Payload: `{ "key": "...", "value": "..." }`)
   - Rate-limited by IP address.

_Note: Endpoints and payloads may be customizable in the Lua scripts. See `nginx/lua/` for logic._

## Configuration

- **nginx/nginx.conf**: Main config for HTTP server, Lua hooks, and routing.
- **nginx/lua/**: All business logic for endpoints, redis cluster operation, and rate limits.
- **docker-compose.yml**: Edit to change exposed ports, Redis version, or add persistence.

## Example Usage

**GET a value:**
```bash
curl "http://localhost:8080/get?key=mykey"
```

**SET a value:**
```bash
curl "http://localhost:8080/set?key=mykey&&value=myvalue"
```

## Customization

- Add new endpoints by creating Lua scripts in `nginx/lua/` and referencing them in `nginx.conf`.
- Adjust rate limiting in `ratelimit.lua` and its hook in `nginx.conf`.
- Change Redis cluster logic in `redis_cluster.lua` for advanced deployments.



## Author

Developed by [Ali Mirlohi](https://github.com/AliMirlohi).

---

