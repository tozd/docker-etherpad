FROM node:24.22.1-alpine3.24 AS adminbuild

COPY ./etherpad /etherpad

WORKDIR /etherpad

# The pnpm version has to match "packageManager" in etherpad/package.json.
RUN npm install -g pnpm@12.4.2 && \
  pnpm install && \
  pnpm run build:ui

FROM registry.gitlab.com/tozd/docker/dinit:ubuntu-noble

VOLUME /var/log/etherpad

EXPOSE 9001/tcp

ENV LOG_TO_STDOUT=0
ENV NODE_ENV=production
ENV ETHERPAD_PRODUCTION=true
# Etherpad calls pnpm at runtime and pnpm should not try to download a different version.
ENV pnpm_config_pm_on_fail=ignore

COPY ./etherpad /etherpad
COPY --from=adminbuild /etherpad/src/templates/admin /etherpad/src/templates/admin
COPY --from=adminbuild /etherpad/src/static/oidc /etherpad/src/static/oidc

# Admin and UI workspace packages are not needed at runtime, so pnpm-workspace.yaml is
# replaced with a production-only version. Dependencies are installed as root but Etherpad
# runs pnpm at runtime as the etherpad user, so files pnpm writes (some with 0600 mode)
# have to be made readable.
RUN apt-get update -q -q && \
  apt-get install --yes --force-yes ca-certificates curl gnupg adduser pwgen && \
  mkdir -p /etc/apt/keyrings && \
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_24.x nodistro main" > /etc/apt/sources.list.d/nodesource.list && \
  apt-get update -q -q && \
  apt-get install --yes --force-yes nodejs && \
  npm install -g pnpm@12.4.2 && \
  adduser --system --group etherpad --home /home/etherpad && \
  cd /etherpad && \
  rm -f .git && \
  printf 'packages:\n  - src\n  - bin\nallowBuilds:\n  esbuild: true\n  "@scarf/scarf": false\nstrictDepBuilds: false\n' > pnpm-workspace.yaml && \
  ./bin/installDeps.sh && \
  mkdir -p src/plugin_packages && \
  chmod -R a+rX /etherpad && \
  apt-get purge --yes --force-yes --auto-remove curl gnupg && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache ~/.npm ~/.local/share/pnpm

COPY ./etc /etc
