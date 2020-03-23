#!/usr/bin/env bash
IMAGE_NAME=timhaak/proxy
docker build --pull --rm --build-arg PHP_VERSION='5.6' -t "${IMAGE_NAME}" .
