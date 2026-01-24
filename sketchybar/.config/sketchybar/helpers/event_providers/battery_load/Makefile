# Makefile for battery_load event provider

TARGET = battery
SRC = battery.c
CC = clang
CFLAGS = -std=c99 -O2 -Wall
FRAMEWORKS = -framework IOKit -framework CoreFoundation

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $(FRAMEWORKS) -o $@ $<

clean:
	rm -f $(TARGET)
