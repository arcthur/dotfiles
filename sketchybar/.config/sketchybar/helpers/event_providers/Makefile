# Master Makefile for all event providers

PROVIDERS = cpu_load network_load memory_load

.PHONY: all clean $(PROVIDERS)

all: $(PROVIDERS)

$(PROVIDERS):
	@echo "Building $@..."
	@$(MAKE) -C $@

clean:
	@for dir in $(PROVIDERS); do \
		echo "Cleaning $$dir..."; \
		$(MAKE) -C $$dir clean; \
	done

# Install binaries to a common location (optional)
install: all
	@mkdir -p bin
	@cp cpu_load/cpu bin/
	@cp network_load/network bin/
	@cp memory_load/memory bin/
	@echo "Installed to bin/"
