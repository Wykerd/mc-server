FROM alpine:latest

WORKDIR /mc

COPY . .

EXPOSE 25565

RUN apk add git openjdk8 curl nodejs yarn maven gradle

RUN yarn

RUN mkdir /tools

ENTRYPOINT [ "sh", "./entry.sh" ]