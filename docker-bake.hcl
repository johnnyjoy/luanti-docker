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
    "luantiserver",
  ]
}

target "luantiserver" {
  context    = "."
  dockerfile = "Dockerfile"
  target     = "luantiserver"

  tags = [
    # Docker Hub
    "tigersmile/luantiserver:${IMAGE_VERSION}",
    "tigersmile/luantiserver:latest",

    # GHCR
    "ghcr.io/johnnyjoy/luantiserver:${IMAGE_VERSION}",
    "ghcr.io/johnnyjoy/luantiserver:latest",
  ]

  cache-from = [
    {
      type = "registry"
      ref  = "tigersmile/luantiserver-cache"
    }
  ]
  cache-to = [
    {
      type = "registry"
      ref  = "tigersmile/luantiserver-cache"
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
