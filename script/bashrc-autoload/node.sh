#!/bin/bash

alias createreact_app="pnpm create vite@latest"
alias createnext_app="pnpm create next-app"
alias createsvelte_app="pnpm create svelte@latest"
alias createastro_app="pnpm create astro@latest"
alias pndev="pnpm run dev"
alias npx="pnpx"

# Prompt for AstroJS project name
create_astro() {
    read -p "Enter AstroJS project name: " project_name
    # Create AstroJS project using pnpm.
    pnpm create astro@latest "$project_name"

    # Check if project was created successfully.
    if [ $? -ne 0 ]; then
        echo "Failed to create project '$project_name'."
        exit 1
    fi

    echo "Project '$project_name' created successfully."

    # Change to project directory.
    cd "$project_name"

    # Disable astro telemetry.
    npx astro telemetry disable

    echo "Telemetry disabled for the project."
}
