FROM registry.gitlab.com/tozd/docker/dinit:ubuntu-jammy

VOLUME /var/log/etherpad

EXPOSE 9001/tcp

ENV LOG_TO_STDOUT=0

COPY ./etherpad-lite /etherpad

RUN apt-get update -q -q && \
  apt-get install --yes --force-yes nodejs npm adduser tidy abiword git curl python3 pkg-config build-essential pwgen && \
  adduser --system --group etherpad --home /home/etherpad && \
  cd /etherpad && \
  ./bin/installDeps.sh && \
  apt-get purge --yes --force-yes --auto-remove git curl python3 pkg-config build-essential && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache ~/.npm

COPY ./etc/service/etherpad /etc/service/etherpad
