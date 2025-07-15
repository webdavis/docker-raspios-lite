#!/usr/bin/env bash

# Exit immediately if any command fails.
set -e

# Ensure the entire pipeline fails if any command in the pipeline fails.
set -o pipefail

docker buildx build \
  --load \
  --platform linux/arm64 \
  --no-cache \
  --build-arg ROOTFS_URL=https://downloads.raspberrypi.com/raspios_lite_arm64/archive/2025-05-13-08:03/root.tar.xz \
  --tag raspios-lite:latest .
