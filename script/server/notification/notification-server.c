#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <limits.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <errno.h>
#include <signal.h>
#include <time.h>
#include <ctype.h>

#define BUFFER_SIZE 4096

/* The listen address lives in the makefile (PORT / LISTEN_HOST), which passes it
   in as -DLISTEN_PORT=... -DLISTEN_HOST='"..."'. Build through make, or supply
   both by hand: gcc -DLISTEN_PORT=8080 -DLISTEN_HOST='"0.0.0.0"' */
#ifndef LISTEN_PORT
#error "LISTEN_PORT is not defined; build with make, or pass -DLISTEN_PORT=<port>"
#endif

#ifndef LISTEN_HOST
#error "LISTEN_HOST is not defined; build with make, or pass -DLISTEN_HOST='\"<addr>\"'"
#endif

#define XDG_DIR ".local/share/notification-server"
#define PID_FILE XDG_DIR "/notification-server.pid"
#define STOP_TIMEOUT 5

/* ------------------------------------------------------------------ */
/* Signal handling                                                     */
/* ------------------------------------------------------------------ */

static volatile sig_atomic_t running = 1;

static void handle_signal(int sig)
{
    (void)sig;
    running = 0;
}

static void handle_sigchld(int sig)
{
    (void)sig;
    while (waitpid(-1, NULL, WNOHANG) > 0)
        ;
}

/* ------------------------------------------------------------------ */
/* URL decoding helpers                                                */
/* ------------------------------------------------------------------ */

/* Decode in place: the decoded form is never longer than the encoded form */
static void url_decode(char *s)
{
    char *dst = s;
    char *src = s;

    while (*src)
    {
        if (*src == '+')
        {
            *dst++ = ' ';
            src++;
        }
        else if (src[0] == '%' && isxdigit((unsigned char)src[1]) && isxdigit((unsigned char)src[2]))
        {
            char hex[3] = { src[1], src[2], '\0' };
            *dst++ = (char)strtol(hex, NULL, 16);
            src += 3;
        }
        else
        {
            *dst++ = *src++;
        }
    }
    *dst = '\0';
}

/* strdup a string and URL-decode the copy; NULL on allocation failure */
static char *decode_dup(const char *s)
{
    char *out = strdup(s);
    if (out)
        url_decode(out);
    return out;
}

/* Split the body on '&' first, then decode each key and value, so that
   percent-encoded separators inside a value are not mistaken for one */
static int parse_urlencoded(const char *body, char **keys, char **values, int max_params)
{
    if (!body || !*body)
        return 0;

    char raw[BUFFER_SIZE];
    size_t len = strlen(body);
    if (len >= sizeof(raw))
        len = sizeof(raw) - 1;
    memcpy(raw, body, len);
    raw[len] = '\0';

    int count = 0;
    char *saveptr = NULL;
    char *param = strtok_r(raw, "&", &saveptr);

    while (param && count < max_params)
    {
        char *eq = strchr(param, '=');
        if (eq)
        {
            *eq = '\0';
            char *key = decode_dup(param);
            char *value = decode_dup(eq + 1);
            if (key && value)
            {
                keys[count] = key;
                values[count] = value;
                count++;
            }
            else
            {
                free(key);
                free(value);
            }
        }
        param = strtok_r(NULL, "&", &saveptr);
    }
    return count;
}

static void free_params(char **keys, char **values, int count)
{
    for (int i = 0; i < count; i++)
    {
        free(keys[i]);
        free(values[i]);
    }
}

static const char *get_param(char **keys, char **values, int count, const char *key)
{
    for (int i = 0; i < count; i++)
    {
        if (strcmp(keys[i], key) == 0)
            return values[i];
    }
    return NULL;
}

/* Case-insensitive comparison restricted to ASCII */
static int strcaseeq(const char *a, const char *b)
{
    while (*a && *b)
    {
        if (tolower((unsigned char)*a) != tolower((unsigned char)*b))
            return 0;
        a++;
        b++;
    }
    return *a == '\0' && *b == '\0';
}

/* Validate an urgency string; returns a canonical value or NULL if invalid */
static const char *parse_urgency(const char *value)
{
    if (!value || !*value)
        return "normal";
    if (strcaseeq(value, "low"))
        return "low";
    if (strcaseeq(value, "normal"))
        return "normal";
    if (strcaseeq(value, "critical"))
        return "critical";
    return NULL;
}

/* Copy src into dst, wrapping single quotes so it is safe for /bin/sh */
static void shell_quote(const char *src, char *dst, size_t dst_size)
{
    size_t j = 0;
    if (dst_size < 3)
    {
        if (dst_size > 0)
            dst[0] = '\0';
        return;
    }

    dst[j++] = '\'';
    for (size_t i = 0; src[i] && j + 4 < dst_size; i++)
    {
        if (src[i] == '\'')
        {
            memcpy(dst + j, "'\\''", 4);
            j += 4;
        }
        else
        {
            dst[j++] = src[i];
        }
    }
    dst[j++] = '\'';
    dst[j] = '\0';
}

