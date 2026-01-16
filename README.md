## Luanti Docker (multi-arch + Docker Hub push)

This repo builds a single **Luanti server** image (`luantiserver`) that supports both SQLite3 and PostgreSQL backends. The image defaults to PostgreSQL but can use SQLite3 by setting the `BACKEND` environment variable.

**Backend selection:**
- **PostgreSQL** (default): No configuration needed - just run the container
- **SQLite3**: Set `BACKEND=sqlite3` environment variable

Multi-platform builds and tagging are defined in `docker-bake.hcl`.
Images are published to Docker Hub as `tigersmile/luantiserver` and GHCR as `ghcr.io/johnnyjoy/luantiserver`.

### Local builds

Build a single-platform image and load it into your local Docker (fastest for dev):

```bash
cd /home/james/luanti-docker
docker buildx create --use --name luanti-builder 2>/dev/null || true
IMAGE="tigersmile/luantiserver" PLATFORMS="linux/amd64" docker buildx bake --load luantiserver
```

Build and push **multi-arch** manifests (requires Docker Hub login):

```bash
cd /home/james/luanti-docker
docker buildx create --use --name luanti-builder 2>/dev/null || true
IMAGE="tigersmile/luantiserver" PLATFORMS="linux/amd64,linux/arm64" docker buildx bake --push
```

### GitHub Actions → Docker Hub

Workflow: `.github/workflows/dockerhub.yml`.

Add these GitHub repository secrets:

- **DOCKERHUB_IMAGE**: Docker Hub repo, e.g. `tigersmile/luantiserver`.
- **DOCKERHUB_USERNAME**: Docker Hub username.
- **DOCKERHUB_TOKEN**: Docker Hub access token (write permissions).

Triggers:

- **Tag push**: `v*` (e.g. `v1.0.0`).
- **Manual**: workflow dispatch (lets you override platforms).

### Tag scheme

The unified image is published with these tags:

- **Latest** (PostgreSQL default): `tigersmile/luantiserver:latest`
- **Versioned**: `tigersmile/luantiserver:${IMAGE_VERSION}`

### Backend selection

The image supports both SQLite3 and PostgreSQL backends. Choose at runtime:

**PostgreSQL (default):**
```bash
docker run -d tigersmile/luantiserver:latest
# Or with PostgreSQL connection details:
docker run -d \
  -e BACKEND=postgresql \
  -e PG_HOST=db \
  -e PG_DB=luanti \
  tigersmile/luantiserver:latest
```

**SQLite3:**
```bash
docker run -d \
  -e BACKEND=sqlite3 \
  -v ./world:/world \
  tigersmile/luantiserver:latest
```


