FROM ubuntu

WORKDIR /app

RUN apt-get update && apt-get install -y iputils-ping bc

COPY ping-script.sh .
