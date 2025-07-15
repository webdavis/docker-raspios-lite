#!/usr/bin/env bash

# Exit immediately if any command fails.
set -e

# Ensure the entire pipeline fails if any command in the pipeline fails.
set -o pipefail

source "./.raspios-versions"

set_armhf_rootfs_url() {
  declare -g ROOTFS_URL="https://downloads.raspberrypi.com/raspios_lite_armhf/archive/${ARMHF_VERSION}/root.tar.xz"
}

short='abc'
long='armv8,armv7,armv6'

# Parse options
OPTIONS="$(getopt -o "$short" --long "$long" -- "$@")"
eval set -- "$OPTIONS"

# Default values.
ARCH='arm64'
PLATFORM='linux/arm64'
PROFILE='webdavis'
OS='raspios-lite'
REPO="${PROFILE}/${OS}"
ROOTFS_URL="https://downloads.raspberrypi.com/raspios_lite_arm64/archive/${ARM64_VERSION}/root.tar.xz"

while true; do
  case "$1" in
    -a | --arm64)
      ARCH='arm64'
      PLATFORM='linux/arm64'
      shift
      ;;
    -b | --armv7)
      ARCH='armv7'
      PLATFORM='linux/arm/v7'
      set_armhf_rootfs_url
      shift
      ;;
    -c | --armv6)
      ARCH='armv6'
      PLATFORM='linux/arm/v6'
      set_armhf_rootfs_url
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

docker buildx build \
  --load \
  --platform "${PLATFORM}" \
  --no-cache \
  --build-arg ROOTFS_URL="${ROOTFS_URL}" \
  --tag "${TAG}" .
