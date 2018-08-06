FROM node:alpine

RUN npm install bonjour minimist --save

WORKDIR /src

COPY src/ .

# Default network interface for most containers
ENV NETWORK_INTERFACE="eth0"
ENV SERVICE_NAME="sd1"
ENTRYPOINT ["./entrypoint.sh"]
