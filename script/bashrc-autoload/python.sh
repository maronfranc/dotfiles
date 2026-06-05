#!/usr/bin/env bash

alias python='python3'
alias pp='python3'
alias pip='pip3'
alias pipinstallRequirementHere='pip install -r ./requirements.txt'

alias uv_help='echo "• Create project / init
${C_CYAN}uv init${C_NC}
${C_CYAN}uv init myproject${C_NC}
• Create virtual environment
${C_CYAN}uv venv${C_NC}
${C_CYAN}uv venv .venv${C_NC}
• Install dependencies
${C_CYAN}uv add requests${C_NC}
${C_CYAN}uv add pytest --dev${C_NC}
• Remove dependencies
${C_CYAN}uv remove requests${C_NC}
• Sync dependencies from lockfile
${C_CYAN}uv sync${C_NC}
• Run Python or scripts
${C_CYAN}uv run python main.py${C_NC}
${C_CYAN}uv run pytest${C_NC}
• Run a tool without installing globally
${C_CYAN}uvx ruff check .${C_NC}
${C_CYAN}uvx black .${C_NC}
• Install Python versions
${C_CYAN}uv python install 3.12${C_NC}
• List installed Python versions
${C_CYAN}uv python list${C_NC}
• Lock dependencies
${C_CYAN}uv lock${C_NC}
• Upgrade packages
${C_CYAN}uv lock --upgrade${C_NC}
• Show dependency tree
${C_CYAN}uv tree${C_NC}
• Export requirements.txt
${C_CYAN}uv export -o requirements.txt"${C_NC}'
