#!/bin/sh
set -ex

docker info

echo "Building with $BUILDKIT_VERSION"
docker buildx rm --force tmp-builder || true
docker buildx create --use --name tmp-builder --driver-opt image=moby/buildkit:$BUILDKIT_VERSION-rootless
docker buildx inspect --bootstrap tmp-builder
docker buildx build --pull --platform linux/amd64 . --tag latest
