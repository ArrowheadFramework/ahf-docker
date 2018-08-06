FROM alpine:3.7

RUN apk add --no-cache socat

WORKDIR /src

COPY src/ .

VOLUME /out

ENTRYPOINT ["./entrypoint.sh"]
