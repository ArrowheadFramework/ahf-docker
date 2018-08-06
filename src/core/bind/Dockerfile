FROM alpine:3.6

RUN apk --no-cache add bind bind-tools

WORKDIR /ahf

COPY scripts/ .

VOLUME /tsig /out

ENTRYPOINT ["./entrypoint.sh"]

