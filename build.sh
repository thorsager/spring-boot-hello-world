#!/usr/bin/env bash
set -x


for target_arch in arm x86_64; do
  wget -N https://github.com/multiarch/qemu-user-static/releases/download/v2.9.1-1/x86_64_qemu-${target_arch}-static.tar.gz
  tar -xvf x86_64_qemu-${target_arch}-static.tar.gz
done

IMAGE=thorsager/sbhw
TAG=latest


mvn package

docker run --rm --privileged multiarch/qemu-user-static:register --reset

docker build -t ${IMAGE}:amd64-${TAG} -f Dockerfile .
docker push ${IMAGE}:amd64-${TAG}

docker build -t ${IMAGE}:arm32v7-${TAG} -f Dockerfile-arm32v7 .
docker push ${IMAGE}:arm32v7-${TAG}


docker manifest create --amend ${IMAGE}:${TAG} \
 ${IMAGE}:amd64-${TAG} \
 ${IMAGE}:arm32v7-${TAG}

docker manifest annotate ${IMAGE}:${TAG} ${IMAGE}:arm32v7-${TAG} --arch arm --os linux --variant v7

docker manifest annotate ${IMAGE}:${TAG} ${IMAGE}:amd64-${TAG} --arch amd64 --os linux

docker manifest push ${IMAGE}:${TAG}


