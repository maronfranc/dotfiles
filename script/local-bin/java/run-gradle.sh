#!/bin/bash
# Usage: run-gradle <task> [args...]
# Examples:
#   1. run-gradle build
#   2. run-gradle test --tests 'com.example.MyTest'
#   3. run-gradle build -x test
#   4. run-gradle build -x test --refresh-dependencies
#   5. run-gradle dependencies --configuration compileClasspath
#   9. ...all other `./gradlew` commands.
TASK="${1:-bootRun}" # Set `bootRun` as default.
# Shift the first argument so "$@" contains any additional args.
shift

C_NC=$'\033[0m' # Reset color | No color.
C_BLUE=$'\033[34m'
C_RED=$'\033[31m'

# Function to detect Gradle project root.
find_gradle_root() {
    local current_dir="$(pwd)"
    
    while [ "${current_dir}" != "/" ]; do
        if [ -f "${current_dir}/build.gradle" ] || [ -f "${current_dir}/build.gradle.kts" ]; then
            echo "${current_dir}"
            return 0
        fi
        current_dir="$(dirname "${current_dir}")"
    done
    return 1
}

GRADLE_ROOT=$(find_gradle_root)

if [ $? -eq 0 ] && [ -n "${GRADLE_ROOT}" ]; then
    cd "${GRADLE_ROOT}" || exit 1
    
    if [ -f "./gradlew" ]; then
        echo "Running ${C_BLUE}'./gradlew $TASK'${C_NC} in: ${C_BLUE}${GRADLE_ROOT}${C_NC}"
        ./gradlew "${TASK}" "$@"
    else
        echo "${C_RED}Error: Gradle wrapper (gradlew) not found in project root.${C_NC}"
        exit 1
    fi
else
    echo "${C_RED}No Gradle project found in the current directory or its parents.${C_NC}"
    exit 1
fi
