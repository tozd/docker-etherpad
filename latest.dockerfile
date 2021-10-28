FROM registry.gitlab.com/tozd/docker/runit:ubuntu-focal

EXPOSE 9001/tcp

RUN apt-get update -q -q && \
 apt-get install --yes --force-yes nodejs npm adduser git gzip curl python pkg-config build-essential tidy abiword pwgen && \
 adduser --system --group etherpad --home /home/etherpad

COPY ./etherpad-lite /etherpad
COPY ./plugins /etherpad-plugins

RUN cd /etherpad && \
 npm install /etherpad-plugins/* && \
 ./bin/installDeps.sh && \
 for PLUGIN in /etherpad-plugins/*; do \
   ln -s /etherpad/node_modules "${PLUGIN}/node_modules"; \
 done && \
 for MODULE in /etherpad/node_modules/*; do \
   chmod o+tw "${MODULE}"; \
 done

COPY ./etc /etc
