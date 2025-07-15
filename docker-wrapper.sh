#!/usr/bin/env bash

# Exit immediately if any command fails.
set -e

# Ensure the entire pipeline fails if any command in the pipeline fails.
set -o pipefail

source "./.raspios-versions"

# Default values.
TAG="raspios-lite:latest"
PLATFORM="linux/arm64"
ROOTFS_URL="https://downloads.raspberrypi.com/raspios_lite_arm64/archive/${ARM64_VERSION}/root.tar.xz"

docker buildx build \
  --load \
  --platform ${PLATFORM} \
  --no-cache \
  --build-arg ROOTFS_URL="${ROOTFS_URL}" \
  --tag ${TAG} .
