FROM openjdk:8-jre

RUN apt-get update && apt-get install -y --no-install-recommends \
		dnsutils \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /ahf

RUN wget http://smartbearsoftware.com/distrib/soapui/5.2.1/SoapUI-5.2.1-linux-bin.tar.gz && \
    tar -xvzf SoapUI-5.2.1-linux-bin.tar.gz && \
    rm SoapUI-5.2.1-linux-bin.tar.gz

COPY ./soapui-min-settings.xml .
COPY ./projects projects
COPY ./scripts scripts

VOLUME /tls

ENTRYPOINT ["scripts/entrypoint.sh"]
