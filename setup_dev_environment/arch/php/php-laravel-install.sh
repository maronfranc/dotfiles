#!/usr/bin/env bash
set -Eeuo pipefail

echo "==> Updating system"
sudo pacman -Syu --noconfirm

echo "==> Installing PHP + required extensions"
sudo pacman -S --noconfirm \
    php \
    php-fpm \
    composer

echo "==> Backing up php.ini"
sudo cp /etc/php/php.ini /etc/php/php.ini.bak.$(date +%F)

echo "==> Hardening PHP configuration"
sudo sed -i \
  -e 's/^expose_php = On/expose_php = Off/' \
  -e 's/^display_errors = On/display_errors = Off/' \
  -e 's/^;log_errors = On/log_errors = On/' \
  -e 's/^;error_log = php_errors.log/error_log = \/var\/log\/php_errors.log/' \
  -e 's/^;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' \
  -e 's/^memory_limit = .*/memory_limit = 256M/' \
  /etc/php/php.ini

sudo touch /var/log/php_errors.log
sudo chown root:http /var/log/php_errors.log
sudo chmod 640 /var/log/php_errors.log

echo "==> Installing Laravel installer (no scripts)"
composer global require laravel/installer --no-scripts --no-interaction

COMPOSER_BIN="$HOME/.config/composer/vendor/bin"

echo "==> Ensuring Composer bin exists"
mkdir -p "$COMPOSER_BIN"

echo "==> Add this to your shell config manually (recommended):"
echo "    export PATH=\"\$PATH:$COMPOSER_BIN\""

echo "==> Enabling PHP-FPM (not started yet)"
sudo systemctl enable php-fpm.service

echo "✅ Hardened PHP + Laravel install complete"
