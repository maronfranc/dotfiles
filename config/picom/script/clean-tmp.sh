#!/usr/bin/env bash

# Delete tmp after 60 minutes
find /tmp/i3_dim -type f -mmin +60 -delete
