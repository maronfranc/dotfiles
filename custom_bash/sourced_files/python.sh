#!/usr/bin/env bash

alias python_env_source='source ~/main_env/bin/activate'
# TODO: talib is not working with python 3.11. Check if is fixed in the future.
# alias conda_env_create='conda create python=3.12 -n "test_env"'
alias condalist='conda info --envs'

alias python='python3'
alias pp='python3'
alias pip='pip3'
alias pipinstallRequirementHere='pip install -r ./requirements.txt'
# alias conda_auto_start_disable='conda config --set auto_activate_base false'
# alias conda_auto_start_enable="conda init --reverse $SHELL"
# alias condaREMOVE_ENV="conda remove -n ENV_NAME --all"

alias condaprompt="conda activate prompt && echo  CMD: conda activate prompt"
alias condatrd="conda activate trd && echo  CMD: conda activate trd"
alias condaaAL="conda activate AL && echo  CMD: conda activate AL"
