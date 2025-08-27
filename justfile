default:
    @just --choose

alias c := list-docker-containers
alias i := list-docker-images
alias b := bootstrap-docker-builder
alias a := load-arm64
alias A := deploy-arm64
alias h := load-armhf
alias H := deploy-armhf
alias l := list-local-image-platforms
alias L := list-system-image-platforms
alias r := list-remote-image-platforms
alias C := clean

list-docker-images:
    docker image ls -a

list-docker-containers:
    docker ps -a

bootstrap-docker-builder:
    docker buildx create --use --name mybuilder
    docker buildx inspect mybuilder --bootstrap

load-arm64:
    ./docker-wrapper.sh --arm64 --load

deploy-arm64:
    ./docker-wrapper.sh --arm64 --push

load-armhf:
    ./docker-wrapper.sh --armhf armv7 --load

deploy-armhf:
    ./docker-wrapper.sh --armhf-all --push

list-local-image-platforms:
    ./scripts/list_image_platforms.sh --local

list-system-image-platforms:
    ./scripts/list_image_platforms.sh --system

list-remote-image-platforms:
    ./scripts/list_image_platforms.sh --remote

clean:
    ./scripts/clean.sh
