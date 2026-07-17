#!/bin/bash

alias createreact_app="pnpm create vite@latest"
alias createnext_app="pnpm create next-app"
alias createsvelte_app="pnpm create svelte@latest"
alias pndev="pnpm run dev"
alias npx="pnpx"

# Prompt for AstroJS project name.
createastro() {
    read -p "Enter AstroJS project name: " project_name
    # Create AstroJS project using pnpm.
    pnpm create astro@latest "$project_name"

    # Check if project was created successfully.
    if [ $? -ne 0 ]; then
        echo "Failed to create project '$project_name'."
        return
    fi

    echo "Project '$project_name' created successfully."

    # Change to project directory.
    cd "$project_name"

    # Disable astro telemetry.
    npx astro telemetry disable

    echo "Telemetry disabled for the project."
}

export HISTIGNORE="${HISTIGNORE:+$HISTIGNORE:}\
npm run build\
:pnpm run build\
:createreact_app\
:createnext_app\
:createsvelte_app\
:createastro_app\
:create_astro\
"
