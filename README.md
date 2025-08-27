<p align="center">
    <img src="./images/repo-icon.jpg" alt="Repo Icon" width="400" height="400">
</p>

# docker-raspios-lite

[![CD - Deploy images to Docker Hub](https://github.com/webdavis/docker-raspios-lite/actions/workflows/cd.yml/badge.svg)](https://github.com/webdavis/docker-raspios-lite/actions/workflows/cd.yml)

This project builds and publishes Docker images for Raspberry Pi OS Lite on [Docker
Hub](https://hub.docker.com/repository/docker/webdavis/raspios-lite/general).

## Supported Architectures

Images are published as multi-arch manifests. Use the table below to choose the right tag for your device:

| Device Type                              | Recommended Tag | Alternative Tags (aliases)                      | Available Platforms              | Notes                             |
| ---------------------------------------- | --------------- | ----------------------------------------------- | -------------------------------- | --------------------------------- |
| Raspberry Pi 3, 4, 400, 5 (64-bit OS)    | `arm64`         | `arm64-<date>`,<br>`64-bit`,<br>`64-bit-<date>` | `linux/arm64`                    | Best performance on modern Pis    |
| Raspberry Pi 2, 3, 4, Zero 2 (32-bit OS) | `armhf`         | `armhf-<date>`,<br>`32-bit`,<br>`32-bit-<date>` | `linux/arm/v7`,<br>`linux/arm64` | Default choice for 32-bit systems |
| Raspberry Pi Zero (v1), Pi 1             | `armhf`         | `armhf-<date>`,<br>`32-bit`,<br>`32-bit-<date>` | `linux/arm/v6`                   | Legacy devices (32-bit armel)     |

> \[!Tip\]
>
> - Use `arm64` if your OS is 64-bit and you’re on a newer Pi.
> - Use `armhf` for 32-bit compatibility or older boards.
> - (**Additional Tip:** Choose the `arch-<date>` tag alias for better reproducability in
>   version control tracked projects.)

## Setup／Installation

This project assumes that both
[Docker](https://docs.docker.com/desktop/setup/install/mac-install/) and
[Buildx](https://github.com/docker/buildx) are installed.

On macOS, you can install **Docker Desktop** (which includes Buildx) via Homebrew:

```bash
brew install --cask docker-desktop
```

Once installed, launch **Docker Desktop** to complete the setup (accepting licenses, etc.),
before starting any builds.

## How to work on this Project!

### Linting

This project uses [Hadolint](https://github.com/hadolint/hadolint) to enforce `Dockerfile` best
practices.

Hadolint can be installed using Homebrew:

```bash
brew install hadolint
```

#### Running Hadolint

To lint the [`Dockerfile`](./Dockerfile), run:

```bash
hadolint Dockerfile
```

Linting rules for this project are defined in the [`.hadolint.yaml`](./.hadolint.yaml)
file.

### Raspberry Pi OS Lite Root File System

The latest root file system for Raspberry Pi OS Lite is provided as `root.tar.xz` in Raspberry
Pi's [official downloads archive](https://downloads.raspberrypi.com/raspios_lite_arm64/archive/).

Just click on the latest version (or most recent date).

## Local Builds

Use the [`docker-wrapper.sh`](./docker-wrapper.sh) script to build and inspect project images.

### Build Images Locally

```bash
./docker-wrapper.sh
```

### List Local Project Architectures

The following command lists the architectures this project has built locally on your machine:

```bash
./docker-wrapper.sh -l
```

### List Remote Image Architectures (Docker Hub Manifests)

The command below lists the image manifests from Docker Hub that are tracked by this
project, which shows all available platforms (architectures/OS variants) that the image
supports.

> \[!NOTE\]
> Commands that access Docker Hub require you to be logged in via `docker login`.

```bash
./docker-wrapper.sh -r
```
