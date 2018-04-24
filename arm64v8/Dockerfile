FROM buildpack-deps as fetcher

ENV QEMU_URL=https://github.com/multiarch/qemu-user-static/releases/download/v2.9.1-1 \
    QEMU_ARCHIVE_FILE=x86_64_qemu-aarch64-static.tar.gz
ADD ${QEMU_URL}/${QEMU_ARCHIVE_FILE} /tmp/

RUN mkdir /tmp/qemu \
    && tar xvf /tmp/${QEMU_ARCHIVE_FILE} -C /tmp/qemu/ \
    && rm /tmp/${QEMU_ARCHIVE_FILE}

##
FROM arm64v8/openjdk:10-jre
COPY --from=fetcher /tmp/qemu/* /usr/bin/

COPY target/hello-*.jar /app.jar

ENTRYPOINT [ "java", "-jar", "app.jar" ]
