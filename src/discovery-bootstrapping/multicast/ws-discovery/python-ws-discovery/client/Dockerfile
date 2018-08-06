FROM python:2.7-alpine3.7

WORKDIR /src

RUN apk add --no-cache gcc musl-dev linux-headers
RUN pip install WSDiscovery netifaces

COPY src/ .

ENV TIMEOUT="2.0"

ENTRYPOINT ["./entrypoint.sh"]
