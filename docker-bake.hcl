# Version of Luanti upstream (Git tag that actually exists)
variable "LUANTI_VERSION" {
  default = "5.14.0"
}

# Version you want to tag your images with (can be 5.14.0-3, etc.)
variable "IMAGE_VERSION" {
  default = "5.14.0"
}

# Metadata for OCI labels in the image
variable "IMAGE_SOURCE" {
  default = ""
}

variable "VCS_REF" {
  default = ""
}

group "default" {
  targets = [
    "luanti-sqlite",
    "luanti-leveldb",
    "luanti-postgres",
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
    "IMAGE_VERSION" = "${IMAGE_VERSION}"
    "IMAGE_SOURCE"   = "${IMAGE_SOURCE}"
    "VCS_REF"        = "${VCS_REF}"
  }

  # NOTE: match nginx-micro: platforms is a string here
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
    "IMAGE_VERSION" = "${IMAGE_VERSION}"
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
    "IMAGE_VERSION" = "${IMAGE_VERSION}"
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
