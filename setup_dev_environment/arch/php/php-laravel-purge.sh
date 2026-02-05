#!/usr/bin/env bash
set -Eeuo pipefail

read -rp "⚠️ Purge PHP, Composer & Laravel completely? [y/N]: " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || exit 0

BACKUP="/tmp/php-purge-backup-$(date +%F-%H%M).tar.gz"

echo "==> Backing up PHP configs to $BACKUP"
sudo tar -czf "$BACKUP" /etc/php /var/lib/php /var/log/php_errors.log 2>/dev/null || true

echo "==> Removing Laravel & Composer user data"
rm -rf "$HOME/.config/composer" "$HOME/.composer"

echo "==> Removing PHP packages"
sudo pacman -Rns --noconfirm \
    php php-fpm php-curl php-mbstring php-zip php-xml \
    php-gd php-intl php-bcmath composer || true

echo "==> Removing PHP directories"
sudo rm -rf /etc/php /var/lib/php /var/log/php_errors.log

echo "==> Checking PHP-related orphan packages"
orphans=$(pacman -Qtdq | grep -E 'php|icu|oniguruma' || true)

if [[ -n "$orphans" ]]; then
  echo "Found PHP-related orphans:"
  echo "$orphans"
  read -rp "Remove these? [y/N]: " oconfirm
  [[ "$oconfirm" =~ ^[Yy]$ ]] && sudo pacman -Rns $orphans
fi

echo "==> Verification"
command -v php >/dev/null && echo "❌ PHP still present" || echo "✔ PHP removed"
command -v composer >/dev/null && echo "❌ Composer still present" || echo "✔ Composer removed"

echo "🧹 PHP & Laravel purged safely"
