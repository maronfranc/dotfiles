#!/bin/bash
# Usage: run-gradle-test [args...]
# Examples:
#   1. run-gradle-test (interactively select a test file)
#   2. run-gradle-test --tests 'com.example.MyTest' (interactively select, then pass extra args)
#
# Uses fzf to select a test file, then calls run-gradle with the test task.

# Check if fzf is installed
if ! command -v fzf &> /dev/null; then
    echo "Error: fzf is not installed. Please install fzf to use this script."
    exit 1
fi

C_NC=$'\033[0m'
C_BLUE=$'\033[34m'
C_RED=$'\033[31m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Try to find run-gradle.sh in various locations
if [ -f "${SCRIPT_DIR}/run-gradle.sh" ]; then
    RUN_GRADLE="${SCRIPT_DIR}/run-gradle.sh"
elif [ -f "${SCRIPT_DIR}/java/run-gradle.sh" ]; then
    RUN_GRADLE="${SCRIPT_DIR}/java/run-gradle.sh"
elif [ -f "${SCRIPT_DIR}/run-gradle" ]; then
    RUN_GRADLE="${SCRIPT_DIR}/run-gradle"
elif command -v run-gradle.sh &> /dev/null; then
    RUN_GRADLE="$(command -v run-gradle.sh)"
elif command -v run-gradle &> /dev/null; then
    RUN_GRADLE="$(command -v run-gradle)"
elif command -v java-run-gradle &> /dev/null; then
    RUN_GRADLE="$(command -v java-run-gradle)"
else
    echo "${C_RED}Error: Could not find run-gradle.sh. Make sure it's installed or in your PATH.${C_NC}"
    exit 1
fi

# Collect extra args (everything after the script name, excluding 'test')
EXTRA_ARGS=("$@")

# Find all test files (Java/Kotlin) and filter through fzf
TEST_FILE=$(find . -type f \( -name '*Test.java' -o -name '*Tests.java' -o -name '*Test.kt' -o -name '*Tests.kt' \) | \
    sed 's|^\./||' | \
    fzf --prompt="Select test file: " --preview="head -100 {}")

if [ -z "${TEST_FILE}" ]; then
    echo "${C_RED}No file selected. Aborting.${C_NC}"
    exit 1
fi

# Convert file path to test class filter if no --tests already in EXTRA_ARGS
CLASS_FILTER=""
if [[ ! " ${EXTRA_ARGS[@]} " =~ "--tests" ]]; then
    # Extract the package and class name from the file path
    # e.g., src/test/java/com/example/MyTest.java -> com.example.MyTest
    PACKAGE=$(dirname "${TEST_FILE}" | sed 's|^src/test/java/||; s|^src/test/kotlin/||' | tr '/' '.')
    CLASS_NAME=$(grep -m1 -oP '^\s*(public|private|protected|static|abstract|final|\s)*\s*class\s+\K\w+' "${TEST_FILE}")
    if [ -z "${CLASS_NAME}" ]; then
        CLASS_NAME=$(basename "${TEST_FILE}" | sed 's/Tests\.java$//; s/Test\.java$//; s/Tests\.kt$//; s/Test\.kt$//; s/\.java$//; s/\.kt$//')
    fi
    
    if [ -n "${PACKAGE}" ]; then
        CLASS_FILTER="${PACKAGE}.${CLASS_NAME}"
    else
        CLASS_FILTER="${CLASS_NAME}"
    fi
fi

echo "Running ${C_BLUE}run-gradle test${C_NC} with selected file: ${C_BLUE}${TEST_FILE}${C_NC}"

if [ -n "${CLASS_FILTER}" ]; then
    "${RUN_GRADLE}" test --tests "${CLASS_FILTER}" "${EXTRA_ARGS[@]}"
else
    "${RUN_GRADLE}" test "${EXTRA_ARGS[@]}"
fi
