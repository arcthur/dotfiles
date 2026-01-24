/*
 * sketchybar.h - SketchyBar Helper Header
 * From: https://github.com/FelixKratz/SketchyBarHelper
 * License: GPL-3.0
 *
 * A header for C/C++ to directly communicate with SketchyBar
 */

#pragma once

#include <bootstrap.h>
#include <mach/mach.h>
#include <mach/message.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define MACH_HANDLER(name) void name(char *env)
typedef MACH_HANDLER(mach_handler);

struct mach_message {
    mach_msg_header_t header;
    mach_msg_size_t msgh_descriptor_count;
    mach_msg_ool_descriptor_t descriptor;
};

struct mach_buffer {
    struct mach_message message;
    mach_msg_trailer_t trailer;
};

struct mach_server {
    bool is_running;
    mach_port_name_t task;
    mach_port_t port;
    mach_port_t bs_port;

    pthread_t thread;
    mach_handler *handler;
};

static mach_port_t g_mach_port = 0;

static inline mach_port_t mach_get_bs_port(char *bs_name) {
    mach_port_name_t task = mach_task_self();
    mach_port_t bs_port;

    if (task_get_special_port(task, TASK_BOOTSTRAP_PORT, &bs_port) !=
        KERN_SUCCESS) {
        return 0;
    }

    mach_port_t port;
    if (bootstrap_look_up(bs_port, bs_name, &port) != KERN_SUCCESS) {
        return 0;
    }

    return port;
}

static inline char *mach_send_message(mach_port_t port, char *message,
                                       uint32_t len) {
    if (!message || !port) {
        return NULL;
    }

    mach_port_name_t task = mach_task_self();
    mach_port_t response_port;

    if (mach_port_allocate(task, MACH_PORT_RIGHT_RECEIVE, &response_port) !=
        KERN_SUCCESS) {
        return NULL;
    }

    if (mach_port_insert_right(task, response_port, response_port,
                                MACH_MSG_TYPE_MAKE_SEND) != KERN_SUCCESS) {
        return NULL;
    }

    struct mach_message msg = {0};
    msg.header.msgh_remote_port = port;
    msg.header.msgh_local_port = response_port;
    msg.header.msgh_id = response_port;
    msg.header.msgh_bits =
        MACH_MSGH_BITS_SET(MACH_MSG_TYPE_COPY_SEND, MACH_MSG_TYPE_MAKE_SEND,
                           0, MACH_MSGH_BITS_COMPLEX);
    msg.header.msgh_size = sizeof(struct mach_message);
    msg.msgh_descriptor_count = 1;
    msg.descriptor.address = message;
    msg.descriptor.size = len * sizeof(char);
    msg.descriptor.copy = MACH_MSG_VIRTUAL_COPY;
    msg.descriptor.deallocate = false;
    msg.descriptor.type = MACH_MSG_OOL_DESCRIPTOR;

    mach_msg(&msg.header, MACH_SEND_MSG, sizeof(struct mach_message), 0,
             MACH_PORT_NULL, 2000, MACH_PORT_NULL);

    struct mach_buffer buffer = {0};
    mach_msg(&buffer.message.header,
             MACH_RCV_MSG | MACH_RCV_TIMEOUT, 0,
             sizeof(struct mach_buffer), response_port, 400, MACH_PORT_NULL);

    if (buffer.message.descriptor.address) {
        // Response received
    }

    mach_port_mod_refs(task, response_port, MACH_PORT_RIGHT_RECEIVE, -1);
    mach_port_deallocate(task, response_port);

    return buffer.message.descriptor.address;
}

static inline uint32_t format_message(char *message, uint32_t len) {
    if (len > 0 && message[len - 1] == '\n') {
        message[len - 1] = '\0';
        len--;
    }

    bool in_quote = false;
    for (int i = 0; i < len; i++) {
        if (message[i] == '"') {
            in_quote = !in_quote;
        }
        if (!in_quote && message[i] == ' ') {
            message[i] = '\0';
        }
    }
    return len + 1;
}

static inline char *sketchybar(char *message) {
    if (!g_mach_port) {
        g_mach_port = mach_get_bs_port("git.felix.sketchybar");
    }

    uint32_t len = strlen(message);
    char *copy = (char *)malloc(len + 1);
    memcpy(copy, message, len);
    copy[len] = '\0';
    len = format_message(copy, len);

    char *response = mach_send_message(g_mach_port, copy, len);
    free(copy);
    return response;
}

static inline char *env_get_value_for_key(char *env, char *key) {
    char *loc = strstr(env, key);
    if (!loc) return NULL;

    char *result = loc + strlen(key) + 1;
    uint32_t count = 0;
    bool in_quotes = false;

    while (result[count] != '\0') {
        if (result[count] == '"') in_quotes = !in_quotes;
        if (!in_quotes && result[count] == ' ') break;
        count++;
    }

    char *value = (char *)malloc(count + 1);
    memcpy(value, result, count);
    value[count] = '\0';
    return value;
}

static inline void *mach_server_loop(void *context) {
    struct mach_server *server = (struct mach_server *)context;

    while (server->is_running) {
        struct mach_buffer buffer = {0};
        mach_msg(&buffer.message.header,
                 MACH_RCV_MSG, 0,
                 sizeof(struct mach_buffer), server->port,
                 MACH_MSG_TIMEOUT_NONE, MACH_PORT_NULL);

        char *env = buffer.message.descriptor.address;
        if (env && server->handler) {
            server->handler(env);
        }

        if (buffer.message.header.msgh_remote_port) {
            struct mach_message response = {0};
            response.header.msgh_remote_port =
                buffer.message.header.msgh_remote_port;
            response.header.msgh_bits =
                MACH_MSGH_BITS_SET(MACH_MSG_TYPE_MOVE_SEND, 0, 0, 0);
            response.header.msgh_size = sizeof(struct mach_message);

            mach_msg(&response.header, MACH_SEND_MSG,
                     sizeof(struct mach_message), 0, MACH_PORT_NULL,
                     MACH_MSG_TIMEOUT_NONE, MACH_PORT_NULL);
        }

        if (env) {
            mach_vm_deallocate(mach_task_self(), (mach_vm_address_t)env,
                               buffer.message.descriptor.size);
        }
    }

    return NULL;
}

static inline void mach_server_begin(struct mach_server *server,
                                      mach_handler *handler) {
    server->handler = handler;
    server->task = mach_task_self();
    mach_port_allocate(server->task, MACH_PORT_RIGHT_RECEIVE, &server->port);
    mach_port_insert_right(server->task, server->port, server->port,
                           MACH_MSG_TYPE_MAKE_SEND);

    task_get_special_port(server->task, TASK_BOOTSTRAP_PORT, &server->bs_port);
    server->is_running = true;

    pthread_create(&server->thread, NULL, mach_server_loop, server);
}

static inline char *mach_server_register_port(struct mach_server *server,
                                               char *name) {
    if (bootstrap_register(server->bs_port, name, server->port) !=
        KERN_SUCCESS) {
        return NULL;
    }
    return name;
}

static inline void event_server_begin(mach_handler *handler,
                                       char *mach_helper) {
    struct mach_server server = {0};
    mach_server_begin(&server, handler);

    char *registered_name = mach_server_register_port(&server, mach_helper);
    if (!registered_name) {
        fprintf(stderr, "Failed to register mach helper: %s\n", mach_helper);
        exit(1);
    }

    pthread_join(server.thread, NULL);
}
