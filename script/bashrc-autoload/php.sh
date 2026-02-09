# alias createlaravel_project="composer create-project laravel/laravel"
export PATH="$PATH:$HOME/.config/composer/vendor/bin"

createlaravel_project() {
    local placeholder="<placeholder-project-name>"
    local C_GRAY="\e[90m"
    local C_NC="\e[0m"

    # Show placeholder
    echo -ne "Enter Laravel project name: ${C_GRAY}${placeholder}${C_NC}\r"
    echo -ne "Enter Laravel project name: "
    read project_name

    if [[ -z "$project_name" ]]; then
        echo "Error: Project name cannot be empty."
        return 1
    fi

    if [[ "$project_name" =~ [[:space:]] ]]; then
        echo "Error: Project name cannot contain spaces."
        return 1
    fi

    echo "Creating Laravel project: $project_name"
    composer create-project laravel/laravel "$project_name"
}

alias composer_install="composer install --no-dev --prefer-dist"

phpart() {
  local dir="$PWD"

  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/artisan" ]]; then
      php "$dir/artisan" "$@"
      return
    fi
    dir="$(dirname "$dir")"
  done

  echo "artisan: not inside a Laravel project"
  return 1
}
