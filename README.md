# tozd/etherpad

<https://gitlab.com/tozd/docker/etherpad>

Available as:

- [`tozd/etherpad`](https://hub.docker.com/r/tozd/etherpad)
- [`registry.gitlab.com/tozd/docker/etherpad`](https://gitlab.com/tozd/docker/etherpad/container_registry)

## Image inheritance

[`tozd/base`](https://gitlab.com/tozd/docker/base) ← [`tozd/runit`](https://gitlab.com/tozd/docker/runit) ← `tozd/etherpad`

## Tags

- `latest`: Etherpad Lite 1.7.5 with [ep_tables2](https://github.com/seballot/ep_tables2) plugin

## Volumes

- `/var/log/etherpad`: log files

## Ports

- `9001/tcp`: HTTP port on which Etherpad listens.

## Description

You can mount Etherpad's `settings.json` file into `/etherpad/settings.json` inside the container.

Alternatively, you can set environment variables which will then Etherpad substitute in settings template
at the first run. See [the template](https://github.com/tozd/etherpad-lite/blob/develop/settings.json.template) and available environment variables.
