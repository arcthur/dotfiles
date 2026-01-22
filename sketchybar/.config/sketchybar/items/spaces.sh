#!/bin/bash

source "$PLUGIN_DIR/apple.sh"

sketchybar --add event aerospace_workspace_change

if command -v aerospace >/dev/null 2>&1; then
    AEROSPACE_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/aerospace"
    main_display_id=""
    secondary_display_id=""

    while IFS=' ' read -r monitor_id display_id is_main; do
        [ -z "$monitor_id" ] && continue

        if [ "$is_main" = "true" ]; then
            main_display_id="$display_id"
        elif [ -z "$secondary_display_id" ]; then
            secondary_display_id="$display_id"
        fi
    done < <(aerospace list-monitors --format '%{monitor-id} %{monitor-appkit-nsscreen-screens-id} %{monitor-is-main}')

    add_space_item() {
        local workspace="$1"
        local label="$2"
        local sync_index="$3"
        local display_id="$4"

        sketchybar --add item "space.$workspace" left                     \
            --subscribe "space.$workspace" aerospace_workspace_change     \
            --set "space.$workspace"                                      \
            display="$display_id"                                         \
            background.color=$HIGHLIGHT                                   \
            background.corner_radius=7                                    \
            background.height=22                                          \
            background.drawing=off                                        \
            label="$label"                                                \
            label.font="$LABEL_FONT:Regular:13.0"                         \
            label.padding_left=5                                          \
            label.padding_right=5                                         \
            icon.drawing=on                                               \
            icon.font="$APP_FONT:Regular:16.0"                            \
            icon.padding_left=6                                           \
            icon.padding_right=6                                          \
            click_script="bash \"$AEROSPACE_CONFIG_DIR/scripts/workspace-sync.sh\" $sync_index" \
            script="$PLUGIN_DIR/aerospace.sh $workspace"
    }

    if [ -n "$main_display_id" ]; then
        for i in {1..10}; do
            add_space_item "$i" "$i" "$i" "$main_display_id"
        done
    fi

    if [ -n "$secondary_display_id" ]; then
        for i in {1..10}; do
            workspace=$((i + 10))
            add_space_item "$workspace" "$i" "$i" "$secondary_display_id"
        done
    fi
fi
