#!/bin/bash
# Purge Java and Kotlin packages and remove orphaned dependencies.
# This script will remove installed packages and clean up orphans.
set -e # Stop on first error.

java_version=25
echo "Purging Java $java_version and Kotlin packages..."
echo "Removing Java $java_version and Kotlin packages..."
sudo pacman -Rns "jdk$java_version-openjdk" kotlin --noconfirm

echo "Removing orphaned packages..."
orphaned_packages=$(pacman -Qtdq)
if [ -n "$orphaned_packages" ]; then
    sudo pacman -Rns $orphaned_packages --noconfirm
else
    echo "No orphaned packages found."
fi

# Verify cleanup.
echo "Checking for remaining Java or Kotlin packages..."
if pacman -Q | grep -E "(java|kotlin)" >/dev/null; then
    echo "Warning: Some Java or Kotlin packages remain installed."
    pacman -Q | grep -E "(java|kotlin)"
else
    echo "All Java and Kotlin packages successfully removed."
fi

# Check for orphaned packages.
echo "Checking for orphaned packages..."
orphan_count=$(pacman -Qtdq | wc -l)
if [ "$orphan_count" -eq 0 ]; then
    echo "No orphaned packages found."
else
    echo "Found $orphan_count orphaned packages. They should have been removed."
fi

echo "Purge complete!"
