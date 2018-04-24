#!/usr/bin/env bash
set -e

IMAGE=thorsager/sbhw
TAG=latest

BUILD=target
QEMU_LOCAL="${BUILD}/qemu"
QEMU_VERSION=2.9.1-1
QEMU_DL_BASE_URL=https://github.com/multiarch/qemu-user-static/releases/download/v${QEMU_VERSION}
QEMU_ARCS="arm aarch64 x86_64";
BUILD_ARCH=x86_64


## Build .jar
mvn package

## Create local QEMU storage-folder
[[ ! -d ${QEMU_LOCAL} ]] && mkdir -p ${QEMU_LOCAL}

## Download QEMU binaries if not found locally
for target_arch in ${QEMU_ARCS}; do
    qemu=qemu-"${target_arch}-static"
    if [[ ! -e ${QEMU_LOCAL}/${qemu} ]]; then
        archive_file="${BUILD_ARCH}_${qemu}.tar.gz"
        wget ${QEMU_DL_BASE_URL}/${archive_file} -O ${QEMU_LOCAL}/${archive_file}
        tar xvf ${QEMU_LOCAL}/${archive_file} --directory ${QEMU_LOCAL}/
        rm ${QEMU_LOCAL}/${archive_file}
    fi
done

## Register qemu-container
docker run --rm --privileged multiarch/qemu-user-static:register --reset

## Build and intel/amd version
docker build -t ${IMAGE}:amd64-${TAG} -f Dockerfile .
docker push ${IMAGE}:amd64-${TAG}

## Build and push arm32v7 version
docker build -t ${IMAGE}:arm32v7-${TAG} -f Dockerfile.arm32v7 .
docker push ${IMAGE}:arm32v7-${TAG}

## Build and arm64v8 version
docker build -t ${IMAGE}:arm64v8-${TAG} -f Dockerfile.arm64v8 .
docker push ${IMAGE}:arm64v8-${TAG}

## Create docker manifest-list
docker manifest create --amend ${IMAGE}:${TAG} \
 ${IMAGE}:amd64-${TAG} \
 ${IMAGE}:arm32v7-${TAG} \
 ${IMAGE}:arm64v8-${TAG}

## Annotate images
docker manifest annotate ${IMAGE}:${TAG} ${IMAGE}:amd64-${TAG} --arch amd64 --os linux
docker manifest annotate ${IMAGE}:${TAG} ${IMAGE}:arm32v7-${TAG} --arch arm --os linux --variant v7
docker manifest annotate ${IMAGE}:${TAG} ${IMAGE}:arm64v8-${TAG} --arch aarch64 --os linux --variant v8

## Push manifest
docker manifest push ${IMAGE}:${TAG}


