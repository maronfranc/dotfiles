#!/usr/bin/env bash

function docker_ip() {
  local container_name=$1
  # TODO: get container names and add options select.
  docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $container_name
}

alias docker-compose="docker compose"
alias docker-compose-reup="docker compose down && docker-compose up -d"
# alias kubectl="minikube kubectl -- "
