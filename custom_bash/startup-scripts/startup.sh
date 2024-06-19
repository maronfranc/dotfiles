#!/bin/bash

# Wait so system can start
spd-say "Push mee..."
spd-say "... and then just touch mee..."
spd-say "... till I can get myy..."
spd-say "... satisfaction"

# https://unix.stackexchange.com/questions/684540/how-can-i-have-the-right-ctrl-key-behave-as-the-left-ctrl-key
# - Comment: https://unix.stackexchange.com/a/685816
xmodmap -e "keycode 105 = Control_R NoSymbol Control_R"
xmodmap -e "add control = Control_R"
xset led named "Scroll Lock"

spd-say "Startup complete."
# https://stackoverflow.com/questions/12973777/how-to-run-a-shell-script-at-startup
