#!/bin/bash

# Builds the binaries
build_binary() {
    echo -n "Building binaries... "
    docker run --rm -v $PWD:/treegen sebas369/smartnode-builder:latest /treegen/build_binaries.sh
    echo "done!"
}

# Build the images
build_docker() {
    echo -n "Building Docker images... "
    docker buildx build --platform=linux/amd64 -t sebas369/treegen:$VERSION-amd64 --load .
    docker buildx build --platform=linux/arm64 -t sebas369/treegen:$VERSION-arm64 --load .
    docker push sebas369/treegen:$VERSION-amd64
    docker push sebas369/treegen:$VERSION-arm64
    echo "done!"
}

# Build the manifest
build_manifest() {
    echo -n "Building Docker manifest... "
    rm -f ~/.docker/manifests/docker.io_rocketpool_treegen-$VERSION
    rm -f ~/.docker/manifests/docker.io_rocketpool_treegen-latest
    docker manifest create sebas369/treegen:$VERSION --amend sebas369/treegen:$VERSION-amd64 --amend sebas369/treegen:$VERSION-arm64
    docker manifest create sebas369/treegen:latest --amend sebas369/treegen:$VERSION-amd64 --amend sebas369/treegen:$VERSION-arm64
    echo "done!"
    echo -n "Pushing to Docker Hub... "
    docker manifest push --purge sebas369/treegen:$VERSION
    docker manifest push --purge sebas369/treegen:latest
    echo "done!"
}

# Print usage
usage() {
    echo "Usage: build-release.sh [options] -v <version number>"
    echo "This script builds treegen's artifacts."
    echo "Options:"
    echo $'\t-a\tBuild all of the artifacts.'
    echo $'\t-b\tBuild the native binaries for most Linux distributions'
    echo $'\t-d\tBuild the Alpine-based Docker containers'
    echo $'\t-m\tBuild the Docker manifest'
    exit 0
}

# =================
# === Main Body ===
# =================

# Get the version
while getopts "abdmv:" FLAG; do
    case "$FLAG" in
        a) BINARIES=true DOCKER=true MANIFEST=true ;;
        b) BINARIES=true ;;
        d) DOCKER=true ;;
        m) MANIFEST=true ;;
        v) VERSION="$OPTARG" ;;
        *) usage ;;
    esac
done
if [ -z "$VERSION" ]; then
    usage
fi

# Build the artifacts
if [ "$BINARIES" = true ]; then
    build_binary
fi
if [ "$DOCKER" = true ]; then
    build_docker
fi
if [ "$MANIFEST" = true ]; then
    build_manifest
fi
