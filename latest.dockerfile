FROM registry.gitlab.com/tozd/docker/dinit:ubuntu-jammy

VOLUME /var/log/etherpad

EXPOSE 9001/tcp

ENV LOG_TO_STDOUT=0

COPY ./etherpad-lite /etherpad

RUN apt-get update -q -q && \
  apt-get install --yes --force-yes ca-certificates curl gnupg adduser tidy abiword git curl python3 pkg-config build-essential pwgen && \
  mkdir -p /etc/apt/keyrings && \
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" > /etc/apt/sources.list.d/nodesource.list && \
  apt-get update -q -q && \
  apt-get install --yes --force-yes nodejs && \
  adduser --system --group etherpad --home /home/etherpad && \
  cd /etherpad && \
  ./bin/installDeps.sh && \
  apt-get purge --yes --force-yes --auto-remove git curl python3 pkg-config build-essential && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache ~/.npm

COPY ./etc/service/etherpad /etc/service/etherpad
