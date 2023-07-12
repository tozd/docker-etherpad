FROM registry.gitlab.com/tozd/docker/dinit:ubuntu-jammy

VOLUME /var/log/etherpad

EXPOSE 9001/tcp

COPY ./etherpad-lite /etherpad

RUN apt-get update -q -q && \
  apt-get install --yes --force-yes nodejs npm adduser tidy abiword git curl python3 pkg-config build-essential pwgen && \
  adduser --system --group etherpad --home /home/etherpad && \
  cd /etherpad && \
  ./bin/installDeps.sh && \
  for MODULE in /etherpad/node_modules/*; do \
  chmod o+tw "${MODULE}"; \
  done && \
  apt-get purge --yes --force-yes --auto-remove git curl python3 pkg-config build-essential && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache ~/.npm

COPY ./etc/service/etherpad /etc/service/etherpad
