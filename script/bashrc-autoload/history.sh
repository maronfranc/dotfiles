# Number of commands to keep in memory
HISTSIZE=2000 # Default: 500
# Number of commands to save to ~/.bash_history
HISTFILESIZE=2000 # Default: 500
# Append history instead of overwriting it
shopt -s histappend
# Write history after each command
PROMPT_COMMAND='history -a'

export HISTCONTROL=ignoredups
