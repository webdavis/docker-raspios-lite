# docker-raspios-lite

Raspberry Pi OS Lite Docker images hosted on [Docker Hub](https://hub.docker.com/).

## Setup／Installation

This project assumes that both
[Docker](https://docs.docker.com/desktop/setup/install/mac-install/) and \[Buildx\] are
installed.

On macOS, you can install Docker Desktop (which includes Buildx) via Homebrew:

```bash
brew install --cask docker-desktop
```

Once installed, launch **Docker Desktop** to complete the setup (accepting licenses and etc.),
before running builds.

## Raspberry Pi OS Lite Root File System

The latest root file system for Raspberry Pi OS Lite is available as `root.tar.xz` in the
[Official Downloads Archive](https://downloads.raspberrypi.com/raspios_lite_arm64/archive/).

(Just click on the latest version, or most recent date.)

## Linting

This project uses [Hadolint](https://github.com/hadolint/hadolint) to enforce Dockerfile best
practices.

Hadoline can be installed using Homebrew:

```bash
brew install hadolint
```

### Running Hadolint

To lint the `Dockerfile`, run:

```bash
hadolint Dockerfile
```

Configuration is defined in the [.hadolint.yaml](./.hadolint.yaml) file at the root of the
project.

