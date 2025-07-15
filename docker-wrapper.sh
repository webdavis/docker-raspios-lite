#!/usr/bin/env bash

# Exit immediately if any command fails.
set -e

# Ensure the entire pipeline fails if any command in the pipeline fails.
set -o pipefail

source "./.raspios-versions"

docker buildx build \
  --load \
  --platform linux/arm64 \
  --no-cache \
  --build-arg ROOTFS_URL=https://downloads.raspberrypi.com/raspios_lite_arm64/archive/${ARM64_VERSION}/root.tar.xz \
  --tag raspios-lite:latest .
