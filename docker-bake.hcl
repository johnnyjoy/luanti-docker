variable "IMAGE" {
  # Docker Hub repo, e.g. "tigersmile/luanti".
  default = "tigersmile/luanti"
}

variable "PLATFORMS" {
  # Comma-separated list.
  default = "linux/amd64,linux/arm64"
}

variable "LUANTI_VERSION" {
  # Used for versioned tags (the Dockerfile also has a default).
  default = "5.14.0"
}

variable "IMAGE_SOURCE" {
  # e.g. "https://github.com/OWNER/REPO"
  default = ""
}

variable "VCS_REF" {
  # e.g. git SHA
  default = ""
}

group "default" {
  targets = ["sqlite", "leveldb", "postgres", "redis"]
}

target "_common" {
  context    = "."
  dockerfile = "Dockerfile"
  platforms  = split(",", PLATFORMS)
  args = {
    LUANTI_VERSION = LUANTI_VERSION
    IMAGE_SOURCE   = IMAGE_SOURCE
    VCS_REF        = VCS_REF
  }
}

target "sqlite" {
  inherits = ["_common"]
  target   = "luanti-sqlite"
  tags = [
    "${IMAGE}:sqlite3-${LUANTI_VERSION}",
    "${IMAGE}:latest",
  ]
}

target "leveldb" {
  inherits = ["_common"]
  target   = "luanti-leveldb"
  tags = [
    "${IMAGE}:leveldb-${LUANTI_VERSION}",
  ]
}

target "postgres" {
  inherits = ["_common"]
  target   = "luanti-postgres"
  tags = [
    "${IMAGE}:postgresql-${LUANTI_VERSION}",
  ]
}

target "redis" {
  inherits = ["_common"]
  target   = "luanti-redis"
  tags = [
    "${IMAGE}:redis-${LUANTI_VERSION}",
  ]
}


