#!/usr/bin/env bash

alias javabuild="./gradlew build"
alias javatest="./gradlew test"
# Build skipping test phase.
alias javabuild_dev="./gradlew build -x test"
alias javabuild_devdependencies="./gradlew build -x test --refresh-dependencies"
alias javabuild_dependencies="./gradlew dependencies"
alias javarun="./gradlew bootRun"
javarun_dev() {
    echo "Building and running with hot-reload."

    # Start everything in a subshell so they share a process group
    (
        ./gradlew classes --continuous --quiet &
        ./gradlew bootRun
    ) &
    GROUP_PID=$!

    cleanup() {
        echo "Stopping process group..."
        kill -TERM -"$GROUP_PID" 2>/dev/null
        wait "$GROUP_PID" 2>/dev/null
    }

    trap cleanup INT TERM
    wait "$GROUP_PID"
}

createjava_project() {
    local C_1="$C_CYAN"

    read -p "${C_1}Enter group name${C_NC} (e.g. com.mycompany.library): " group_name
    read -p "${C_1}Enter artifact name${C_NC} (e.g. hiphen-separated-project-words): " artifact_name

    # Get current Java version installed.
    local java_version=$(java -version 2>&1 | head -1 | cut -d'"' -f2 | cut -d'.' -f1)
    # local java_versions_available=$(curl -s https://start.spring.io \
    #     -H "Accept: application/vnd.initializr.v2.1+json" |
    #     jq -r '[.javaVersion.values[].id] | join(",")')

    read -p "${C_1}Enter language [default java]${C_NC} (options: java,kotlin): " language
    local language=${language:-java}

    local package_name="${group_name}.${artifact_name//-/.}"
    local zip_file="${artifact_name}.zip"

    if [ -f "$zip_file" ]; then
        echo "Error: $zip_file already exists. Aborting to avoid overwrite."
        return 1
    fi

    echo "Using package name: $package_name"
    echo "Java version: $java_version | Language: $language"

    # Dependencies:
    # web         -> Spring MVC / REST API support
    # data-jpa    -> ORM with Hibernate + Spring Data repositories
    # postgresql  -> PostgreSQL JDBC driver
    curl https://start.spring.io/starter.zip \
        -d dependencies=web,data-jpa,postgresql \
        -d type=gradle-project \
        -d language="$language" \
        -d javaVersion="$java_version" \
        -d baseDir="$artifact_name" \
        -d artifactId="$artifact_name" \
        -d groupId="$group_name" \
        -d packageName="$package_name" \
        -o "$zip_file"

    unzip "$zip_file"
    rm -rf "$zip_file"
    cd "$artifact_name"
}
