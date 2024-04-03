#!/bin/bash

alias portlist="netstat -np"
function portkill() {
  PORT=$1
  kill -9 $(lsof -t -i:"$PORT" -sTCP:LISTEN)
}
