# Makefile for cpu_load event provider

TARGET = cpu
SRC = cpu.c
CC = clang
CFLAGS = -std=c99 -O2 -Wall

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $@ $<

clean:
	rm -f $(TARGET)
