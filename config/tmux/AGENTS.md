# tmux Configuration Instructions

## Files

- `tmux.conf` — tmux options, status bar, plugins, and keybindings.
- `tmux-session-manager.sh` — Bash/`jq` session snapshot manager.
- `load-plugin.sh` — Links `tmux-session-manager` to `~/.local/bin`.
- `load.sh` — Copies `tmux.conf` to `/etc/tmux.conf` and restarts tmux.
- `README.md` — Brief user-facing usage documentation.

## Development

- Keep the session manager Bash-based and compatible with tmux 3.6.
- Preserve the JSON schema and atomic locked writes in `tmux-session-manager.sh`.
- Snapshot the current session only; do not add arbitrary process replay without an explicit design decision.
- Restore must refuse to replace an existing live session with the same name.
- Keep `tmux.conf` bindings aligned with the commands in `README.md`.
- Run `bash -n` on shell scripts and `git diff --check` before finishing.
- Prefer isolated tmux sockets for integration tests; do not run `tmux kill-server` on the user’s default server.

## Deployment

Run from this directory:

```bash
./load-plugin.sh
./load.sh
```

`load.sh` terminates active tmux sessions. Do not run it casually; deploy only when restarting tmux is acceptable.

The manager stores data at:

```text
${XDG_STATE_HOME:-$HOME/.local/state}/tmux/snapshots.json
```

`export` writes all saved snapshots to the current directory as `tmux-session-snapshots-<UTC timestamp>.json` unless a path is given; `import` merges a backup picked from the current directory into the store, replacing snapshots with the same name or id, and `--all` imports every snapshot in the backup without the selection picker.

Required commands are `tmux`, `jq`, `fzf`, and `flock`.
