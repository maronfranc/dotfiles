CC = gcc
PORT ?= 22222
LISTEN_HOST ?= 0.0.0.0
CFLAGS = -Wall -Wextra -O2 -DLISTEN_PORT=$(PORT) -DLISTEN_HOST='"$(LISTEN_HOST)"'
TARGET = bin/notification-server
SRC = notification-server.c
HOST ?= http://localhost:$(PORT)
SERVER ?= $(HOST)
URGENCY ?=

# The listen address is defined here and nowhere else
ifeq ($(shell [ "$(PORT)" -ge 1 ] 2>/dev/null && [ "$(PORT)" -le 65535 ] && echo ok),)
$(error PORT must be an integer between 1 and 65535, got '$(PORT)')
endif
ifeq ($(shell [ -n "$(LISTEN_HOST)" ] 2>/dev/null && echo ok),)
$(error LISTEN_HOST must not be empty)
endif

.PHONY: all clean run daemon stop status test install uninstall

all: $(TARGET)

bin:
	mkdir -p bin

$(TARGET): $(SRC) bin
	$(CC) $(CFLAGS) -o $@ $<

clean:
	rm -f $(TARGET)

run: $(TARGET)
	./$(TARGET)

daemon: $(TARGET)
	./$(TARGET) start

stop: $(TARGET)
	./$(TARGET) stop

status: $(TARGET)
	./$(TARGET) status

test:
	@echo "Usage: make test [SERVER=<url>] [URGENCY=low|normal|critical]"
	@echo "Example: make test URGENCY=critical SERVER=http://localhost:$(PORT)"
	@curl -X POST $(SERVER)/notify -d "title=Hello&body=Test+notification$(if $(URGENCY),&urgency=$(URGENCY))"

INSTALL_DIR = $(HOME)/.local/bin

install: $(TARGET)
	@mkdir -p $(INSTALL_DIR)
	@ln -sf $(abspath $(TARGET)) $(INSTALL_DIR)/$(notdir $(TARGET))

uninstall:
	rm -f $(INSTALL_DIR)/$(notdir $(TARGET))
	rm -rf bin
