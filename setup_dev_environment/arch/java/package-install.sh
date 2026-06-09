#!/bin/bash
# Install Java 25 and Kotlin compiler.
# This script will install OpenJDK 25 and Kotlin compiler.
set -e # Stop on first error

echo "Updating package lists..."
sudo pacman -Syu --noconfirm

java_version=21
echo "Installing OpenJDK $java_version..."
sudo pacman -S "jdk$java_version-openjdk" --noconfirm

echo "Installing Kotlin compiler..."
sudo pacman -S kotlin --noconfirm

echo "Verifying installations..."
java -version
kotlin -version

echo "Installation complete!"

# export JAVA_HOME=/usr/lib/jvm/java-25-openjdk
