# Dotfiles

My personal Linux dotfiles, configured for an i3wm-based tiling window manager setup with a focus on terminal tools, developer productivity, and a clean minimal aesthetic.

## Stack

- **Window Manager:** i3wm
- **Shell:** Bash
- **Terminal:** Alacritty or Ghostty
- **Bar:** Polybar
- **Status Notifications:** Dunst
- **Compositor:** Picom
- **File Manager:** Yazi (TUI)
- **Tmux:** Custom config with dev environment support

## Directory Structure

```
├── config/          # Per-application configuration files
│   ├── alacritty/   # Terminal emulator (alacritty.toml)
│   ├── ghostty/     # Terminal emulator (ghostty config)
│   ├── i3wm/        # i3 window manager config
│   ├── polybar/     # Taskbar/status bar
│   ├── dunst/       # Notification daemon
│   ├── picom/       # Compositor
│   ├── tmux/        # Tmux session manager
│   ├── mpv/         # Media player
│   ├── imv/         # Image viewer
│   ├── zathura-mupdf/ # PDF viewer
│   ├── lazygit/     # Git TUI
│   ├── fastfetch/   # System info display
│   ├── fonts/       # Custom font installer
│   └── gnome/       # GTK settings / gsettings
├── script/          # Utility scripts
│   ├── bashrc-autoload/   # Bashrc helper functions (git, docker, node, python, etc.)
│   ├── local-bin/         # Custom shell scripts (screenshot, image tools, notes)
│   ├── startup-scripts/   # Login startup utilities (keyboard, mouse)
│   ├── not-in-use/        # Legacy / retired scripts
│   ├── load-bashrc-files.sh
│   ├── load-local-bins.sh
│   ├── load-usr-bin.sh
│   └── bashrc-source-files.sh
├── setup_dev_environment/  # Dev environment provisioning scripts
│   ├── apt/           # Debian/Ubuntu packages (neovim, tmux, docker, yazi, php-laravel)
│   └── arch/          # Arch Linux setup (docker-nvidia-llm, lightdm login)
└── backup/            # Backup of configs
```

## Quick Start

### Load all configs

```bash
./config/load-configs.sh
```

### Bash helpers

The `bashrc-autoload/` directory contains modular bash functions. Source them in your `.bashrc`:

```bash
source ~/dotfiles/script/bashrc-source-files.sh
```

### Custom scripts

Local binaries in `script/local-bin/` can be symlinked into your `PATH`:

```bash
./script/load-local-bins.sh
```

## Dev Environment

Platform-specific setup scripts under `setup_dev_environment/`:

| Platform | Scripts |
|----------|---------|
| Debian/Ubuntu (apt) | `neovim.sh`, `tmux.sh`, `docker-and-compose.sh`, `install-yazi.sh`, `php-laravel.sh` |
| Arch Linux | `docker-nvidia-llm-setup.sh`, `login-lightdm.sh`, `usb-enable-automount.sh` |

## License

MIT - see [LICENSE](LICENSE)
