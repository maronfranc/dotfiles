# Notification Server

A simple C HTTP server for posting notifications.

## First Run

```bash
# 1. Build and install to your local bin
make install

# 2. Start the server as a daemon
notification-server start

# 3. In another terminal, send a test notification
curl -X POST http://localhost:22222/notify -d "title=Hello&body=Test+notification"

# 4. Stop the server
notification-server stop
```

## CLI Commands

| Command | Description |
|---------|-------------|
| `notification-server` | Run in foreground (development mode) |
| `notification-server start` | Start as a background daemon |
| `notification-server stop` | Gracefully stop the daemon (SIGTERM → SIGKILL after 5s) |
| `notification-server status` | Show running state (PID) |

## Usage

| Command | Description |
|---------|-------------|
| `make install` | Build and symlink binary to `~/.local/bin` |
| `make uninstall` | Remove the symlink |
| `make run` | Build and run the server locally in foreground |
| `make clean` | Remove the built binary (keeps the symlink) |
| `make test` | Send a test notification (server must be running) |

### Build options

The listen address is defined in the `makefile` only — it is the single source of
truth. The makefile passes it to the compiler as `-DLISTEN_PORT=...` and
`-DLISTEN_HOST='"..."'`, and `notification-server.c` refuses to compile without
both (`#error`), so the port can never silently drift between the two.

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `22222` | Port to listen on (`-DLISTEN_PORT`) |
| `LISTEN_HOST` | `0.0.0.0` | Address to bind (`-DLISTEN_HOST`) |
| `SERVER` | `http://localhost:$(PORT)` | Server URL used by `make test` |
| `URGENCY` | _(unset)_ | Urgency used by `make test` |

```bash
make PORT=8080 LISTEN_HOST=127.0.0.1
make test URGENCY=critical
```

`make` rejects a non-numeric or out-of-range `PORT`, and an empty `LISTEN_HOST`.

Note: the port is compiled in, so re-run `make clean && make PORT=<port>` when changing it.

Compiling by hand is possible but you must pass both defines yourself:

```bash
gcc -DLISTEN_PORT=8080 -DLISTEN_HOST='"0.0.0.0"' -o notification-server notification-server.c
```

## API

POST `http://localhost:22222/notify` with URL-encoded body:

| Parameter | Description |
|-----------|-------------|
| `title` | Notification title (required) |
| `body` | Notification body (required, alias `description` also works) |
| `urgency` | Optional: `low`, `normal` or `critical` (case-insensitive, defaults to `normal`) |
| `icon` | Optional: icon name from the current icon theme, absolute image path, or comma-separated list (alias `app-icon` also works) |

Example:

```bash
curl -X POST http://localhost:22222/notify -d "title=Alert&body=Something+happened"
curl -X POST http://localhost:22222/notify -d "title=Alert&body=Something+happened&urgency=critical"
curl -X POST http://localhost:22222/notify -d "title=Disk+full&body=/dev/sda1&urgency=critical&icon=drive-harddisk-symbolic"
```

An invalid `urgency` value is rejected with `400 Bad Request`.

### Icons and Nerd Fonts

`icon` is forwarded to `notify-send -i`, so anything dunst can resolve works: a stock
icon name, an absolute path to a PNG/SVG, or a comma-separated list. With
`icon_position = left` in `dunst/dunstrc` it is drawn to the left of the text.

Nerd Font glyphs are **not** icons — they are text. Put the glyph in `title` (or `body`)
and it is passed through byte-for-byte:

```bash
curl -X POST http://localhost:22222/notify --data-urlencode "title=󰅚 Build finished" --data-urlencode "urgency=normal"
```

For that to render instead of tofu, the dunst font has to contain the glyphs
(`font = Hack 10` in `dunst/dunstrc` does not, unless a Nerd-Font-patched Hack is
installed and registered under that family name). Check with:

```bash
fc-list | grep -i "nerd" | head
fc-match "Hack:charset=f0c0"   # must resolve to a Nerd Font
```

If it does not, set `font = Hack Nerd Font 10` (or another patched family) in
`config/dunst/dunstrc`.

The server listens on `http://0.0.0.0:22222`.