/* ------------------------------------------------------------------ */
/* HTTP helpers                                                        */
/* ------------------------------------------------------------------ */

static void send_response(int client_fd, int status_code, const char *status_text,
                          const char *content_type, const char *body)
{
    int body_len = (int)strlen(body);
    char header[BUFFER_SIZE];
    int hlen;
    hlen = snprintf(header, sizeof(header),
                    "HTTP/1.1 %d %s\r\n"
                    "Content-Type: %s\r\n"
                    "Content-Length: %d\r\n"
                    "Connection: close\r\n"
                    "\r\n",
                    status_code, status_text, content_type, body_len);
    send(client_fd, header, hlen, MSG_NOSIGNAL);
    if (body_len > 0)
        send(client_fd, body, body_len, MSG_NOSIGNAL);
}

static ssize_t read_all(int client_fd, char *buf, size_t buf_len)
{
    size_t total = 0;
    while (total < buf_len - 1)
    {
        fd_set fds;
        struct timeval tv;
        FD_ZERO(&fds);
        FD_SET(client_fd, &fds);
        tv.tv_sec = 0;
        tv.tv_usec = 100000;
        int sel = select(client_fd + 1, &fds, NULL, NULL, &tv);
        if (sel <= 0)
            break;
        ssize_t n = recv(client_fd, buf + total, buf_len - total - 1, 0);
        if (n <= 0)
            break;
        total += n;
    }
    buf[total] = '\0';
    return total;
}

static ssize_t read_request(int client_fd, char *buf, size_t buf_len)
{
    ssize_t total = read_all(client_fd, buf, buf_len);
    if (total <= 0)
        return -1;

    char *header_end = strstr(buf, "\r\n\r\n");
    if (!header_end)
        header_end = strstr(buf, "\n\n");
    if (!header_end)
        return -1;

    long content_length = 0;
    char *cl = strstr(buf, "Content-Length:");
    if (cl)
    {
        content_length = strtol(cl + 15, NULL, 10);
    }

    size_t headers_len = (size_t)(header_end - buf) + 4;
    size_t body_received = (size_t)(total - (ssize_t)headers_len);

    if (content_length > 0 && body_received < (size_t)content_length)
    {
        size_t remaining = (size_t)content_length - body_received;
        if (headers_len + remaining >= buf_len)
            return -1;
        ssize_t n = read_all(client_fd, buf + headers_len, remaining);
        if (n < 0)
            return -1;
        total += n;
    }

    return total;
}

/* ------------------------------------------------------------------ */
/* Client handler                                                      */
/* ------------------------------------------------------------------ */

static void handle_client(int client_fd)
{
    char full_request[BUFFER_SIZE * 2] = {0};
    ssize_t total = read_request(client_fd, full_request, sizeof(full_request));
    if (total <= 0)
        return;

    char method[16] = {0};
    char path[BUFFER_SIZE] = {0};
    char version[16] = {0};
    sscanf(full_request, "%15s %999s %15s", method, path, version);

    if (strcmp(method, "POST") != 0 || strcmp(path, "/notify") != 0)
    {
        send_response(client_fd, 404, "Not Found", "text/plain", "Not Found");
        return;
    }

    char *header_end = strstr(full_request, "\r\n\r\n");
    if (!header_end)
        header_end = strstr(full_request, "\n\n");
    char *body = header_end ? header_end + 4 : "";

    char *keys[64] = {0};
    char *values[64] = {0};
    int param_count = parse_urlencoded(body, keys, values, 64);

    const char *title = get_param(keys, values, param_count, "title");
    const char *description = get_param(keys, values, param_count, "body");
    if (!description)
        description = get_param(keys, values, param_count, "description");
    const char *icon = get_param(keys, values, param_count, "icon");
    if (!icon)
        icon = get_param(keys, values, param_count, "app-icon");

    if (!title)
        title = "";
    if (!description)
        description = "";
    if (!icon)
        icon = "";

    const char *urgency = parse_urgency(get_param(keys, values, param_count, "urgency"));
    if (!urgency)
    {
        send_response(client_fd, 400, "Bad Request", "text/plain",
                      "Invalid urgency, expected one of: low, normal, critical");
        free_params(keys, values, param_count);
        return;
    }

    char time_str[64];
    time_t now = time(NULL);
    struct tm tm_buf;
    struct tm *tm_info = localtime_r(&now, &tm_buf);
    strftime(time_str, sizeof(time_str), "%Y-%m-%dT%H:%M:%S", tm_info);
    if (*icon)
        fprintf(stderr, "[%s] urgency=%s, icon=\"%s\", title=\"%s\", body=\"%s\"\n",
                time_str, urgency, icon, title, description);
    else
        fprintf(stderr, "[%s] urgency=%s, title=\"%s\", body=\"%s\"\n",
                time_str, urgency, title, description);
    fflush(stderr);

    char quoted_title[BUFFER_SIZE];
    char quoted_body[BUFFER_SIZE];
    char quoted_icon[BUFFER_SIZE];
    shell_quote(title, quoted_title, sizeof(quoted_title));
    shell_quote(description, quoted_body, sizeof(quoted_body));
    shell_quote(icon, quoted_icon, sizeof(quoted_icon));

    /* -i takes an icon name from the current theme or an absolute image path */
    char icon_opt[BUFFER_SIZE + 8];
    if (*icon)
        snprintf(icon_opt, sizeof(icon_opt), " -i %s", quoted_icon);
    else
        snprintf(icon_opt, sizeof(icon_opt), "%s", "");

    char cmd[BUFFER_SIZE * 4];
    snprintf(cmd, sizeof(cmd), "notify-send -u '%s'%s %s %s >/dev/null 2>&1",
             urgency, icon_opt, quoted_title, quoted_body);
    FILE *pipe = popen(cmd, "r");
    if (pipe)
        pclose(pipe);
    send_response(client_fd, 200, "OK", "text/plain", "ok");
    close(client_fd);

    free_params(keys, values, param_count);
}

