# AGENTS.md

This is a dotfiles configuration project. All edits should be made directly in the local files — changes are automatically reflected at their respective configuration paths (e.g. `~/.config`, `~/.local/bin`, `~/.bashrc`, etc.) via the `load.sh` scripts or `load-configs.sh`.

## How It Works

- `config/<app>/` — Per-application configuration files. Edit the files directly (e.g. `config/i3wm/config`, `config/alacritty/alacritty.toml`, `config/tmux/tmux.conf`).
- `script/` — Utility scripts and bashrc autoload modules.
- `setup_dev_environment/` — Dev environment provisioning scripts for apt and arch platforms.

Run `./config/load-configs.sh` to deploy all configs to their expected locations.

## Key Directories

| Directory | Deploys to |
|---|---|
| `config/i3wm/` | `~/.config/i3/` |
| `config/alacritty/` | `~/.config/alacritty/` |
| `config/ghostty/` | `~/.config/ghostty/` |
| `config/polybar/` | `~/.config/polybar/` |
| `config/picom/` | `~/.config/picom/` |
| `config/dunst/` | `~/.config/dunst/` |
| `config/tmux/` | `~/.config/tmux/` |
| `config/fastfetch/` | `~/.config/fastfetch/` |
| `config/lazygit/` | `~/.local/share/lazygit/` |
| `config/mpv/` | `~/.config/mpv/` |
| `config/imv/` | `~/.config/imv/` |
| `config/zathura-mupdf/` | `~/.config/zathura/` |
| `config/gnome/` | gsettings / GTK configs |
| `script/local-bin/` | `~/.local/bin/` |
| `script/bashrc-autoload/` | sourced from `~/.bashrc` |

## Guidelines

- Edit config files in-place under `config/`. Do not edit files directly in `~/.config/` — they are symlinks or copies from this repo.
- After editing, run `./config/load-configs.sh` to re-deploy, or `source ~/.bashrc` to reload shell configuration.
- Each `config/<app>/load.sh` handles the deployment for that application. Check it to see exactly where files land.
