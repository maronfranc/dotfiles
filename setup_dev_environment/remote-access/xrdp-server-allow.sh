#!/usr/bin/env bash
# Dependency: tigervnc

x11vnc -display :0 -forever -auth guess
