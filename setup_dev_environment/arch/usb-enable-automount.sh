# USB stick auto-mount on plug: `/run/media/$USER/<label>`
sudo pacman -S udisks2 udiskie
sudo systemctl enable --now udisks2.service
# systemctl status udisks2

# Enable in i3wm_config: `exec --no-startup-id udiskie --automount --notify`
# udisksctl unmount -b /dev/sdX1
# udisksctl power-off -b /dev/sdX
