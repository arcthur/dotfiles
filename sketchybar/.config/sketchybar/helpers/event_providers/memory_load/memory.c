/*
 * memory.c - Memory Load Event Provider for SketchyBar
 *
 * Monitors RAM usage and sends updates to SketchyBar via Mach messaging.
 * Usage: ./memory <update_interval_seconds> <event_name>
 *
 * Example: ./memory 2 memory_update
 */

#include <mach/mach.h>
#include <mach/mach_host.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/sysctl.h>
#include <unistd.h>

#include "../sketchybar.h"

// Get total physical memory
static uint64_t get_total_memory(void) {
    int mib[2] = {CTL_HW, HW_MEMSIZE};
    uint64_t mem;
    size_t len = sizeof(mem);

    if (sysctl(mib, 2, &mem, &len, NULL, 0) < 0) {
        return 0;
    }
    return mem;
}

// Get memory usage percentage
static void get_memory_usage(int *used_percent, uint64_t *used_bytes,
                              uint64_t *total_bytes) {
    mach_msg_type_number_t count = HOST_VM_INFO64_COUNT;
    vm_statistics64_data_t vm_stat;

    if (host_statistics64(mach_host_self(), HOST_VM_INFO64,
                          (host_info64_t)&vm_stat, &count) != KERN_SUCCESS) {
        *used_percent = 0;
        *used_bytes = 0;
        *total_bytes = 0;
        return;
    }

    // Get page size
    vm_size_t page_size;
    host_page_size(mach_host_self(), &page_size);

    *total_bytes = get_total_memory();

    // Calculate used memory (excluding cached/purgeable)
    uint64_t active = (uint64_t)vm_stat.active_count * page_size;
    uint64_t inactive = (uint64_t)vm_stat.inactive_count * page_size;
    uint64_t wired = (uint64_t)vm_stat.wire_count * page_size;
    uint64_t compressed = (uint64_t)vm_stat.compressor_page_count * page_size;

    // Used = active + wired + compressed (similar to Activity Monitor)
    *used_bytes = active + wired + compressed;

    if (*total_bytes > 0) {
        *used_percent = (int)((*used_bytes * 100) / *total_bytes);
    } else {
        *used_percent = 0;
    }

    // Clamp
    if (*used_percent > 100) *used_percent = 100;
    if (*used_percent < 0) *used_percent = 0;
}

// Format bytes to human readable (GB)
static void format_memory(uint64_t bytes, char *buf, size_t buf_size) {
    double gb = (double)bytes / (1024.0 * 1024.0 * 1024.0);
    snprintf(buf, buf_size, "%.1f GB", gb);
}

int main(int argc, char **argv) {
    if (argc < 3) {
        fprintf(stderr, "Usage: %s <interval_seconds> <event_name>\n", argv[0]);
        fprintf(stderr, "Example: %s 2 memory_update\n", argv[0]);
        return 1;
    }

    int interval = atoi(argv[1]);
    char *event_name = argv[2];

    if (interval < 1) {
        interval = 1;
    }

    char message[256];
    char used_str[32];
    char total_str[32];

    while (true) {
        int used_percent;
        uint64_t used_bytes, total_bytes;

        get_memory_usage(&used_percent, &used_bytes, &total_bytes);
        format_memory(used_bytes, used_str, sizeof(used_str));
        format_memory(total_bytes, total_str, sizeof(total_str));

        // Calculate graph value (0.0 - 1.0)
        double graph_value = (double)used_percent / 100.0;
        if (graph_value > 1.0) graph_value = 1.0;
        if (graph_value < 0.0) graph_value = 0.0;

        // Send trigger with memory data
        snprintf(message, sizeof(message),
                 "--trigger %s USED_PERCENT=%d USED_STR=\"%s\" "
                 "TOTAL_STR=\"%s\" GRAPH_VALUE=%.2f",
                 event_name, used_percent, used_str, total_str, graph_value);

        sketchybar(message);
        sleep(interval);
    }

    return 0;
}
