FROM openjdk:10-jre
# Not necessary for the arch where host and target are the same
# COPY qemu-x86_64-static /usr/bin/

COPY target/hello-*.jar /app.jar

ENTRYPOINT [ "java", "-jar", "app.jar" ]