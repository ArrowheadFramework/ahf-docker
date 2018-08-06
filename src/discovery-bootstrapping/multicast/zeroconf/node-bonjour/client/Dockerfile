FROM node:alpine

RUN npm install bonjour --save

ENV TIMEOUT="5"

WORKDIR /src

COPY src/ .

ENTRYPOINT ["./entrypoint.sh"]
