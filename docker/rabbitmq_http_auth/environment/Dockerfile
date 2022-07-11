FROM openjdk:8-jre

MAINTAINER cqiang <lacia.cq@qq.com>

RUN mkdir /app

COPY app.jar /app/app.jar

ENTRYPOINT ["java", "-jar", "/app/app.jar"]

EXPOSE 80

