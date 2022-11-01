FROM openjdk:alpine

EXPOSE 8080
ADD application.jar application.jar
ENTRYPOINT ["java","-jar","-Xms1024m","-Xmx1800m","application.jar"]
