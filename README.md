<p align="center">
    <img src="./images/repo-icon.jpg" alt="Repo Icon" width="400" height="400">
</p>

# docker-raspios-lite

[![CD - Deploy images to Docker Hub](https://github.com/webdavis/docker-raspios-lite/actions/workflows/cd.yml/badge.svg)](https://github.com/webdavis/docker-raspios-lite/actions/workflows/cd.yml)

This project builds and publishes Docker images for Raspberry Pi OS Lite on [Docker
Hub](https://hub.docker.com/repository/docker/webdavis/raspios-lite/general).

## Table of Contents

- [Supported Architectures](#supported-architectures)
- [Usage](#usage)
  - [Docker Setup／Installation](#docker-setupinstallation)
  - [Running the Images](#running-the-images)
    - [Running ARM Containers on x86_64 Hosts (QEMU Setup)](#running-arm-containers-on-x86_64-hosts-qemu-setup)
      - [Debian/Ubuntu](#debianubuntu)
      - [Fedora](#fedora)
      - [Arch Linux](#arch-linux)
- [How to Work on this Project](#how-to-work-on-this-project)
  - [Building Images Locally](#building-images-locally)
    - [Building 64-bit (arm64) Compatible Images](#building-64-bit-arm64-compatible-images)
    - [Building 32-bit (armhf／armel) Compatible Images](#building-32-bit-armhfarmel-compatible-images)
  - [List Local Project Architectures](#list-local-project-architectures)
  - [List Remote Image Architectures (Docker Hub Manifests)](#list-remote-image-architectures-docker-hub-manifests)
  - [Linting](#linting)
    - [Running Hadolint](#running-hadolint)
  - [Raspberry Pi OS Lite Root File System](#raspberry-pi-os-lite-root-file-system)

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
> - (**Pro Tip:** The `arch-YYYYMMDD` tag aliases are immutable and built from the
>   official Raspberry Pi OS Lite root filesystems published on that specific date. These
>   will never change. Choose these to ensure reproducibility.)

## Usage

This section explains how to set up Docker on your machine and work with the Raspberry Pi OS
Lite images provided by this project. Follow the steps below to get started.

### Docker Setup／Installation

On macOS, you can install **Docker Desktop** (which includes Buildx) via Homebrew:

```bash
brew install --cask docker-desktop
```

After installation, launch **Docker Desktop** complete the setup (accepting licenses, etc.),
before building any images.

### Running the Images

These images can be used as a base for Raspberry Pi OS Lite-specific containers:

```dockerfile
FROM webdavis/raspios-lite:arm64-20250513

# Add your own layers here...
```

Or run a container directly, like so:

```bash
docker run --rm -it --platform linux/arm64 webdavis/raspios-lite:arm64
```

> \[!NOTE\]
> To run ARM containers on an x86_64 (Intel/AMD) host, QEMU emulation must be enabled (see
> below).

### Running ARM Containers on x86_64 Hosts (QEMU Setup)

Install QEMU and enable `binfmt` support via your system’s package manager:

#### Debian/Ubuntu:

```bash
sudo apt install qemu-user-static binfmt-support
```

#### Fedora:

```bash
sudo dnf install qemu-user-static binfmt-support
```

#### Arch Linux:

```bash
sudo pacman -S qemu-user-static binfmt-support
```

## How to work on this Project!

This project requires [Docker](https://docs.docker.com/desktop/setup/install/mac-install/) and
[Buildx](https://github.com/docker/buildx).

Again, assuming you're on macOS, you will need to install **Docker Desktop** (which comes with
Buildx) via Homebrew:

```bash
brew install --cask docker-desktop
```

Download this repo:

```bash
git clone git@github.com:webdavis/docker-raspios-lite.git
```

Then switch into the project directory:

```bash
cd docker-raspios-lite
```

### Building Images Locally

Use the [`docker-wrapper.sh`](./docker-wrapper.sh) script to build and inspect project images
on your dev machine.

> `docker-wrapper.sh` is a convenience script that makes working on this project a tad easier.

#### Building 64-bit (arm64) Compatible Images

To build the 64-bit variant for an arm64 architecture, run the following command:

```bash
./docker-wrapper.sh -a -o
```

> **Note:** The `-o` option will append the `--load` flag to the `docker` command, which loads
> the built image into Docker so that you can run it locally.

#### Building 32-bit (armhf／armel) Compatible Images

When building a 32-bit image with the `-h` flag, you must specify which *Platform* the image
should be built for, for example `armv7` or `armv6`. The following table will help you:

- `armv7` → `linux/arm/v7` (most models: Pi 2, 3, 4, Zero 2)
- `armv6` → `linux/arm/v6` (Pi Zero v1, Pi 1, legacy)
- `arm64` → `linux/arm64` (32-bit on 64-bit hardware)

For example, run the following command to build and load a 32-bit image for Pi 2/3/4/Zero 2:

```bash
./docker-wrapper.sh -h armv7 -o
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
