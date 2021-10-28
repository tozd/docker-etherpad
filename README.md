# tozd/etherpad

<https://gitlab.com/tozd/docker/etherpad>

Available as:

* [`tozd/etherpad`](https://hub.docker.com/r/tozd/etherpad)
* [`registry.gitlab.com/tozd/docker/etherpad`](https://gitlab.com/tozd/docker/etherpad/container_registry)

## Description

You can mount Etherpad's `settings.json` file into `/etherpad/settings.json` inside the container.

Alternatively, you can set environment variables which will then Etherpad substitute in settings template
at the first run. See [the template](./etherpad-lite/settings.json.template) and available environment variables.