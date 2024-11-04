#!/bin/sh
set -ex

for buildkit in "v0.16.0" "v0.17.0"; do
  echo "Building with $buildkit"
  docker buildx rm --force tmp-builder || true
  docker buildx create --use --name tmp-builder --driver-opt image=moby/buildkit:$buildkit-rootless
  docker buildx inspect --bootstrap tmp-builder
  docker buildx build --pull --platform linux/amd64 . --tag latest
done
