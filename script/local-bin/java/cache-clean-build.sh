#!/usr/bin/env bash
# Strict mode: fail fast and loudly.
set -e          # Stop on first error.
set -u          # Disallow unset variables.
set -o pipefail # Propagate pipeline failures.
# NOTE: depends on ./run-gradle.sh

echo "=== Java Dependency Cache Cleaner & Rebuilder ==="
echo "WARNING: This will DELETE Gradle caches."
echo "• java-run-gradle --stop || true"
echo "• find . -type d -name "build" -exec rm -rf {} +"
echo "• rm -rf .gradle"
echo "• rm -rf $HOME/.gradle/caches"
echo "• java-run-gradle clean"
echo "• java-run-gradle build --refresh-dependencies"

read -rp "Continue? (y/N): " response
if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  echo "Doing nothing."
  exit 0
fi

PROJECT_DIR=$(pwd)
echo "Project directory: $PROJECT_DIR"

# Stop Gradle daemons.
echo "Stopping Gradle daemons..."
java-run-gradle --stop || true

# Remove project build directories.
echo "Removing build/ directories..."
find . -type d -name "build" -exec rm -rf {} +

# Remove project .gradle cache.
echo "Removing .gradle/..."
rm -rf .gradle

# Remove global Gradle cache.
echo "Removing ~/.gradle/caches..."
sudo rm -rf "$HOME/.gradle/caches"

# Clean and rebuild.
echo "Running gradlew clean..."
java-run-gradle clean

echo "Rebuilding project with fresh dependencies..."
java-run-gradle build --refresh-dependencies

echo "=== Done! Project rebuilt with fresh dependencies ==="
