# Makefile for network_load event provider

TARGET = network
SRC = network.c
CC = clang
CFLAGS = -std=c99 -O2 -Wall

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $@ $<

clean:
	rm -f $(TARGET)
