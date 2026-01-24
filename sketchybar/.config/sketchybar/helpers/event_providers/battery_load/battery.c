/*
 * battery.c - Smart Battery Event Provider for SketchyBar
 *
 * Monitors battery status with adaptive polling intervals:
 * - Critical (<15%): Check every 10 seconds
 * - Low (<25%): Check every 30 seconds
 * - Normal: Check every 60 seconds
 *
 * Only sends updates when battery state actually changes.
 *
 * Usage: ./battery <event_name>
 * Example: ./battery battery_update
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <unistd.h>
#include <IOKit/ps/IOPowerSources.h>
#include <IOKit/ps/IOPSKeys.h>
#include <CoreFoundation/CoreFoundation.h>

#include "../sketchybar.h"

typedef struct {
    int percent;
    bool charging;
    bool has_battery;
} BatteryState;

// Get current battery state
static BatteryState get_battery_state(void) {
    BatteryState state = {0, false, false};

    CFTypeRef ps_info = IOPSCopyPowerSourcesInfo();
    if (!ps_info) return state;

    CFArrayRef ps_list = IOPSCopyPowerSourcesList(ps_info);
    if (!ps_list) {
        CFRelease(ps_info);
        return state;
    }

    CFIndex count = CFArrayGetCount(ps_list);
    for (CFIndex i = 0; i < count; i++) {
        CFDictionaryRef ps = IOPSGetPowerSourceDescription(ps_info,
                              CFArrayGetValueAtIndex(ps_list, i));
        if (!ps) continue;

        // Check if this is an internal battery
        CFStringRef type = CFDictionaryGetValue(ps, CFSTR(kIOPSTypeKey));
        if (!type || !CFEqual(type, CFSTR(kIOPSInternalBatteryType))) continue;

        state.has_battery = true;

        // Get current capacity
        CFNumberRef capacity = CFDictionaryGetValue(ps, CFSTR(kIOPSCurrentCapacityKey));
        if (capacity) {
            CFNumberGetValue(capacity, kCFNumberIntType, &state.percent);
        }

        // Get charging state
        CFStringRef power_source = CFDictionaryGetValue(ps, CFSTR(kIOPSPowerSourceStateKey));
        if (power_source) {
            state.charging = CFEqual(power_source, CFSTR(kIOPSACPowerValue));
        }

        break;  // Found internal battery
    }

    CFRelease(ps_list);
    CFRelease(ps_info);
    return state;
}

// Check if battery state changed
static bool state_changed(BatteryState *prev, BatteryState *curr) {
    return prev->percent != curr->percent ||
           prev->charging != curr->charging ||
           prev->has_battery != curr->has_battery;
}

// Get sleep interval based on battery level
static int get_sleep_interval(BatteryState *state) {
    if (!state->has_battery) {
        return 60;  // No battery, check every minute
    }

    if (state->charging) {
        return 60;  // Charging, no urgency
    }

    // Discharging - adaptive intervals
    if (state->percent <= 15) {
        return 10;  // Critical: every 10 seconds
    } else if (state->percent <= 25) {
        return 30;  // Low: every 30 seconds
    } else {
        return 60;  // Normal: every minute
    }
}

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <event_name>\n", argv[0]);
        fprintf(stderr, "Example: %s battery_update\n", argv[0]);
        return 1;
    }

    char *event_name = argv[1];
    char message[256];

    BatteryState prev_state = {-1, false, false};
    BatteryState curr_state;

    while (true) {
        curr_state = get_battery_state();

        // Only send update if state changed
        if (state_changed(&prev_state, &curr_state)) {
            snprintf(message, sizeof(message),
                     "--trigger %s PERCENT=%d CHARGING=%d HAS_BATTERY=%d",
                     event_name,
                     curr_state.percent,
                     curr_state.charging ? 1 : 0,
                     curr_state.has_battery ? 1 : 0);

            sketchybar_trigger(message);
            prev_state = curr_state;
        }

        int interval = get_sleep_interval(&curr_state);
        sleep(interval);
    }

    return 0;
}
