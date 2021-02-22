FROM containers.intersystems.com/intersystems/iris:2020.4.0.524.0 AS builder

FROM openjdk:8-jdk-alpine

WORKDIR /app/

COPY --from=builder /usr/irissys/dev/java/lib/JDK18/intersystems-utils-3.2.0.jar /app
COPY --from=builder /usr/irissys/dev/java/lib/JDK18/intersystems-jdbc-3.2.0.jar /app
COPY --from=builder /usr/irissys/dev/java/lib/JDK18/intersystems-xep-3.2.0.jar /app

COPY wait.sh /app/

CMD [ "/app/wait.sh"]
