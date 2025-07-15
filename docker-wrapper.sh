#!/usr/bin/env bash

# Exit immediately if any command fails.
set -e

# Ensure the entire pipeline fails if any command in the pipeline fails.
set -o pipefail

source "./.raspios-versions"

set_armhf_rootfs_url() {
  declare -g ROOTFS_URL="https://downloads.raspberrypi.com/raspios_lite_armhf/archive/${ARMHF_VERSION}/root.tar.xz"
}

list_local_architectures() {
  ./list-image-architectures.sh -l
}

list_remote_architectures() {
  ./list-image-architectures.sh -r
}

short='abcdlLr'
long='armv8,armv7,armv6,dry-run,load,list,remote'

# Parse options
OPTIONS="$(getopt -o "$short" --long "$long" -- "$@")"
eval set -- "$OPTIONS"

# Default values.
BUILD='true'
ARCH='arm64'
PLATFORM='linux/arm64'
PROFILE='webdavis'
OS='raspios-lite'
REPO="${PROFILE}/${OS}"
ROOTFS_URL="https://downloads.raspberrypi.com/raspios_lite_arm64/archive/${ARM64_VERSION}/root.tar.xz"
LOAD='true'
DRY_RUN='false'

while true; do
  case "$1" in
    -a | --arm64)
      BUILD='true'
      ARCH='arm64'
      PLATFORM='linux/arm64'
      shift
      ;;
    -b | --armv7)
      BUILD='true'
      ARCH='armv7'
      PLATFORM='linux/arm/v7'
      set_armhf_rootfs_url
      shift
      ;;
    -c | --armv6)
      BUILD='true'
      ARCH='armv6'
      PLATFORM='linux/arm/v6'
      set_armhf_rootfs_url
      shift
      ;;
    -d | --dry-run)
      BUILD='false'
      DRY_RUN='true'
      shift
      ;;
    -l | --load)
      LOAD='true'
      shift
      ;;
    -L | --list)
      BUILD='false'
      list_local_architectures
      shift
      ;;
    -r | --remote)
      BUILD='false'
      list_remote_architectures
      shift
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

TAG="${REPO}:${ARCH}"

DOCKER_CMD="docker buildx build \
--platform \"${PLATFORM}\" \
--no-cache \
--build-arg ROOTFS_URL=\"${ROOTFS_URL}\" \
--tag \"${TAG}\" ."

docker_load() {
  DOCKER_CMD+=" --load"
}

docker_build_dry_run() {
  echo "$DOCKER_CMD"
}

docker_build() {
  eval "$DOCKER_CMD"
}

main() {
  if [[ "$LOAD" == 'true' ]]; then
    docker_load
  fi

  if [[ "$DRY_RUN" == 'true' ]]; then
    docker_build_dry_run
  fi

  if [[ "$BUILD" == 'true' ]]; then
    docker_build
  fi
}

main "$@"
