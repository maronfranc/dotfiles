#!/usr/bin/env bash

set -e  # exit on error

echo "=== Java Dependency Cache Cleaner & Rebuilder ==="

PROJECT_DIR=$(pwd)

echo "Project directory: $PROJECT_DIR"

# पुष्टि function
confirm() {
  read -rp "$1 (y/N): " response
  [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
}

# 1. Stop Gradle daemons
echo "Stopping Gradle daemons..."
./gradlew --stop || true

# 2. Remove project build directories
if confirm "Delete local build directories (build/)?"; then
  echo "Removing build/ directories..."
  find . -type d -name "build" -exec rm -rf {} +
fi

# 3. Remove Gradle project cache
if confirm "Delete project .gradle cache?"; then
  echo "Removing .gradle/..."
  rm -rf .gradle
fi

# 4. Remove global Gradle cache
GRADLE_CACHE="$HOME/.gradle/caches"
if confirm "Delete GLOBAL Gradle cache (~/.gradle/caches)?"; then
  echo "Removing $GRADLE_CACHE ..."
  rm -rf "$GRADLE_CACHE"
fi

# 5. Optional: Maven cache (some Spring Boot setups still use it)
MAVEN_CACHE="$HOME/.m2/repository"
if confirm "Delete Maven cache (~/.m2/repository)?"; then
  echo "Removing $MAVEN_CACHE ..."
  rm -rf "$MAVEN_CACHE"
fi

# 6. Clean Gradle wrapper
echo "Running gradlew clean..."
./gradlew clean

# 7. Rebuild dependencies and project
echo "Rebuilding project..."
./gradlew build --refresh-dependencies

echo "=== Done! Project rebuilt with fresh dependencies ==="
