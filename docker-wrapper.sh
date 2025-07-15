#!/usr/bin/env bash

# Exit immediately if any command fails.
set -e

# Ensure the entire pipeline fails if any command in the pipeline fails.
set -o pipefail

source "./.raspios-versions"

short='abc'
long='armv8,armv7,armv6'

# Parse options
OPTIONS="$(getopt -o "$short" --long "$long" -- "$@")"
eval set -- "$OPTIONS"

ARCH='arm64'

while true; do
  case "$1" in
    -a | --arm64)
      ARCH='arm64'
      shift
      ;;
    -b | --armv7)
      ARCH='armv7'
      shift
      ;;
    -c | --armv6)
      ARCH='armv6'
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

# Default values.
ROOTFS_URL="https://downloads.raspberrypi.com/raspios_lite_arm64/archive/${ARM64_VERSION}/root.tar.xz"
PLATFORM='linux/arm64'
TAG='raspios-lite:arm64'

if [[ "$ARCH" == 'armv7' || "$ARCH" == 'armv6' ]]; then
  ROOTFS_URL="https://downloads.raspberrypi.com/raspios_lite_armhf/archive/${ARMHF_VERSION}/root.tar.xz"
  TAG='raspios-lite:armhf'

  if [[ "$ARCH" == 'armv7' ]]; then
    PLATFORM='linux/arm/v7'
  else
    PLATFORM='linux/arm/v6'
  fi
fi

docker buildx build \
  --load \
  --platform "${PLATFORM}" \
  --no-cache \
  --build-arg ROOTFS_URL="${ROOTFS_URL}" \
  --tag "${TAG}" .
