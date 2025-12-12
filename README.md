## Luanti Docker (multi-arch + Docker Hub push)

This repo builds **Luanti server** images with multiple backend variants:

- **sqlite3**.
- **leveldb**.
- **postgresql**.
- **redis**.

Multi-platform builds and tagging are defined in `docker-bake.hcl`.
Images are published to a single Docker Hub repo (e.g. `tigersmile/luanti`) with tags like `:<backend>-<version>`.

### Local builds

Build a single-platform image and load it into your local Docker (fastest for dev):

```bash
cd /home/james/luanti-docker
docker buildx create --use --name luanti-builder 2>/dev/null || true
IMAGE="tigersmile/luanti" PLATFORMS="linux/amd64" docker buildx bake --load sqlite
```

Build and push **multi-arch** manifests (requires Docker Hub login):

```bash
cd /home/james/luanti-docker
docker buildx create --use --name luanti-builder 2>/dev/null || true
IMAGE="tigersmile/luanti" PLATFORMS="linux/amd64,linux/arm64" docker buildx bake --push
```

### GitHub Actions → Docker Hub

Workflow: `.github/workflows/dockerhub.yml`.

Add these GitHub repository secrets:

- **DOCKERHUB_IMAGE**: Docker Hub repo, e.g. `tigersmile/luanti`.
- **DOCKERHUB_USERNAME**: Docker Hub username.
- **DOCKERHUB_TOKEN**: Docker Hub access token (write permissions).

Triggers:

- **Tag push**: `v*` (e.g. `v1.0.0`).
- **Manual**: workflow dispatch (lets you override platforms).

### Tag scheme

For each backend variant, bake publishes:

- **Latest** (sqlite3 only): `tigersmile/luanti:latest`.
- **Versioned**:
  - `tigersmile/luanti:sqlite3-${LUANTI_VERSION}`
  - `tigersmile/luanti:postgresql-${LUANTI_VERSION}`
  - `tigersmile/luanti:leveldb-${LUANTI_VERSION}`
  - `tigersmile/luanti:redis-${LUANTI_VERSION}`


