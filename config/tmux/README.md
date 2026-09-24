# tmux

`tmux.conf` contains the tmux configuration and keybindings. The session manager saves the current tmux session as JSON in:

```text
${XDG_STATE_HOME:-$HOME/.local/state}/tmux/snapshots.json
```

## Setup

```bash
./load-plugin.sh
./load.sh
```

`load-plugin.sh` links `tmux-session-manager` into `~/.local/bin`. `load.sh` deploys `tmux.conf` and restarts tmux, so it will terminate active sessions.

## Session manager

| Key | Action |
|---|---|
| `F9` | Save the current session under its current name |
| `F10` | Select and restore a saved session |
| `F11` | Select and delete a saved session |

The manager preserves session, window, and pane names, working directories, pane layout, focus, and sizes. If a live session with the snapshot's name already exists, restore attaches to it instead of replacing it; running processes are not recreated. The `new` command prompts for a session name and generates a random name when the input is empty. The `stop` command picks a running session with `fzf` and kills it after confirmation; pass a session name to skip the picker and `--yes` to skip the confirmation. Run `new` from an ordinary terminal outside tmux. `restore` can run outside tmux or from a current session; an in-session restore saves the current session first and then switches the client to the selected session. The F-key actions do not use tmux popups.

`export` writes every saved snapshot to a JSON backup in the current directory as `tmux-session-snapshots-<UTC timestamp>.json` unless a path argument is given. `import` restores backups: without a path argument it picks a backup `*.json` from the current directory with `fzf` (non-backup JSON files are ignored), then picks which snapshots to bring in; `import --all` skips that selection and takes every snapshot in the backup. Imported snapshots replace existing ones with the same name or id after confirmation. Both commands accept a path argument, and `--yes` skips their confirmation prompt.

The same commands are available directly. Running the manager without a command opens an `fzf` menu with all available commands:

```bash
tmux-session-manager
tmux-session-manager new
tmux-session-manager save my-session
tmux-session-manager list
tmux-session-manager restore
tmux-session-manager delete
tmux-session-manager stop
tmux-session-manager export
tmux-session-manager export ~/tmux-snapshots.json
tmux-session-manager import
tmux-session-manager import --all
tmux-session-manager import ~/tmux-snapshots.json
```

Dependencies: `tmux`, `jq`, `fzf`, and `flock`.
