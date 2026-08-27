CC = gcc
CFLAGS = -Wall -Wextra -O2
TARGET = bin/notification-server
SRC = notification-server.c
HOST = http://localhost:22222
SERVER ?= $(HOST)

.PHONY: all clean run daemon stop status test install uninstall

all: $(TARGET)

bin:
	mkdir -p bin

$(TARGET): $(SRC) bin
	$(CC) $(CFLAGS) -o $@ $<

run: $(TARGET)
	./$(TARGET)

daemon: $(TARGET)
	./$(TARGET) start

stop: $(TARGET)
	./$(TARGET) stop

status: $(TARGET)
	./$(TARGET) status

test:
	@echo "Usage: make test SERVER=<url>"
	@echo "Example: make test SERVER=http://localhost:22222"
	@curl -X POST $(SERVER)/notify -d "title=Hello&body=Test+notification"

INSTALL_DIR = $(HOME)/.local/bin

install: $(TARGET)
	@mkdir -p $(INSTALL_DIR)
	@ln -sf $(abspath $(TARGET)) $(INSTALL_DIR)/$(notdir $(TARGET))

uninstall:
	rm -f $(INSTALL_DIR)/$(notdir $(TARGET))
	rm -rf bin
