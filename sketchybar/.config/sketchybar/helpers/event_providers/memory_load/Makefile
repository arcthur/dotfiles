# Makefile for memory_load event provider

TARGET = memory
SRC = memory.c
CC = clang
CFLAGS = -std=c99 -O2 -Wall

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $@ $<

clean:
	rm -f $(TARGET)
