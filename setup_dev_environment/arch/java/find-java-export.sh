#!/usr/bin/env bash

# Find the correct JAVA_HOME path dynamically
find_java_home() {
    # Look for java directories in /usr/lib/jvm
    local java_dirs=$(find /usr/lib/jvm -maxdepth 1 -name "java-*" -type d 2>/dev/null)

    if [ -z "$java_dirs" ]; then
        echo "Error: No Java directories found in /usr/lib/jvm"
        exit 1
    fi

    # Get the first directory (usually the latest version)
    local java_home=$(echo "$java_dirs" | head -n 1)

    # Extract just the directory name
    local java_dir_name=$(basename "$java_home")

    echo "➡  Add following exports to ~/.bashrc:"
    echo "export JAVA_HOME=/usr/lib/jvm/$java_dir_name"
    echo "export PATH=\$JAVA_HOME/bin:\$PATH"
}

find_java_home
