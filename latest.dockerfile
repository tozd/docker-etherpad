FROM registry.gitlab.com/tozd/docker/runit:ubuntu-jammy

EXPOSE 9001/tcp

COPY ./etherpad-lite /etherpad
COPY ./plugins /etherpad-plugins

RUN apt-get update -q -q && \
  apt-get install --yes --force-yes nodejs npm adduser tidy abiword git curl python2 pkg-config build-essential pwgen && \
  adduser --system --group etherpad --home /home/etherpad && \
  cd /etherpad && \
  npm install /etherpad-plugins/* && \
  ./bin/installDeps.sh && \
  for PLUGIN in /etherpad-plugins/*; do \
  ln -s /etherpad/node_modules "${PLUGIN}/node_modules"; \
  done && \
  for MODULE in /etherpad/node_modules/*; do \
  chmod o+tw "${MODULE}"; \
  done && \
  apt-get purge --yes --force-yes --auto-remove git curl python2 pkg-config build-essential && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache ~/.npm

COPY ./etc/service/etherpad /etc/service/etherpad
