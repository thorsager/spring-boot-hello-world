FROM openjdk:10-jre

COPY target/hello-*.jar /app.jar

ENTRYPOINT [ "java", "-jar", "app.jar" ]