#!/usr/bin/env bash

# Exit immediately if any command fails.
set -e

# Ensure the entire pipeline fails if any command in the pipeline fails.
set -o pipefail

source "./.raspios-versions"

get_project_root_directory() {
  git rev-parse --show-toplevel
}

set_armhf_rootfs_url() {
  declare -g ROOTFS_URL="https://downloads.raspberrypi.com/raspios_lite_armhf/archive/${ARMHF_VERSION}/root.tar.xz"
}

list_local_project_architectures() {
  ./scripts/list-image-architectures.sh -l
}

list_local_system_architectures() {
  ./scripts/list-image-architectures.sh -s
}

list_remote_project_architectures() {
  ./scripts/list-image-architectures.sh -r
}

list_remote_system_architectures() {
  ./scripts/list-image-architectures.sh -r -s
}

SHORT_FLAGS='ah:doplLrRc'
LONG_FLAGS='arm64,armhf:,dry-run,load,push,'
LONG_FLAGS+='list-local-project-arch,list-remote-project-arch,list-remote-system-arch,list-local-system-arch,'
LONG_FLAGS+='clean'

# Parse options
OPTIONS="$(getopt -o "$SHORT_FLAGS" --long "$LONG_FLAGS" -- "$@")"
eval set -- "$OPTIONS"

# Default values.
BUILD='true'
ARCH='64-bit'
PLATFORM='linux/arm64'
PROFILE='webdavis'
OS='raspios-lite'
REPO="${PROFILE}/${OS}"
ROOTFS_URL="https://downloads.raspberrypi.com/raspios_lite_arm64/archive/${ARM64_VERSION}/root.tar.xz"
LOAD='false'
DRY_RUN='false'
PUSH='false'

while true; do
  case "$1" in
    -a | --arm64)
      BUILD='true'
      ARCH='arm64'
      PLATFORM='linux/arm64'
      shift
      ;;
    -h | --armhf)
      BUILD='true'
      ARCH='armhf'
      case "$2" in
        armv6) PLATFORM='linux/arm/v6' ;;
        armv7) PLATFORM='linux/arm/v7' ;;
        arm64) PLATFORM='linux/arm64' ;;
        *) echo "Unknown ${ARCH} variant: '$2'" >&2; exit 1 ;;
      esac
      set_armhf_rootfs_url
      shift 2
      ;;
    -d | --dry-run)
      BUILD='false'
      DRY_RUN='true'
      shift
      ;;
    -o | --load)
      LOAD='true'
      shift
      ;;
    -p | --push)
      PUSH='true'
      shift
      ;;
    -l | --list-local-project-arch)
      BUILD='false'
      list_local_project_architectures
      shift
      ;;
    -L| --list-local-system-arch)
      BUILD='false'
      list_local_system_architectures
      shift
      ;;
    -r | --list-remote-project-arch)
      BUILD='false'
      list_remote_project_architectures
      shift
      ;;
    -R | --list-remote-system-arch)
      BUILD='false'
      list_remote_system_architectures
      shift
      ;;
    -c | --clean)
      ./scripts/clean.sh
      exit 1
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
--build-arg ROOTFS_URL=\"${ROOTFS_URL}\" \
--tag \"${TAG}\" ."

docker_load() {
  DOCKER_CMD+=" --load"
}

docker_push() {
  DOCKER_CMD+=" --push"
}

docker_build_dry_run() {
  echo "$DOCKER_CMD"
}

docker_build() {
  eval "$DOCKER_CMD"
}

main() {
  cd "$(get_project_root_directory)" || exit 1

  if [[ "$PUSH" == 'true' ]]; then
    if [[ "$LOAD" == 'true' ]]; then
      echo "Warning: --load disabled because --push is requested" >&2
    fi
    LOAD='false'

    if [[ "$ARCH" == "armhf" ]]; then
      PLATFORM="linux/arm/v6,linux/arm/v7,linux/arm64"
    fi

    docker_push
  fi

  # Local load only happens for single-platform builds.
  if [[ "$LOAD" == 'true' ]]; then
    docker_load
  fi

  case "$ARCH" in
    armhf) DOCKER_CMD+=" --tag ${REPO}:32-bit" ;;
    arm64) DOCKER_CMD+=" --tag ${REPO}:64-bit" ;;
  esac

  if [[ "$DRY_RUN" == 'true' ]]; then
    docker_build_dry_run
  fi

  if [[ "$BUILD" == 'true' ]]; then
    docker_build
  fi
}

main "$@"
