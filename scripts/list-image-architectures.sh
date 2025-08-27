#!/usr/bin/env bash

# Exit immediately if any command fails.
set -e
set -o pipefail

assert_images_exist() {
  local images="$1"
  local message="$2"

  if [[ "$images" == '' ]]; then
    echo "$message" >&2
    exit 1
  fi
}

get_system_images() {
  local image_ignore_list='none'

  # Get a list of all images for this project in repo:tag format.
  local images
  images="$(docker image ls -a --format '{{.Repository}}:{{.Tag}}' \
    | grep -v "$image_ignore_list")"

  assert_images_exist "$images" 'No images have been created'

  echo "$images"
}

get_project_images() {
  local image_ignore_list='moby/buildkit\|none'
  local image_allow_list='^webdavis/raspios-lite'

  # Get a list of all images for this project in repo:tag format.
  local images
  images="$(docker image ls -a --format '{{.Repository}}:{{.Tag}}' \
    | grep -v "$image_ignore_list" \
    | grep "$image_allow_list")"

  assert_images_exist "$images" 'No project images have been created'

  echo "$images"
}

list_local_architectures() {
  local project_only="$1"
  local images="$2"

  local output
  if [[ "$project_only" == 'true' ]]; then
    output="Project Image\tArchitecture\n"
    output+="-------------\t------------\n"
  else
    output="System Image\tArchitecture\n"
    output+="------------\t------------\n"
  fi

  local image architecture
  for image in $images; do

    # Get image details and extract architecture.
    architecture="$(docker image inspect -f '{{ .Architecture }}{{ .Variant }}' "$image")"

    output+="${image}\t${architecture}\n"
  done

  echo -e "${output}" | column -s $'\t' -t
}

list_remote_architectures() {
  local images="$1"

  local output
  output="Remote Image\tSupported Platforms\n"
  output+="------------\t-------------------\n"

  local image manifest architectures formatted_architectures
  for image in $images; do

    # Get manifest details and extract architectures.
    manifest="$(docker manifest inspect "$image")" || continue

    if [[ $? -ne 0 ]]; then
      continue
    fi

    architectures="$(echo "$manifest" | jq -r '.manifests[] | "\(.platform.architecture)\(.platform.variant // "")"')"
    formatted_architectures="$(echo "$architectures" | grep -v 'unknown' | tr '\n' ' ')"

    output+="$image\t$formatted_architectures\n"
  done

  echo -e "${output}" | column -s $'\t' -t
}

parse_command_line_arguments() {
  local short='slr'
  local long='system,local,remote'

  local project_only='true'
  local local='false'
  local remote='false'

  OPTIONS="$(getopt -o "$short" --long "$long" -- "$@")"

  eval set -- "$OPTIONS"

  while true; do
    case "$1" in
      -s | --system)
        project_only='false'
        shift
        ;;
      -l | --local)
        local='true'
        shift
        ;;
      -r | --remote)
        remote='true'
        shift
        ;;
      --)
        shift
        break
        ;;
    esac
  done

  local images
  if [[ "$project_only" == 'true' ]]; then
    images="$(get_project_images)"
  else
    images="$(get_system_images)"
  fi

  if [[ "$local" == 'false' && "$remote" == 'false' ]]; then
    list_local_architectures "$project_only" "$images"
    return
  fi

  if [[ "$local" == 'true' ]]; then
    list_local_architectures "$project_only" "$images"
  fi

  if [[ "$remote" == 'true' ]]; then
    list_remote_architectures "$images"
  fi
}

main() {
  parse_command_line_arguments "$@"
}

main "$@"
