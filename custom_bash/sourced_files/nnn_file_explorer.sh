#!/usr/bin/env bash
# SEE: https://github.com/jarun/nnn/tree/master/plugins#installation
# SEE: https://github.com/jarun/nnn/wiki/Basic-use-cases
alias fe="nnn"

# | ----------------------------------- |
# |             NNN_OPTS                |
# | Flag | Meaning                      |
# | ---- | ---------------------------- |
# | `H`  | Show hidden files            |
# | `c`  | Use colors                   |
# | `d`  | Detail view                  |
# | `a`  | Auto-enter directories       |
# | `r`  | Use reverse sort             |
# | `x`  | Use hex colors               |
# | `Q`  | Disable confirmation prompts |
# | `H`  | always show hidden files. (Default toggle with ".") |
export NNN_OPTS="cdx"
# Colors (4-digit format: directory, executable, link, fifo/socket)
# 8 colors numbers: 0-black, 1-red, 2-green, 3-yellow, 4-blue (default), 5-magenta, 6-cyan, 7-white.
export NNN_COLORS="7777"
