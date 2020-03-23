#!/usr/bin/env bash
IMAGE_NAME=timhaak/proxy
docker build --pull --rm -t "${IMAGE_NAME}" .
docker push "${IMAGE_NAME}"
