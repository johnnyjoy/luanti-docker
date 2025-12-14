variable "LUANTI_VERSION" {
  # Upstream Luanti version (must match luanti-org/luanti tag exactly)
  default = "5.14.0"
}

variable "IMAGE_VERSION" {
  # Docker image version (can include your build suffix, e.g. 5.14.0-6)
  default = "5.14.0"
}

# All platforms you want to build for (mirrors nginx-micro)
variable "ALL_PLATFORMS" {
  default = [
    "linux/386",
    "linux/amd64",
    "linux/arm/v6",
    "linux/arm/v7",
    "linux/arm64",
    "linux/ppc64le",
    "linux/s390x",
  ]
}

# Metadata for OCI labels
variable "IMAGE_SOURCE" {
  default = ""
}

variable "VCS_REF" {
  default = ""
}

group "default" {
  targets = [
    "luanti-sqlite",
    "luanti-postgres",
  ]
}

group "extras" {
  targets = [
    "luanti-leveldb",
    "luanti-redis",
  ]
}

target "luanti-sqlite" {
  context    = "."
  dockerfile = "Dockerfile"
  target     = "luanti-sqlite"

  tags = [
    # Docker Hub
    "tigersmile/luanti:${IMAGE_VERSION}-sqlite3",
    "tigersmile/luanti:sqlite3",
    "tigersmile/luanti:latest",

    # GHCR
    "ghcr.io/johnnyjoy/luanti:${IMAGE_VERSION}-sqlite3",
    "ghcr.io/johnnyjoy/luanti:sqlite3",
    "ghcr.io/johnnyjoy/luanti:latest",
  ]

  cache-from = [
    {
      type = "registry"
      ref  = "tigersmile/luanti-cache"
    }
  ]
  cache-to = [
    {
      type = "registry"
      ref  = "tigersmile/luanti-cache"
      mode = "max"
    }
  ]

  args = {
    "LUANTI_VERSION" = "${LUANTI_VERSION}"
    "IMAGE_SOURCE"   = "${IMAGE_SOURCE}"
    "VCS_REF"        = "${VCS_REF}"
  }

  platforms = "${ALL_PLATFORMS}"
}

target "luanti-leveldb" {
  context    = "."
  dockerfile = "Dockerfile"
  target     = "luanti-leveldb"

  tags = [
    # Docker Hub
    "tigersmile/luanti:${IMAGE_VERSION}-leveldb",
    "tigersmile/luanti:leveldb",

    # GHCR
    "ghcr.io/johnnyjoy/luanti:${IMAGE_VERSION}-leveldb",
    "ghcr.io/johnnyjoy/luanti:leveldb",
  ]

  cache-from = [
    {
      type = "registry"
      ref  = "tigersmile/luanti-cache"
    }
  ]
  cache-to = [
    {
      type = "registry"
      ref  = "tigersmile/luanti-cache"
      mode = "max"
    }
  ]

  args = {
    "LUANTI_VERSION" = "${LUANTI_VERSION}"
    "IMAGE_SOURCE"   = "${IMAGE_SOURCE}"
    "VCS_REF"        = "${VCS_REF}"
  }

  platforms = "${ALL_PLATFORMS}"
}

target "luanti-postgres" {
  context    = "."
  dockerfile = "Dockerfile"
  target     = "luanti-postgres"

  tags = [
    # Docker Hub
    "tigersmile/luanti:${IMAGE_VERSION}-postgresql",
    "tigersmile/luanti:postgresql",

    # GHCR
    "ghcr.io/johnnyjoy/luanti:${IMAGE_VERSION}-postgresql",
    "ghcr.io/johnnyjoy/luanti:postgresql",
  ]

  cache-from = [
    {
      type = "registry"
      ref  = "tigersmile/luanti-cache"
    }
  ]
  cache-to = [
    {
      type = "registry"
      ref  = "tigersmile/luanti-cache"
      mode = "max"
    }
  ]

  args = {
    "LUANTI_VERSION" = "${LUANTI_VERSION}"
    "IMAGE_SOURCE"   = "${IMAGE_SOURCE}"
    "VCS_REF"        = "${VCS_REF}"
  }

  platforms = "${ALL_PLATFORMS}"
}

target "luanti-redis" {
  context    = "."
  dockerfile = "Dockerfile"
  target     = "luanti-redis"

  tags = [
    # Docker Hub
    "tigersmile/luanti:${IMAGE_VERSION}-redis",
    "tigersmile/luanti:redis",

    # GHCR
    "ghcr.io/johnnyjoy/luanti:${IMAGE_VERSION}-redis",
    "ghcr.io/johnnyjoy/luanti:redis",
  ]

  cache-from = [
    {
      type = "registry"
      ref  = "tigersmile/luanti-cache"
    }
  ]
  cache-to = [
    {
      type = "registry"
      ref  = "tigersmile/luanti-cache"
      mode = "max"
    }
  ]

  args = {
    "LUANTI_VERSION" = "${LUANTI_VERSION}"
    "IMAGE_SOURCE"   = "${IMAGE_SOURCE}"
    "VCS_REF"        = "${VCS_REF}"
  }

  platforms = "${ALL_PLATFORMS}"
}