/* ------------------------------------------------------------------ */
/* PID file helpers                                                    */
/* ------------------------------------------------------------------ */

/* Create the XDG state directory */
static void ensure_xdg_dir(void)
{
    const char *home = getenv("HOME");
    if (!home)
    {
        fprintf(stderr, "HOME not set\n");
        exit(1);
    }
    char dir[PATH_MAX];
    snprintf(dir, sizeof(dir), "%s/%s", home, XDG_DIR);
    struct stat st;
    if (stat(dir, &st) == 0)
        return;
    if (mkdir(dir, 0700) < 0)
    {
        perror("mkdir");
        exit(1);
    }
}

/* Write the current PID to the PID file */
static void write_pid(void)
{
    const char *home = getenv("HOME");
    if (!home)
        return;
    char path[PATH_MAX];
    snprintf(path, sizeof(path), "%s/%s", home, PID_FILE);
    FILE *f = fopen(path, "w");
    if (!f)
    {
        perror("fopen");
        return;
    }
    fprintf(f, "%d\n", getpid());
    fclose(f);
}

/* Read PID from file; returns 0 on success, -1 on failure */
static int read_pid(char *buf, size_t buflen)
{
    const char *home = getenv("HOME");
    if (!home)
        return -1;
    char path[PATH_MAX];
    snprintf(path, sizeof(path), "%s/%s", home, PID_FILE);
    FILE *f = fopen(path, "r");
    if (!f)
        return -1;
    ssize_t n = fread(buf, 1, buflen - 1, f);
    fclose(f);
    if (n <= 0)
        return -1;
    buf[n] = '\0';
    return 0;
}

/* Remove the PID file */
static void remove_pid(void)
{
    const char *home = getenv("HOME");
    if (!home)
        return;
    char path[PATH_MAX];
    snprintf(path, sizeof(path), "%s/%s", home, PID_FILE);
    unlink(path);
}

/* ------------------------------------------------------------------ */
/* Desktop notifications                                               */
/* ------------------------------------------------------------------ */

static void notify(const char *summary, const char *body)
{
    char cmd[BUFFER_SIZE];
    snprintf(cmd, sizeof(cmd), "notify-send '%s' '%s' 2>/dev/null", summary, body);
    system(cmd);
}

static void notify_server_start(void)
{
    char msg[128];
    snprintf(msg, sizeof(msg), "Started on port %d", LISTEN_PORT);
    notify("🔔 Notification Server", msg);
}

static void notify_server_stop(void)
{
    notify("🔔 Notification Server", "Stopped");
}

/* ------------------------------------------------------------------ */
/* Subcommands                                                         */
/* ------------------------------------------------------------------ */

/* Daemonize: fork, setsid, detach stdio */
static void daemonize(void)
{
    pid_t pid = fork();
    if (pid < 0)
    {
        perror("fork");
        exit(1);
    }
    if (pid > 0)
        exit(0);  /* parent exits */
    if (setsid() < 0)
    {
        perror("setsid");
        exit(1);
    }
    fclose(stdin);
    fclose(stdout);
    fclose(stderr);
}

static void server_loop(int server_fd);

