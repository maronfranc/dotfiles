#!/bin/bash

alias portlist="netstat -np"

port_kill() {
  if [ -z "$1" ]; then
    echo '   Please provide the port number like "port_kill 3000"'
  else
    port=$1
    echo "   Killing any processes using port $port..."
    lsof -ti:$port | xargs -r kill -9
    #   kill -9 $(lsof -t -i:"$PORT" -sTCP:LISTEN)
  fi
}
