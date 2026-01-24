/*
 * cpu.c - CPU Load Event Provider for SketchyBar
 *
 * Monitors CPU usage and sends updates to SketchyBar via Mach messaging.
 * Uses adaptive polling: more frequent updates when CPU load is high.
 *
 * Usage: ./cpu <base_interval_seconds> <event_name>
 * Example: ./cpu 2 cpu_update
 *
 * Adaptive intervals:
 *   - High load (>=70%): 1 second
 *   - Medium load (>=40%): base interval
 *   - Low load (<40%): base interval * 2 (max 5s)
 */

#include <mach/mach.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "../sketchybar.h"

// CPU tick data structure
struct cpu_ticks {
    uint64_t user;
    uint64_t system;
    uint64_t idle;
    uint64_t nice;
    uint64_t total;
};

// Global state
static struct cpu_ticks g_prev_ticks = {0};
static bool g_first_run = true;

// Get current CPU ticks from kernel
static void get_cpu_ticks(struct cpu_ticks *ticks) {
    mach_msg_type_number_t count = HOST_CPU_LOAD_INFO_COUNT;
    host_cpu_load_info_data_t cpu_info;

    kern_return_t kr = host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO,
                                        (host_info_t)&cpu_info, &count);

    if (kr != KERN_SUCCESS) {
        memset(ticks, 0, sizeof(*ticks));
        return;
    }

    ticks->user = cpu_info.cpu_ticks[CPU_STATE_USER];
    ticks->system = cpu_info.cpu_ticks[CPU_STATE_SYSTEM];
    ticks->idle = cpu_info.cpu_ticks[CPU_STATE_IDLE];
    ticks->nice = cpu_info.cpu_ticks[CPU_STATE_NICE];
    ticks->total = ticks->user + ticks->system + ticks->idle + ticks->nice;
}

// Calculate CPU percentages
static void calculate_cpu_usage(int *total_percent, int *user_percent,
                                 int *sys_percent) {
    struct cpu_ticks current;
    get_cpu_ticks(&current);

    if (g_first_run) {
        g_prev_ticks = current;
        g_first_run = false;
        *total_percent = 0;
        *user_percent = 0;
        *sys_percent = 0;
        return;
    }

    uint64_t delta_total = current.total - g_prev_ticks.total;
    uint64_t delta_user = current.user - g_prev_ticks.user;
    uint64_t delta_system = current.system - g_prev_ticks.system;
    uint64_t delta_idle = current.idle - g_prev_ticks.idle;

    g_prev_ticks = current;

    if (delta_total == 0) {
        *total_percent = 0;
        *user_percent = 0;
        *sys_percent = 0;
        return;
    }

    uint64_t delta_used = delta_total - delta_idle;
    *total_percent = (int)((delta_used * 100) / delta_total);
    *user_percent = (int)((delta_user * 100) / delta_total);
    *sys_percent = (int)((delta_system * 100) / delta_total);

    // Clamp values
    if (*total_percent > 100) *total_percent = 100;
    if (*total_percent < 0) *total_percent = 0;
    if (*user_percent > 100) *user_percent = 100;
    if (*user_percent < 0) *user_percent = 0;
    if (*sys_percent > 100) *sys_percent = 100;
    if (*sys_percent < 0) *sys_percent = 0;
}

// Get adaptive sleep interval based on CPU load
static int get_adaptive_interval(int base_interval, int cpu_percent) {
    if (cpu_percent >= 70) {
        return 1;  // High load: update every second
    } else if (cpu_percent >= 40) {
        return base_interval;  // Medium load: use base interval
    } else {
        // Low load: slower updates (max 5 seconds)
        int slow_interval = base_interval * 2;
        return slow_interval > 5 ? 5 : slow_interval;
    }
}

int main(int argc, char **argv) {
    if (argc < 3) {
        fprintf(stderr, "Usage: %s <base_interval_seconds> <event_name>\n", argv[0]);
        fprintf(stderr, "Example: %s 2 cpu_update\n", argv[0]);
        fprintf(stderr, "\nAdaptive polling:\n");
        fprintf(stderr, "  - High load (>=70%%): 1 second\n");
        fprintf(stderr, "  - Medium load (>=40%%): base interval\n");
        fprintf(stderr, "  - Low load (<40%%): base interval * 2 (max 5s)\n");
        return 1;
    }

    int base_interval = atoi(argv[1]);
    char *event_name = argv[2];

    if (base_interval < 1) {
        base_interval = 1;
    }

    // Initial tick read
    get_cpu_ticks(&g_prev_ticks);
    g_first_run = false;
    sleep(1);  // Initial delay for accurate first reading

    char message[256];

    while (true) {
        int total, user, sys;
        calculate_cpu_usage(&total, &user, &sys);

        // Calculate graph value (0.0 - 1.0)
        double graph_value = (double)total / 100.0;
        if (graph_value > 1.0) graph_value = 1.0;
        if (graph_value < 0.0) graph_value = 0.0;

        // Send trigger with CPU data
        snprintf(message, sizeof(message),
                 "--trigger %s TOTAL_PERCENT=%d USER_PERCENT=%d "
                 "SYS_PERCENT=%d GRAPH_VALUE=%.2f",
                 event_name, total, user, sys, graph_value);

        sketchybar(message);

        // Adaptive sleep based on current load
        int interval = get_adaptive_interval(base_interval, total);
        sleep(interval);
    }

    return 0;
}