static void setup_server_socket(int *server_fd_out)
{
    int server_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (server_fd < 0)
    {
        perror("socket");
        exit(1);
    }

    int opt = 1;
    setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));

    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port = htons(LISTEN_PORT);
    inet_pton(AF_INET, LISTEN_HOST, &addr.sin_addr);

    if (bind(server_fd, (struct sockaddr *)&addr, sizeof(addr)) < 0)
    {
        perror("bind");
        close(server_fd);
        exit(1);
    }

    if (listen(server_fd, 128) < 0)
    {
        perror("listen");
        close(server_fd);
        exit(1);
    }

    *server_fd_out = server_fd;
}

static void server_loop(int server_fd)
{
    /* Set a 1-second accept timeout so running flag is checked promptly */
    struct timeval tv;
    tv.tv_sec = 1;
    tv.tv_usec = 0;
    setsockopt(server_fd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));

    while (running)
    {
        struct sockaddr_in client_addr;
        socklen_t client_len = sizeof(client_addr);
        int client_fd = accept(server_fd, (struct sockaddr *)&client_addr, &client_len);
        if (client_fd < 0)
        {
            if (errno == EINTR || errno == EAGAIN || errno == EWOULDBLOCK)
                continue;
            perror("accept");
            continue;
        }
        handle_client(client_fd);
        close(client_fd);
    }
    close(server_fd);
}

/* `start` — daemonize and run the server in the background */
static void cmd_start(void)
{
    ensure_xdg_dir();

    /* Check if already running */
    char buf[64];
    if (read_pid(buf, sizeof(buf)) == 0)
    {
        int pid = (int)strtol(buf, NULL, 10);
        if (kill(pid, 0) == 0)
        {
            fprintf(stderr, "already running (PID %d) on port %d\n", pid, LISTEN_PORT);
            exit(1);
        }
        /* Stale PID file */
        remove_pid();
    }

    daemonize();

    /* Child (grandchild): set up server and run */
    write_pid();
    notify_server_start();
    signal(SIGPIPE, SIG_IGN);
    signal(SIGTERM, handle_signal);
    signal(SIGCHLD, handle_sigchld);

    int server_fd;
    setup_server_socket(&server_fd);
    server_loop(server_fd);
    notify_server_stop();
    exit(0);
}

/* `stop` — send SIGTERM, wait gracefully, SIGKILL after timeout */
static void cmd_stop(void)
{
    char buf[64];
    if (read_pid(buf, sizeof(buf)) != 0)
    {
        fprintf(stderr, "not running\n");
        return;
    }

    int pid = (int)strtol(buf, NULL, 10);

    /* Verify the PID is actually alive */
    if (kill(pid, 0) != 0)
    {
        remove_pid();
        fprintf(stderr, "stale PID file removed\n");
        return;
    }

    fprintf(stderr, "stopping notification-server (PID %d)...\n", pid);
    kill(pid, SIGTERM);

    for (int i = 0; i < STOP_TIMEOUT; i++)
    {
        usleep(1000000);  /* 1 second */
        if (kill(pid, 0) != 0)
        {
            remove_pid();
            notify_server_stop();
            fprintf(stderr, "stopped\n");
            return;
        }
    }

    fprintf(stderr, "force killing...\n");
    kill(pid, SIGKILL);
    waitpid(pid, NULL, 0);
    remove_pid();
    notify_server_stop();
    fprintf(stderr, "killed\n");
}

/* `status` — print running/stopped state */
static void cmd_status(void)
{
    char buf[64];
    if (read_pid(buf, sizeof(buf)) != 0)
    {
        printf("stopped\n");
        return;
    }

    int pid = (int)strtol(buf, NULL, 10);
    if (kill(pid, 0) == 0)
    {
        printf("running (PID %d) on port %d\n", pid, LISTEN_PORT);
    }
    else
    {
        printf("stopped (stale PID %d)\n", pid);
    }
}

/* ------------------------------------------------------------------ */
/* Foreground mode (default, no args)                                  */
/* ------------------------------------------------------------------ */

static void run_foreground(void)
{
    signal(SIGPIPE, SIG_IGN);
    signal(SIGTERM, handle_signal);
    signal(SIGCHLD, handle_sigchld);

    int server_fd;
    setup_server_socket(&server_fd);

    printf("Server running at http://%s:%d/\n", LISTEN_HOST, LISTEN_PORT);
    fflush(stdout);
    notify_server_start();

    server_loop(server_fd);
    notify_server_stop();
}

int main(int argc, char *argv[])
{
    if (argc >= 2 && strcmp(argv[1], "start") == 0)
    {
        cmd_start();
    }
    else if (argc >= 2 && strcmp(argv[1], "stop") == 0)
    {
        cmd_stop();
    }
    else if (argc >= 2 && strcmp(argv[1], "status") == 0)
    {
        cmd_status();
    }
    else
    {
        run_foreground();
    }
    return 0;
}
