#!/usr/bin/env bash
set -euxo pipefail

for buildkit in "v0.16.0" "v0.17.0"; do
  echo "Building with $buildkit"
  docker buildx rm --force tmp-builder || true
  docker buildx create --use --name tmp-builder --driver-opt image=moby/buildkit:$buildkit-rootless
  docker buildx inspect --bootstrap tmp-builder
  docker buildx build --pull --platform linux/amd64,linux/arm64 --output type=oci,dest=test.tar . --tag latest
done
