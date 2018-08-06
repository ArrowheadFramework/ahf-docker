FROM python:2.7-alpine3.7

WORKDIR /src

RUN apk add --no-cache gcc musl-dev linux-headers
RUN pip install WSDiscovery netifaces

COPY src/ .

# Default network interface for most containers
ENV NETWORK_INTERFACE="eth0"
ENTRYPOINT ["./entrypoint.sh"]
