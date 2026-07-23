#!/usr/bin/env bash

function docker_ip() {
  local container_name=$1
  # TODO: check for `network_mode: "host"` on container and print 127.0.0.1 instead of `invalid IP`.
  # TODO: get container names and add options_select.
  docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $container_name
}

alias dockercompose-reup="docker compose down --volumes && docker-compose up -d"

alias lazypodman="DOCKER_HOST=unix://$XDG_RUNTIME_DIR/podman/podman.sock lazydocker"

export HISTIGNORE="${HISTIGNORE:+$HISTIGNORE:}\
docker compose up -d\
:docker compose down\
:dockercompose-reup\
:docker system prune\
:docker_ip\
:lazydocker:lazypodman\
"
