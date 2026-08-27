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

## API

POST `http://localhost:22222/notify` with URL-encoded body:

| Parameter | Description |
|-----------|-------------|
| `title` | Notification title (required) |
| `body` | Notification body (required, alias `description` also works) |

Example:

```bash
curl -X POST http://localhost:22222/notify -d "title=Alert&body=Something+happened"
```

The server listens on `http://0.0.0.0:22222`.
