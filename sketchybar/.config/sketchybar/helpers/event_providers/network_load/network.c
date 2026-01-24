/*
 * network.c - Network Load Event Provider for SketchyBar
 *
 * Monitors network bandwidth and sends updates to SketchyBar via Mach messaging.
 * Usage: ./network <interface> <update_interval_seconds> <event_name>
 *
 * Example: ./network en0 2 network_update
 */

#include <ifaddrs.h>
#include <inttypes.h>
#include <net/if.h>
#include <net/if_var.h>
#include <net/route.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <unistd.h>

#include "../sketchybar.h"

// Network statistics structure
struct net_stats {
    uint64_t bytes_in;
    uint64_t bytes_out;
};

// Global state
static struct net_stats g_prev_stats = {0};
static bool g_first_run = true;
static char g_interface[32] = "en0";

// Get network interface statistics using sysctl
static bool get_net_stats(const char *interface, struct net_stats *stats) {
    int mib[] = {CTL_NET, PF_ROUTE, 0, 0, NET_RT_IFLIST2, 0};
    size_t len;

    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        return false;
    }

    char *buf = (char *)malloc(len);
    if (!buf) {
        return false;
    }

    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        free(buf);
        return false;
    }

    char *end = buf + len;
    char *next = buf;
    bool found = false;

    while (next < end) {
        struct if_msghdr *ifm = (struct if_msghdr *)next;
        next += ifm->ifm_msglen;

        if (ifm->ifm_type == RTM_IFINFO2) {
            struct if_msghdr2 *ifm2 = (struct if_msghdr2 *)ifm;
            struct sockaddr_dl *sdl =
                (struct sockaddr_dl *)(ifm2 + 1);

            // Compare interface name
            if (sdl->sdl_nlen == strlen(interface) &&
                strncmp(sdl->sdl_data, interface, sdl->sdl_nlen) == 0) {
                stats->bytes_in = ifm2->ifm_data.ifi_ibytes;
                stats->bytes_out = ifm2->ifm_data.ifi_obytes;
                found = true;
                break;
            }
        }
    }

    free(buf);
    return found;
}

// Format bytes to human readable string
static void format_bytes(uint64_t bytes, char *buf, size_t buf_size) {
    if (bytes >= 1048576) {
        snprintf(buf, buf_size, "%.1f MB/s", (double)bytes / 1048576.0);
    } else if (bytes >= 1024) {
        snprintf(buf, buf_size, "%" PRIu64 " KB/s", bytes / 1024);
    } else {
        snprintf(buf, buf_size, "%" PRIu64 " B/s", bytes);
    }
}

// Calculate network speeds
static void calculate_network_speed(int interval, uint64_t *speed_in,
                                     uint64_t *speed_out,
                                     char *speed_in_str, char *speed_out_str,
                                     size_t str_size) {
    struct net_stats current;

    if (!get_net_stats(g_interface, &current)) {
        *speed_in = 0;
        *speed_out = 0;
        snprintf(speed_in_str, str_size, "-- B/s");
        snprintf(speed_out_str, str_size, "-- B/s");
        return;
    }

    if (g_first_run) {
        g_prev_stats = current;
        g_first_run = false;
        *speed_in = 0;
        *speed_out = 0;
        snprintf(speed_in_str, str_size, "0 B/s");
        snprintf(speed_out_str, str_size, "0 B/s");
        return;
    }

    uint64_t delta_in = current.bytes_in - g_prev_stats.bytes_in;
    uint64_t delta_out = current.bytes_out - g_prev_stats.bytes_out;

    g_prev_stats = current;

    // Calculate bytes per second
    *speed_in = delta_in / interval;
    *speed_out = delta_out / interval;

    format_bytes(*speed_in, speed_in_str, str_size);
    format_bytes(*speed_out, speed_out_str, str_size);
}

// Detect primary network interface
static void detect_interface(void) {
    struct ifaddrs *ifaddr, *ifa;

    if (getifaddrs(&ifaddr) == -1) {
        return;
    }

    // Prefer en0, then any active interface
    for (ifa = ifaddr; ifa != NULL; ifa = ifa->ifa_next) {
        if (ifa->ifa_addr == NULL) continue;
        if (!(ifa->ifa_flags & IFF_UP)) continue;
        if (ifa->ifa_flags & IFF_LOOPBACK) continue;

        // Check for active interfaces (prefer en0)
        if (strcmp(ifa->ifa_name, "en0") == 0) {
            strncpy(g_interface, ifa->ifa_name, sizeof(g_interface) - 1);
            break;
        }
        // Fallback to first active interface
        if (g_interface[0] == '\0' || strcmp(g_interface, "en0") != 0) {
            strncpy(g_interface, ifa->ifa_name, sizeof(g_interface) - 1);
        }
    }

    freeifaddrs(ifaddr);
}

int main(int argc, char **argv) {
    int interval = 2;
    char *event_name = "network_update";

    // Parse arguments
    if (argc >= 2) {
        strncpy(g_interface, argv[1], sizeof(g_interface) - 1);
    } else {
        detect_interface();
    }

    if (argc >= 3) {
        interval = atoi(argv[2]);
        if (interval < 1) interval = 1;
    }

    if (argc >= 4) {
        event_name = argv[3];
    }

    fprintf(stderr, "network_load: monitoring interface %s, interval %ds\n",
            g_interface, interval);

    // Initial stats read
    struct net_stats initial;
    get_net_stats(g_interface, &initial);
    g_prev_stats = initial;
    g_first_run = false;
    sleep(1);  // Initial delay

    char message[512];
    char speed_in_str[32];
    char speed_out_str[32];

    while (true) {
        uint64_t speed_in, speed_out;
        calculate_network_speed(interval, &speed_in, &speed_out,
                                speed_in_str, speed_out_str, sizeof(speed_in_str));

        // Send trigger with network data
        snprintf(message, sizeof(message),
                 "--trigger %s SPEED_DOWN=%" PRIu64 " SPEED_UP=%" PRIu64 " "
                 "SPEED_DOWN_STR=\"%s\" SPEED_UP_STR=\"%s\" INTERFACE=%s",
                 event_name, speed_in, speed_out,
                 speed_in_str, speed_out_str, g_interface);

        sketchybar_trigger(message);
        sleep(interval);
    }

    return 0;
}
