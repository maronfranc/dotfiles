#!/usr/bin/env bash

set -e

echo "Updating system..."
sudo apt update && sudo apt upgrade -y

echo "Installing prerequisites..."
sudo apt install -y software-properties-common curl unzip git

echo "Adding Ondřej Surý PHP PPA..."
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update

echo "Installing latest PHP and common extensions..."
sudo apt install -y \
  php \
  php-cli \
  php-common \
  php-curl \
  php-mbstring \
  php-xml \
  php-zip \
  php-bcmath \
  php-mysql \
  php-sqlite3

echo "PHP version installed:"
php -v

echo "Installing Composer..."
EXPECTED_SIGNATURE="$(curl -s https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then
    echo "ERROR: Invalid Composer installer signature"
    rm composer-setup.php
    exit 1
fi

php composer-setup.php --quiet
rm composer-setup.php
sudo mv composer.phar /usr/local/bin/composer

echo "Composer version installed:"
composer --version

echo "Installing Laravel installer..."
composer global require laravel/installer

# Ensure Composer global bin is in PATH
COMPOSER_BIN="$HOME/.config/composer/vendor/bin"
if ! grep -q "$COMPOSER_BIN" ~/.bashrc; then
    echo "export PATH=\"$COMPOSER_BIN:\$PATH\"" >> ~/.bashrc
fi

export PATH="$COMPOSER_BIN:$PATH"

echo "Laravel version installed:"
laravel --version

echo "Installation complete!"
echo "You may need to run: source ~/.bashrc"

sudo systemctl stop apache2
sudo systemctl disable apache2
