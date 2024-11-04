#!/usr/bin/env bash
set -euxo pipefail
docker buildx rm --force --keep-state tmp-builder || true
docker buildx create --use --name tmp-builder --driver-opt image=moby/buildkit:buildx-stable-1-rootless
docker buildx inspect --bootstrap tmp-builder
docker buildx build --pull --platform linux/amd64,linux/arm64 --output type=oci,dest=test.tar . --tag latest
