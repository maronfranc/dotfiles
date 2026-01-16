#!/usr/bin/env bash

# TODO: add to startup-script.
# https://unix.stackexchange.com/questions/684540/how-can-i-have-the-right-ctrl-key-behave-as-the-left-ctrl-key
# - Comment: https://unix.stackexchange.com/a/685816
function xsetrightctrl() {
    xmodmap -e "keycode 105 = Control_R NoSymbol Control_R"
    xmodmap -e "add control = Control_R"
}
alias xmodsetrightctrl="xsetrightctrl"
alias xinit="xsetrightctrl && xsetled"
